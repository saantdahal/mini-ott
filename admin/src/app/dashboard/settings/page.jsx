import AdminSectionPage from "@/components/common/AdminSectionPage";
import React from "react";

const page = () => {
  return (
    <AdminSectionPage
      eyebrow="Configuration"
      title="Settings"
      description="System configuration overview and environment health indicators."
      metrics={[
        {
          label: "Env Status",
          value: "Healthy",
          meta: "All services connected",
        },
        { label: "2FA Enabled", value: "92%", meta: "Admin account coverage" },
        { label: "API Keys", value: "7", meta: "Active integrations" },
        {
          label: "Last Backup",
          value: "2h ago",
          meta: "Automated backup cycle",
        },
      ]}
    />
  );
};

export default page;
