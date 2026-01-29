import { useState } from "react";
import Login from "./components/Login";
import Register from "./components/Register";
import Admin from "./components/Admin";
import Employee from "./components/Employee";

export default function App() {
  const [token, setToken] = useState(null);
  const [role, setRole] = useState(null);
  const [page, setPage] = useState("login");
  const [loginType, setLoginType] = useState("employee");

  function logout() {
    setToken(null);
    setRole(null);
    setPage("login");
  }

  // NOT LOGGED IN
  if (!token) {
    return (
      <div className="min-h-screen bg-gradient-to-br from-blue-50 to-white flex items-center justify-center p-4">
        <div className="w-full max-w-[400px]">
          {page === "login" && (
            <div className="bg-white rounded-2xl shadow-xl border border-gray-100">
              {/* Header */}
              <div className="text-center pt-8 pb-6 px-6">
                <div className="w-16 h-16 bg-blue-600 rounded-2xl flex items-center justify-center mx-auto mb-4 shadow-lg">
                  <svg className="w-8 h-8 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z" />
                  </svg>
                </div>
                <h1 className="text-2xl font-bold text-gray-900 mb-1">Leave Management</h1>
                <p className="text-sm text-gray-500">Manage your time off efficiently</p>
              </div>

              {/* Tab Selector */}
              <div className="px-6 mb-6">
                <div className="bg-gray-100 rounded-xl p-1 flex gap-1">
                  <button
                    onClick={() => setLoginType("employee")}
                    className={`flex-1 py-2.5 text-sm font-medium rounded-lg transition-all ${loginType === "employee"
                      ? "bg-white text-blue-600 shadow-sm"
                      : "text-gray-600 hover:text-gray-900"
                      }`}
                  >
                    Employee
                  </button>
                  <button
                    onClick={() => setLoginType("admin")}
                    className={`flex-1 py-2.5 text-sm font-medium rounded-lg transition-all ${loginType === "admin"
                      ? "bg-white text-blue-600 shadow-sm"
                      : "text-gray-600 hover:text-gray-900"
                      }`}
                  >
                    Admin
                  </button>
                </div>
              </div>

              {/* Login Form */}
              <div className="px-6 pb-6">
                <Login
                  setToken={setToken}
                  setRole={setRole}
                  loginType={loginType}
                />
              </div>

              {/* Footer */}
              <div className="bg-gray-50 px-6 py-4 text-center rounded-b-2xl border-t border-gray-100">
                <p className="text-sm text-gray-600">
                  Don't have an account?{" "}
                  <button
                    onClick={() => setPage("register")}
                    className="text-blue-600 hover:text-blue-700 font-medium"
                  >
                    Sign up
                  </button>
                </p>
              </div>
            </div>
          )}

          {page === "register" && (
            <div className="bg-white rounded-2xl shadow-xl border border-gray-100">
              <div className="text-center pt-8 pb-6 px-6">
                <div className="w-16 h-16 bg-blue-600 rounded-2xl flex items-center justify-center mx-auto mb-4 shadow-lg">
                  <svg className="w-8 h-8 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M18 9v3m0 0v3m0-3h3m-3 0h-3m-2-5a4 4 0 11-8 0 4 4 0 018 0zM3 20a6 6 0 0112 0v1H3v-1z" />
                  </svg>
                </div>
                <h1 className="text-2xl font-bold text-gray-900 mb-1">Create Account</h1>
                <p className="text-sm text-gray-500">Join our leave management system</p>
              </div>

              {/* Tab Selector */}
              <div className="px-6 mb-6">
                <div className="bg-gray-100 rounded-xl p-1 flex gap-1">
                  <button
                    onClick={() => setLoginType("employee")}
                    className={`flex-1 py-2.5 text-sm font-medium rounded-lg transition-all ${loginType === "employee"
                      ? "bg-white text-blue-600 shadow-sm"
                      : "text-gray-600 hover:text-gray-900"
                      }`}
                  >
                    Employee
                  </button>
                  <button
                    onClick={() => setLoginType("admin")}
                    className={`flex-1 py-2.5 text-sm font-medium rounded-lg transition-all ${loginType === "admin"
                      ? "bg-white text-blue-600 shadow-sm"
                      : "text-gray-600 hover:text-gray-900"
                      }`}
                  >
                    Admin
                  </button>
                </div>
              </div>

              <div className="px-6 pb-6">
                <Register onSuccess={() => setPage("login")} registerType={loginType} />
              </div>

              <div className="bg-gray-50 px-6 py-4 text-center rounded-b-2xl border-t border-gray-100">
                <p className="text-sm text-gray-600">
                  Already have an account?{" "}
                  <button
                    onClick={() => setPage("login")}
                    className="text-blue-600 hover:text-blue-700 font-medium"
                  >
                    Sign in
                  </button>
                </p>
              </div>
            </div>
          )}
        </div>
      </div>
    );
  }

  // LOGGED IN
  return (
    <div className="min-h-screen bg-gray-50">
      {/* Top Navigation */}
      <nav className="bg-white shadow-sm border-b border-gray-200">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="flex justify-between items-center h-16">
            <div className="flex items-center gap-3">
              <div className="w-10 h-10 bg-blue-600 rounded-xl flex items-center justify-center">
                <svg className="w-5 h-5 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z" />
                </svg>
              </div>
              <div>
                <h1 className="text-lg font-bold text-gray-900">Leave Management</h1>
                <p className="text-xs text-gray-500">
                  {role === "ADMIN" ? "Admin Dashboard" : "Employee Portal"}
                </p>
              </div>
            </div>
            <button
              onClick={logout}
              className="px-4 py-2 text-sm font-medium text-red-600 hover:bg-red-50 rounded-lg transition-colors"
            >
              Logout
            </button>
          </div>
        </div>
      </nav>

      {/* Main Content */}
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        {role === "ADMIN" && <Admin token={token} />}
        {role === "EMPLOYEE" && <Employee token={token} />}
      </div>
    </div>
  );
}
