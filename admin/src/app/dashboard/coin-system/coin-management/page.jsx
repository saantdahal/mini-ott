import { getCoinPackages } from "@/services/coin.service";
import AdminSectionPage from "@/components/common/AdminSectionPage";
import CreateCoinPackageForm from "@/components/coin/CreateCoinPackageForm";

export default async function PricingPlansPage() {
  const packages = await getCoinPackages();

  const activePackages = packages.filter(
    (pkg) => pkg.status === "active",
  ).length;
  const totalValue = packages.reduce(
    (sum, pkg) => sum + parseFloat(pkg.price_amount || 0),
    0,
  );

  return (
    <div className="space-y-4 md:space-y-8">
      <AdminSectionPage
        eyebrow="Coin System"
        title="Pricing Plans"
        metrics={[
          {
            label: "Active Plans",
            value: activePackages.toString(),
            meta: "Available",
          },
          {
            label: "Total Plans",
            value: packages.length.toString(),
            meta: "All",
          },
          {
            label: "Total Value",
            value: `${totalValue.toLocaleString()} NPR`,
            meta: "Revenue",
          },
        ]}
      />

      <div className="px-4 md:px-8">
        <CreateCoinPackageForm />
      </div>

      <div className="space-y-3 px-4 md:px-8">
        <h2 className="text-base md:text-lg font-semibold mb-3 md:mb-4">All Coin Packages</h2>
        {packages.length === 0 ? (
          <div className="text-center py-12 border rounded-lg bg-background text-foreground/60 text-sm">
            No coin packages found.
          </div>
        ) : (
          packages.map(pkg => (
            <div
              key={pkg.coin_package_id}
              className="rounded-lg border border-foreground/10 bg-background p-3 sm:p-4 shadow-sm"
            >
              <div className="flex flex-col md:flex-row md:items-center md:justify-between gap-3 sm:gap-4">
                <div className="flex-1 min-w-0">
                  <div className="flex items-center gap-2 mb-1">
                    <h3 className="text-sm sm:text-base font-semibold truncate">{pkg.title}</h3>
                    {pkg.is_popular && (
                      <span className="bg-brand-primary/10 text-brand-primary text-xs font-semibold px-2 py-1 rounded">
                        Popular
                      </span>
                    )}
                  </div>
                  <p className="text-xs text-foreground/60">
                    {pkg.description}
                  </p>
                </div>

                <div className="grid grid-cols-3 sm:grid-cols-5 gap-3 sm:gap-6 text-sm">
                  <div>
                    <p className="text-xs text-brand-muted">Coins</p>
                    <p className="font-semibold">{pkg.coins}</p>
                  </div>
                  <div>
                    <p className="text-xs text-brand-muted">Bonus</p>
                    <p className="font-semibold text-green-600">
                      +{pkg.bonus_coins}
                    </p>
                  </div>
                  <div>
                    <p className="text-xs text-brand-muted">Order</p>
                    <p className="font-semibold">#{pkg.sort_order}</p>
                  </div>
                  <div>
                    <p className="text-xs text-brand-muted">Price</p>
                    <p className="font-semibold text-brand-primary">
                      {pkg.price_amount} {pkg.currency}
                    </p>
                  </div>
                  <div>
                    <p className="text-xs text-brand-muted">Status</p>
                    <span
                      className={`text-xs font-semibold px-2 py-0.5 rounded ${pkg.status === "active" ? "bg-green-100 text-green-800" : "bg-gray-100"}`}
                    >
                      {pkg.status}
                    </span>
                  </div>
                </div>
              </div>
            </div>
          ))
        )}
      </div>
    </div>
  );
}
