import AdminSectionPage from "@/components/common/AdminSectionPage";
import React from "react";

const page = () => {
  return (
    <AdminSectionPage
      eyebrow="Live & Voting"
      title="Poll Results"
      description="Summary of poll participation and response trends."
      metrics={[
        { label: "Polls Closed", value: "42", meta: "This month" },
        {
          label: "Total Votes",
          value: "1,26,402",
          meta: "All responses counted",
        },
        { label: "Avg Turnout", value: "64%", meta: "Per poll audience" },
        {
          label: "Top Campaign",
          value: "Music Awards",
          meta: "Highest engagement",
        },
      ]}
    />
  );
};

export default page;
