# Docker Image Optimization Summary

## Overview

Both backend and frontend Docker images have been optimized using **multi-stage builds** to significantly reduce image size and improve security.

## Backend Image Optimization

### Before (Single-stage)
```dockerfile
FROM node:22-alpine
WORKDIR /app
COPY package*.json ./
RUN npm install          # Installs ALL dependencies (prod + dev)
COPY . .
EXPOSE 3000
CMD ["node", "app.js"]
```

**Issues:**
- Includes devDependencies (jest, supertest, cross-env)
- Larger image size
- Runs as root user (security risk)

### After (Multi-stage)
```dockerfile
# Stage 1: Dependencies
FROM node:22-alpine AS dependencies
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production    # Only production deps

# Stage 2: Production
FROM node:22-alpine AS production
WORKDIR /app
COPY --from=dependencies /app/node_modules ./node_modules
COPY . .
RUN addgroup -g 1001 -S nodejs && \
    adduser -S nodejs -u 1001 && \
    chown -R nodejs:nodejs /app
USER nodejs                      # Non-root user
EXPOSE 3000
CMD ["node", "app.js"]
```

**Benefits:**
- ✅ Only production dependencies included
- ✅ Smaller image size (~50-70% reduction)
- ✅ Runs as non-root user (enhanced security)
- ✅ Faster deployments
- ✅ Reduced attack surface

**Estimated Size:**
- Before: ~200-250 MB
- After: ~80-120 MB

## Frontend Image Optimization

### Current (Already Optimized)
```dockerfile
# Stage 1: Build
FROM node:22-alpine as builder
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build               # Build static files

# Stage 2: Serve
FROM nginx:alpine
COPY --from=builder /app/dist /usr/share/nginx/html
COPY nginx.conf /etc/nginx/conf.d/default.conf
COPY entrypoint.sh /docker-entrypoint.d/99-config.sh
RUN chmod +x /docker-entrypoint.d/99-config.sh
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
```

**Benefits:**
- ✅ No Node.js in final image (only nginx)
- ✅ Only static build artifacts included
- ✅ Minimal image size (~90% reduction from dev)
- ✅ Fast startup time
- ✅ Production-ready nginx server

**Estimated Size:**
- Development (with Node.js): ~400-500 MB
- Production (nginx only): ~30-50 MB

## Additional Optimizations

### .dockerignore Files

Both backend and frontend now have `.dockerignore` files to exclude:
- `node_modules` (installed during build)
- `.git` directory
- Documentation files (*.md)
- IDE configurations
- Log files
- Test coverage reports
- Temporary files

**Benefits:**
- ✅ Faster build context transfer
- ✅ Smaller build context
- ✅ Faster builds

## Build Commands

### Build Backend
```powershell
docker build -t leave-backend:local ./backend
```

### Build Frontend
```powershell
docker build -t leave-frontend:local ./frontend
```

### Check Image Sizes
```powershell
docker images | findstr leave
```

## Security Improvements

### Backend
- Runs as non-root user (`nodejs:nodejs`)
- UID/GID: 1001
- Minimal attack surface (no dev tools)

### Frontend
- Uses official nginx:alpine base
- Only static files exposed
- No build tools in production image

## Performance Improvements

### Faster Deployments
- Smaller images = faster pulls
- Faster container startup
- Less bandwidth usage

### Better Caching
- Multi-stage builds leverage Docker layer caching
- Dependencies cached separately from code
- Rebuilds only changed layers

## Comparison Table

| Metric | Backend (Before) | Backend (After) | Frontend (Dev) | Frontend (Prod) |
|--------|-----------------|-----------------|----------------|-----------------|
| Base Image | node:22-alpine | node:22-alpine | node:22-alpine | nginx:alpine |
| Dependencies | All (prod+dev) | Production only | Build time only | None (static) |
| Image Size | ~200-250 MB | ~80-120 MB | ~400-500 MB | ~30-50 MB |
| User | root | nodejs (1001) | root | nginx |
| Startup Time | Medium | Fast | N/A | Very Fast |
| Security | Basic | Enhanced | N/A | Enhanced |

## Verification

After building, verify the optimizations:

```powershell
# Build images
docker build -t leave-backend:local ./backend
docker build -t leave-frontend:local ./frontend

# Check sizes
docker images leave-backend:local
docker images leave-frontend:local

# Inspect layers
docker history leave-backend:local
docker history leave-frontend:local

# Verify non-root user (backend)
docker run --rm leave-backend:local whoami
# Should output: nodejs
```

## Next Steps

1. Build the optimized images
2. Test locally with k3d
3. Verify functionality
4. Push to container registry for EKS deployment

## References

- [Docker Multi-stage Builds](https://docs.docker.com/build/building/multi-stage/)
- [Docker Best Practices](https://docs.docker.com/develop/dev-best-practices/)
- [Node.js Docker Best Practices](https://github.com/nodejs/docker-node/blob/main/docs/BestPractices.md)
