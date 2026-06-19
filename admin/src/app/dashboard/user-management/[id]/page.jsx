import AdminSectionPage from "@/components/common/AdminSectionPage";
import { getUserById } from "@/services/user.service";
import Link from "next/link";

export default async function UserDetailPage({ params }) {
  const { id } = await params;
  const user = await getUserById(id);

  if (!user) {
    return (
      <AdminSectionPage
        eyebrow="Accounts"
        title="User Not Found"
        description="The requested user does not exist or has been removed."
      >
        <div className="rounded-xl border border-foreground/10 bg-background/40 backdrop-blur-xl p-8 shadow-2xl text-center">
          <p className="text-foreground/60 text-sm mb-4">
            Could not find a user with this ID.
          </p>
          <Link
            href="/dashboard/user-management"
            className="inline-flex items-center px-4 py-2 rounded-lg text-sm font-medium bg-foreground/5 border border-foreground/10 hover:bg-foreground/10 text-foreground/70 hover:text-foreground transition-colors"
          >
            Back to Users
          </Link>
        </div>
      </AdminSectionPage>
    );
  }

  const fields = [
    { label: "Full Name", value: user.full_name },
    { label: "Email", value: user.email },
    { label: "Phone", value: user.phone || "N/A" },
    { label: "Gender", value: user.gender || "N/A" },
    { label: "Country", value: user.country || "N/A" },
    {
      label: "Role",
      value: user.role,
      badge: true,
      badgeClass:
        user.role === "admin"
          ? "bg-brand-primary/20 text-brand-primary"
          : "bg-blue-500/20 text-blue-400",
    },
    {
      label: "Status",
      value: user.status,
      badge: true,
      badgeClass:
        user.status === "active"
          ? "bg-green-500/20 text-green-500"
          : "bg-red-500/20 text-red-400",
    },
    {
      label: "Date of Birth",
      value: user.date_of_birth
        ? new Date(user.date_of_birth).toLocaleDateString("en-US", {
            year: "numeric",
            month: "long",
            day: "numeric",
          })
        : "N/A",
    },
    {
      label: "Last Login",
      value: user.last_login_at
        ? new Date(user.last_login_at).toLocaleDateString("en-US", {
            year: "numeric",
            month: "short",
            day: "numeric",
            hour: "2-digit",
            minute: "2-digit",
          })
        : "Never",
    },
  ];

  return (
    <AdminSectionPage
      eyebrow="Accounts"
      title={user.full_name}
      description={`User details for ${user.email}`}
    >
      <div className="rounded-xl border border-foreground/10 bg-background/40 backdrop-blur-xl p-6 shadow-2xl">
        <div className="flex items-center justify-between mb-6">
          <h2 className="text-lg font-semibold text-foreground">
            User Information
          </h2>
          <Link
            href="/dashboard/user-management"
            className="inline-flex items-center px-4 py-2 rounded-lg text-sm font-medium bg-foreground/5 border border-foreground/10 hover:bg-foreground/10 text-foreground/70 hover:text-foreground transition-colors"
          >
            Back to Users
          </Link>
        </div>

        <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
          {fields.map((field) => (
            <div
              key={field.label}
              className="rounded-lg border border-foreground/10 bg-foreground/5 p-4"
            >
              <p className="text-xs text-foreground/50 uppercase tracking-wider font-medium mb-1">
                {field.label}
              </p>
              {field.badge ? (
                <span
                  className={`inline-block px-2 py-1 rounded text-xs font-bold uppercase tracking-wider ${field.badgeClass}`}
                >
                  {field.value}
                </span>
              ) : (
                <p className="text-sm font-medium text-foreground">
                  {field.value}
                </p>
              )}
            </div>
          ))}
        </div>
      </div>
    </AdminSectionPage>
  );
}
