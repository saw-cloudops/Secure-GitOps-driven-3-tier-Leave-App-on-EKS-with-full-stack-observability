import { API_URL } from "../api";
import { useEffect, useState } from "react";
import PropTypes from "prop-types";

const statusColors = {
  APPROVED: "bg-green-100 text-green-700",
  REJECTED: "bg-red-100 text-red-700",
  PENDING: "bg-yellow-100 text-yellow-700"
};

export default function Employee({ token }) {
  const [leaves, setLeaves] = useState([]);
  const [loading, setLoading] = useState(false);

  async function load() {
    setLoading(true);
    const res = await fetch(API_URL + "/leave", {
      headers: { Authorization: `Bearer ${token}` }
    });
    setLeaves(await res.json());
    setLoading(false);
  }

  async function apply(e) {
    e.preventDefault();
    setLoading(true);

    await fetch(API_URL + "/leave", {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        Authorization: `Bearer ${token}`
      },
      body: JSON.stringify({
        start_date: e.target.start.value,
        end_date: e.target.end.value,
        reason: e.target.reason.value
      })
    });

    e.target.reset();
    load();
  }

  useEffect(() => { load(); }, []);

  return (
    <div className="max-w-4xl mx-auto space-y-6">
      {/* Apply Leave Card */}
      <div className="bg-white rounded-2xl shadow-sm border border-gray-200 p-6">
        <div className="flex items-center gap-3 mb-6">
          <div className="w-12 h-12 bg-blue-100 rounded-xl flex items-center justify-center">
            <svg className="w-6 h-6 text-blue-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 4v16m8-8H4" />
            </svg>
          </div>
          <div>
            <h2 className="text-xl font-bold text-gray-900">Apply for Leave</h2>
            <p className="text-sm text-gray-500">Submit a new leave request</p>
          </div>
        </div>

        <form onSubmit={apply} className="space-y-4">
          <div className="grid grid-cols-2 gap-4">
            <div>
              <label htmlFor="start" className="block text-sm font-medium text-gray-700 mb-2">
                Start Date
              </label>
              <input
                id="start"
                type="date"
                name="start"
                required
                className="w-full px-4 py-3 bg-gray-50 border border-gray-200 rounded-xl focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent"
              />
            </div>
            <div>
              <label htmlFor="end" className="block text-sm font-medium text-gray-700 mb-2">
                End Date
              </label>
              <input
                id="end"
                type="date"
                name="end"
                required
                className="w-full px-4 py-3 bg-gray-50 border border-gray-200 rounded-xl focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent"
              />
            </div>
          </div>

          <div>
            <label htmlFor="reason" className="block text-sm font-medium text-gray-700 mb-2">
              Reason
            </label>
            <input
              id="reason"
              name="reason"
              placeholder="e.g., Family vacation, Medical appointment..."
              required
              className="w-full px-4 py-3 bg-gray-50 border border-gray-200 rounded-xl focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent"
            />
          </div>

          <button
            disabled={loading}
            className="w-full bg-blue-600 hover:bg-blue-700 text-white font-medium py-3 rounded-xl transition-colors shadow-sm disabled:opacity-50"
          >
            {loading ? "Submitting..." : "Submit Request"}
          </button>
        </form>
      </div>

      {/* My Leave Requests Card */}
      <div className="bg-white rounded-2xl shadow-sm border border-gray-200 p-6">
        <div className="flex items-center gap-3 mb-6">
          <div className="w-12 h-12 bg-purple-100 rounded-xl flex items-center justify-center">
            <svg className="w-6 h-6 text-purple-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 5H7a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2M9 5a2 2 0 012-2h2a2 2 0 012 2" />
            </svg>
          </div>
          <div>
            <h2 className="text-xl font-bold text-gray-900">My Leave Requests</h2>
            <p className="text-sm text-gray-500">View your leave history</p>
          </div>
        </div>

        {loading && (
          <div className="text-center py-12 text-gray-500">
            Loading...
          </div>
        )}

        {!loading && leaves.length === 0 && (
          <div className="text-center py-12">
            <svg className="w-16 h-16 text-gray-300 mx-auto mb-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M20 13V6a2 2 0 00-2-2H6a2 2 0 00-2 2v7m16 0v5a2 2 0 01-2 2H6a2 2 0 01-2-2v-5m16 0h-2.586a1 1 0 00-.707.293l-2.414 2.414a1 1 0 01-.707.293h-3.172a1 1 0 01-.707-.293l-2.414-2.414A1 1 0 006.586 13H4" />
            </svg>
            <p className="text-gray-500 font-medium">No leave requests yet</p>
            <p className="text-sm text-gray-400 mt-1">Submit your first request above</p>
          </div>
        )}

        <div className="space-y-3">
          {leaves.map(l => (
            <div
              key={l.id}
              className="border border-gray-200 rounded-xl p-4 hover:border-blue-200 hover:bg-blue-50/50 transition-all"
            >
              <div className="flex justify-between items-start">
                <div className="flex-1">
                  <div className="flex items-center gap-2 mb-2">
                    <span className="font-semibold text-gray-900">
                      {l.start_date} → {l.end_date}
                    </span>
                  </div>
                  <p className="text-sm text-gray-600 mb-3">
                    {l.reason || "No reason provided"}
                  </p>
                  <div className="flex items-center gap-3">
                    <span className={`inline-flex items-center px-3 py-1 rounded-full text-xs font-medium ${statusColors[l.status || "PENDING"] || statusColors.PENDING}`}>
                      {l.status || "PENDING"}
                    </span>
                    <span className="text-xs text-gray-400">
                      {new Date(l.created_at).toLocaleDateString()}
                    </span>
                  </div>
                </div>
              </div>
            </div>
          ))}
        </div>
      </div>
    </div>
  );
}

Employee.propTypes = {
  token: PropTypes.string.isRequired
};
