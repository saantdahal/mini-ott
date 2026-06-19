import AdminSectionPage from "@/components/common/AdminSectionPage";

export default function UserManagementLoading() {
  return (
    <AdminSectionPage
      eyebrow="Accounts"
      title="User Management"
      description="View and manage all registered users on the platform."
    >
      <div className="rounded-xl border border-foreground/10 bg-background/40 backdrop-blur-xl overflow-hidden shadow-2xl">
        <div className="p-6 space-y-4">
          {Array.from({ length: 5 }).map((_, i) => (
            <div key={i} className="flex items-center gap-4 animate-pulse">
              <div className="h-4 w-32 bg-foreground/10 rounded" />
              <div className="h-4 w-48 bg-foreground/10 rounded" />
              <div className="h-4 w-16 bg-foreground/10 rounded" />
              <div className="h-4 w-16 bg-foreground/10 rounded" />
              <div className="h-4 w-24 bg-foreground/10 rounded" />
            </div>
          ))}
        </div>
      </div>
    </AdminSectionPage>
  );
}
