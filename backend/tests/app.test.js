const request = require("supertest");
const app = require("../app");
const db = require("../db");
const bcrypt = require("bcryptjs");

// Mock the database
jest.mock("../db", () => ({
    query: jest.fn(),
}));

describe("Backend API Endpoints", () => {
    beforeEach(() => {
        jest.clearAllMocks();
    });

    describe("GET /health", () => {
        it("should return 200 OK", async () => {
            const res = await request(app).get("/health");
            expect(res.statusCode).toBe(200);
            expect(res.text).toBe("OK");
        });
    });

    describe("GET /api/health", () => {
        it("should return 200 OK via router", async () => {
            const res = await request(app).get("/api/health");
            expect(res.statusCode).toBe(200);
            expect(res.text).toBe("OK");
        });
    });

    describe("POST /api/register", () => {
        it("should register a user successfully", async () => {
            // Mock db query to succeed
            db.query.mockImplementation((sql, params, callback) => {
                callback(null, { insertId: 1 });
            });

            const res = await request(app)
                .post("/api/register")
                .send({ username: "testuser", password: "password123", role: "EMPLOYEE" });

            expect(res.statusCode).toBe(200);
            expect(res.body).toEqual({ message: "User created" });
            expect(db.query).toHaveBeenCalledTimes(1);
        });

        it("should handle database errors", async () => {
            db.query.mockImplementation((sql, params, callback) => {
                callback(new Error("DB Error"), null);
            });

            const res = await request(app)
                .post("/api/register")
                .send({ username: "testuser", password: "password123" });

            expect(res.statusCode).toBe(500);
            expect(res.body).toHaveProperty("error");
        });
    });
});
