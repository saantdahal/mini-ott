import AdminSectionPage from "@/components/common/AdminSectionPage";
import React from "react";

const page = () => {
  return (
    <AdminSectionPage
      eyebrow="Interactive"
      title="Live & Voting"
      description="Realtime engagement metrics for live sessions and voting activities."
      metrics={[
        { label: "Live Rooms", value: "6", meta: "Currently active" },
        { label: "Participants", value: "4,120", meta: "Connected users" },
        { label: "Votes Today", value: "18,340", meta: "Across all polls" },
        { label: "Avg Response", value: "1.8s", meta: "Realtime sync delay" },
      ]}
    />
  );
};

export default page;
