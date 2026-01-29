
import http from 'k6/http';
import { check, sleep, group } from 'k6';
import { Rate } from 'k6/metrics';

// Custom metrics
const errorRate = new Rate('errors');

// Test Configuration
export const options = {
    stages: [
        { duration: '1m', target: 20 },  // Ramp up to 20 users
        { duration: '2m', target: 50 },  // Spike to 50 users (Should trigger HPA)
        { duration: '2m', target: 50 },  // Maintain high load
        { duration: '1m', target: 0 },   // Ramp down
    ],
    thresholds: {
        'http_req_duration': ['p(95)<500'], // 95% of requests must be faster than 500ms
        'errors': ['rate<0.01'],            // Error rate must be less than 1%
    },
};

const BASE_URL = __ENV.API_URL || 'http://localhost:3000'; // Override with your ALB URL

// Utils
function getRandomUser() {
    const id = Math.floor(Math.random() * 10000);
    return {
        username: `user${id}`,
        password: `pass${id}`,
    };
}

export default function () {
    const user = getRandomUser();
    let token = "";

    group('User Flow: Register -> Login -> Apply Leave -> Check Leave', () => {

        // 1. REGISTER
        let res = http.post(`${BASE_URL}/api/register`, JSON.stringify({
            username: user.username,
            password: user.password,
            role: 'EMPLOYEE'
        }), { headers: { 'Content-Type': 'application/json' } });

        // We allow 409 (Conflict) if user already exists from random collision
        check(res, {
            'Register success or conflict': (r) => r.status === 200 || r.status === 409, // Accept conflict
        }) || errorRate.add(1);

        sleep(1);

        // 2. LOGIN (Get Token)
        res = http.post(`${BASE_URL}/api/login`, JSON.stringify({
            username: user.username,
            password: user.password
        }), { headers: { 'Content-Type': 'application/json' } });

        const loginSuccess = check(res, {
            'Login successful': (r) => r.status === 200 && r.json('token') !== undefined,
        });

        if (!loginSuccess) {
            errorRate.add(1);
            return; // Stop iteration if login fails
        }

        token = res.json('token');
        const authHeaders = {
            'Content-Type': 'application/json',
            'Authorization': `Bearer ${token}`
        };

        sleep(1);

        // 3. APPLY LEAVE
        res = http.post(`${BASE_URL}/api/leave`, JSON.stringify({
            start_date: '2025-01-01',
            end_date: '2025-01-05',
            reason: 'Vacation'
        }), { headers: authHeaders });

        check(res, {
            'Apply Leave success': (r) => r.status === 200,
        }) || errorRate.add(1);

        sleep(1);

        // 4. VIEW LEAVES
        res = http.get(`${BASE_URL}/api/leave`, { headers: authHeaders });

        check(res, {
            'Get Leaves success': (r) => r.status === 200,
        }) || errorRate.add(1);
    });

    sleep(1);
}
