const request = require("supertest");
const express = require("express");
const app = require("../app"); // Make sure app.js exports 'app' (we might need to refactor app.js to export it)

// Mock the database
jest.mock("../db", () => ({
    query: jest.fn(),
}));

const db = require("../db");

describe("Backend API Tests", () => {
    beforeEach(() => {
        jest.clearAllMocks();
    });

    /* Test /health */
    test("GET /health should return 200 OK", async () => {
        // We need to export app from app.js for this to work.
        // If app.js starts listening immediately, it might be tricky.
        // Ideally we separate app creation from listening.
        // For now, let's assume we can refactor app.js slightly or use a workaround.

        // BUT since I cannot easily refactor app.js to export without breaking the running server logic 
        // (if I export, the require('../app') will execute the file and start the server), 
        // I will mock the entire app flow or better yet, refactor app.js first.
    });
});
