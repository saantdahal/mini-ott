"use client";

import { useRouter } from "next/navigation";
import { useState } from "react";
import { deleteUser } from "@/services/user.service";

export default function UserTable({ users }) {
  const router = useRouter();
  const [deletingId, setDeletingId] = useState(null);
  const [error, setError] = useState("");

  const handleView = (userId) => {
    router.push(`/dashboard/user-management/${userId}`);
  };

  const handleDelete = async (userId, fullName) => {
    if (!confirm(`Are you sure you want to delete "${fullName}"?`)) return;

    setDeletingId(userId);
    setError("");

    const result = await deleteUser(userId);

    if (result?.success) {
      router.refresh();
    } else {
      setError(result?.message || "Failed to delete user");
    }

    setDeletingId(null);
  };

  if (users.length === 0) {
    return (
      <div className="text-center py-12 text-foreground/60 text-sm">
        No users found.
      </div>
    );
  }

  return (
    <>
      {error && (
        <div className="mb-4 px-4 py-3 rounded-lg bg-red-500/10 border border-red-500/20 text-red-400 text-sm">
          {error}
        </div>
      )}
      <div className="overflow-x-auto">
        <table className="w-full text-left text-sm text-foreground/80">
          <thead className="bg-foreground/5 border-b border-foreground/10 text-xs uppercase font-semibold text-foreground/60">
            <tr>
              <th className="px-6 py-4">Full Name</th>
              <th className="px-6 py-4">Email</th>
              <th className="px-6 py-4">Role</th>
              <th className="px-6 py-4">Status</th>
              <th className="px-6 py-4">Created Date</th>
              <th className="px-6 py-4 text-right">Actions</th>
            </tr>
          </thead>
          <tbody className="divide-y divide-foreground/10">
            {users.map((user) => (
              <tr
                key={user.user_id}
                className="hover:bg-foreground/5 transition-colors"
              >
                <td className="px-6 py-4 font-medium text-foreground">
                  {user.full_name}
                </td>
                <td className="px-6 py-4">{user.email}</td>
                <td className="px-6 py-4">
                  <span
                    className={`px-2 py-1 rounded text-[10px] font-bold uppercase tracking-wider ${
                      user.role === "admin"
                        ? "bg-brand-primary/20 text-brand-primary"
                        : "bg-blue-500/20 text-blue-400"
                    }`}
                  >
                    {user.role}
                  </span>
                </td>
                <td className="px-6 py-4">
                  <span
                    className={`px-2 py-1 rounded text-[10px] font-bold uppercase tracking-wider ${
                      user.status === "active"
                        ? "bg-green-500/20 text-green-500"
                        : "bg-red-500/20 text-red-400"
                    }`}
                  >
                    {user.status}
                  </span>
                </td>
                <td className="px-6 py-4 text-xs text-foreground/60">
                  {new Date(user.created_at).toLocaleDateString("en-US", {
                    year: "numeric",
                    month: "short",
                    day: "numeric",
                  })}
                </td>
                <td className="px-6 py-4 text-right">
                  <div className="flex items-center justify-end gap-2">
                    <button
                      onClick={() => handleView(user.user_id)}
                      className="inline-flex items-center px-3 py-1.5 rounded-lg text-xs font-medium bg-foreground/5 border border-foreground/10 hover:bg-foreground/10 text-foreground/70 hover:text-foreground transition-colors"
                    >
                      View
                    </button>
                    <button
                      onClick={() => handleDelete(user.user_id, user.full_name)}
                      disabled={deletingId === user.user_id}
                      className="inline-flex items-center px-3 py-1.5 rounded-lg text-xs font-medium bg-red-500/10 border border-red-500/20 hover:bg-red-500/20 text-red-400 hover:text-red-300 transition-colors disabled:opacity-50 disabled:cursor-not-allowed"
                    >
                      {deletingId === user.user_id ? "Deleting..." : "Delete"}
                    </button>
                  </div>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </>
  );
}
