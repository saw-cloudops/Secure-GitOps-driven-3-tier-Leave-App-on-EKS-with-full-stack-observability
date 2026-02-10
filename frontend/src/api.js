/*
LOCAL:
  http://localhost:3000
AWS:
  http://<BACKEND-ALB-DNS>
*/
export const API_URL = import.meta.env.VITE_API_URL || "http://localhost:3000";
