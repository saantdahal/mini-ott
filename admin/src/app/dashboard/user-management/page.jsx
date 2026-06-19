import AdminSectionPage from "@/components/common/AdminSectionPage";
import UserTable from "@/components/users/UserTable";
import { getAllUsers } from "@/services/user.service";

export default async function UserManagementPage() {
  const users = await getAllUsers();

  const totalUsers = users.length;
  const activeUsers = users.filter((u) => u.status === "active").length;
  const verifiedUsers = users.filter((u) => u.is_email_verified).length;
  const adminUsers = users.filter((u) => u.role === "admin").length;

  return (
    <AdminSectionPage
      eyebrow="Accounts"
      title="User Management"
      description="View and manage all registered users on the platform."
      metrics={[
        {
          label: "Total Users",
          value: totalUsers.toString(),
          meta: "Registered accounts",
        },
        {
          label: "Active Users",
          value: activeUsers.toString(),
          meta: "Currently active",
        },
        {
          label: "Verified",
          value: verifiedUsers.toString(),
          meta: "Email verified",
        },
        {
          label: "Admins",
          value: adminUsers.toString(),
          meta: "Admin accounts",
        },
      ]}
    >
      <div className="rounded-xl border border-foreground/10 bg-background/40 backdrop-blur-xl overflow-hidden shadow-2xl">
        <UserTable users={users} />
      </div>
    </AdminSectionPage>
  );
}
