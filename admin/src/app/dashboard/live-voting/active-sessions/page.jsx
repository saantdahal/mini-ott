import AdminSectionPage from "@/components/common/AdminSectionPage";
import React from "react";

const page = () => {
  return (
    <AdminSectionPage
      eyebrow="Live & Voting"
      title="Active Sessions"
      description="Current session load and stability indicators."
      metrics={[
        { label: "Sessions Running", value: "6", meta: "No outage detected" },
        {
          label: "Peak Viewers",
          value: "1,284",
          meta: "Highest concurrent today",
        },
        {
          label: "Avg Session Time",
          value: "22m",
          meta: "User retention window",
        },
        { label: "Errors", value: "0.2%", meta: "Realtime stream errors" },
      ]}
    />
  );
};

export default page;
