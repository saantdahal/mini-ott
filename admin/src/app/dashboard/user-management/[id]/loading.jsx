import AdminSectionPage from "@/components/common/AdminSectionPage";

export default function UserDetailLoading() {
  return (
    <AdminSectionPage
      eyebrow="Accounts"
      title="Loading..."
      description="Fetching user details"
    >
      <div className="rounded-xl border border-foreground/10 bg-background/40 backdrop-blur-xl p-6 shadow-2xl">
        <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
          {Array.from({ length: 9 }).map((_, i) => (
            <div
              key={i}
              className="rounded-lg border border-foreground/10 bg-foreground/5 p-4 animate-pulse"
            >
              <div className="h-3 w-20 bg-foreground/10 rounded mb-2" />
              <div className="h-4 w-36 bg-foreground/10 rounded" />
            </div>
          ))}
        </div>
      </div>
    </AdminSectionPage>
  );
}
