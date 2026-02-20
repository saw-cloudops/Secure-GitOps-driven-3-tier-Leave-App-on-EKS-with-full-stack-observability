import { API_URL } from "../api";
import { useState } from "react";
import PropTypes from "prop-types";

export default function Register({ onSuccess, registerType }) {
  const [loading, setLoading] = useState(false);
  const [message, setMessage] = useState("");

  async function register(e) {
    e.preventDefault();
    setLoading(true);
    setMessage("");

    const form = e.target;
    const role = registerType === "admin" ? "ADMIN" : "EMPLOYEE";

    try {
      const res = await fetch(API_URL + "/register", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          username: form.user.value,
          password: form.pass.value,
          role: role
        })
      });

      if (!res.ok) {
        throw new Error("Registration failed. Username may already exist.");
      }

      setMessage("Account created successfully! Redirecting...");
      form.reset();

      setTimeout(() => {
        onSuccess();
      }, 1500);
    } catch (err) {
      setMessage(err.message);
    } finally {
      setLoading(false);
    }
  }

  return (
    <form onSubmit={register} className="space-y-4">
      {message && (
        <div className={`px-4 py-3 rounded-xl text-sm border ${message.includes("successfully")
          ? "bg-green-50 border-green-200 text-green-700"
          : "bg-red-50 border-red-200 text-red-600"
          }`}>
          {message}
        </div>
      )}

      <div>
        <label htmlFor="user" className="block text-sm font-medium text-gray-700 mb-2">
          Username
        </label>
        <input
          id="user"
          name="user"
          placeholder="Choose a username"
          required
          autoComplete="username"
          className="w-full px-4 py-3 bg-gray-50 border border-gray-200 rounded-xl focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent transition-all"
        />
      </div>

      <div>
        <label htmlFor="pass" className="block text-sm font-medium text-gray-700 mb-2">
          Password
        </label>
        <input
          id="pass"
          name="pass"
          type="password"
          placeholder="Create a password"
          required
          autoComplete="new-password"
          className="w-full px-4 py-3 bg-gray-50 border border-gray-200 rounded-xl focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent transition-all"
        />
      </div>

      <button
        disabled={loading}
        className="w-full bg-blue-600 hover:bg-blue-700 active:bg-blue-800 text-white font-medium py-3 rounded-xl transition-colors shadow-sm disabled:opacity-50 disabled:cursor-not-allowed"
      >
        {loading ? "Creating account..." : "Create Account"}
      </button>
    </form>
  );
}

Register.propTypes = {
  onSuccess: PropTypes.func.isRequired,
  registerType: PropTypes.string.isRequired
};
