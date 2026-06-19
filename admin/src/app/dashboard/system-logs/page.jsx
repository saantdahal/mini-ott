import AdminSectionPage from "@/components/common/AdminSectionPage";
import React from "react";

const page = () => {
  return (
    <AdminSectionPage
      eyebrow="Monitoring"
      title="System Logs"
      description="Operational audit summary for service and platform events."
      metrics={[
        { label: "Logs Today", value: "12,840", meta: "Total entries" },
        { label: "Warnings", value: "64", meta: "Needs observation" },
        { label: "Critical", value: "4", meta: "Escalated incidents" },
        { label: "Retention", value: "90 Days", meta: "Current policy" },
      ]}
    />
  );
};

export default page;
