import LoginFormClient from "@/components/auth/LoginFormClient";
import { adminProxy } from "@/lib/adminProxy";
import { redirect } from "next/navigation";
import React from "react";

export const dynamic = "force-dynamic";

const page = async () => {
  const { allowed } = await adminProxy();

  if (allowed) {
    redirect("/dashboard");
  }

  return (
    <div>
      <LoginFormClient />
    </div>
  );
};

export default page;
