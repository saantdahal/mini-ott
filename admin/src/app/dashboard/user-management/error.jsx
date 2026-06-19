"use client";

import AdminSectionPage from "@/components/common/AdminSectionPage";

export default function UserManagementError({ reset }) {
  return (
    <AdminSectionPage
      eyebrow="Accounts"
      title="User Management"
      description="Something went wrong while loading users."
    >
      <div className="rounded-xl border border-foreground/10 bg-background/40 backdrop-blur-xl p-8 shadow-2xl text-center">
        <p className="text-red-400 text-sm mb-4">
          Failed to load user data. Please try again.
        </p>
        <button
          onClick={() => reset()}
          className="inline-flex items-center px-4 py-2 rounded-lg text-sm font-medium bg-foreground/5 border border-foreground/10 hover:bg-foreground/10 text-foreground/70 hover:text-foreground transition-colors"
        >
          Retry
        </button>
      </div>
    </AdminSectionPage>
  );
}
