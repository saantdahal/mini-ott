import React from "react";

const AdminSectionPage = ({
  eyebrow,
  title,
  description,
  metrics = [],
  note = "",
  children,
}) => {
  return (
    <div className="relative w-full">
      {/* Background with dim effect to match the dashboard */}
      <div className="fixed inset-0 z-0 bg-[url('/background.jpg')] bg-cover bg-center bg-no-repeat opacity-10 pointer-events-none" />

      {/* Main Content Container */}
      <div className="relative z-10 p-4 md:p-8 mx-auto max-w-[1600px] space-y-6">
        {/* Header */}
        <header className="rounded-xl sm:rounded-2xl border border-foreground/10 bg-background/40 backdrop-blur-xl p-4 sm:p-5 md:p-6 shadow-2xl">
          <p className="text-[10px] sm:text-xs md:text-sm text-foreground/50 uppercase tracking-wider font-medium">
            {eyebrow}
          </p>
          <h1 className="text-xl sm:text-2xl md:text-3xl font-bold mt-1 text-foreground">
            {title}
          </h1>
          <p className="text-sm text-brand-muted mt-2">{description}</p>
        </header>

        {/* Metrics Grid */}
        {metrics.length > 0 && (
          <section className="grid grid-cols-2 sm:grid-cols-2 xl:grid-cols-4 gap-3 sm:gap-4 md:gap-6">
            {metrics.map((metric, idx) => (
              <article
                key={metric.label}
                className="relative overflow-hidden rounded-2xl border border-foreground/10 bg-background/40 backdrop-blur-xl p-4 sm:p-5 md:p-6 shadow-2xl flex flex-col justify-between min-h-[110px] sm:min-h-[140px]"
              >
                {/* Subtle gradient overlay mapping to primary colors */}
                <div
                  className="absolute inset-0 opacity-[0.03] pointer-events-none"
                  style={{
                    background: `linear-gradient(135deg, ${idx % 2 === 0 ? "var(--color-brand-primary)" : "var(--color-brand-deep)"} 0%, transparent 100%)`,
                  }}
                />

                <div className="relative z-10 flex items-start justify-between gap-3">
                  <p className="text-xs text-foreground/50 uppercase tracking-wider font-medium">
                    {metric.label}
                  </p>
                  {metric.icon && (
                    <div className="h-8 w-8 rounded-lg bg-brand-primary/10 text-brand-primary flex items-center justify-center">
                      <metric.icon size={16} />
                    </div>
                  )}
                </div>

                <div className="relative z-10 mt-auto pt-2 sm:pt-4">
                  <p className="text-xl sm:text-2xl md:text-3xl font-bold text-foreground">
                    {metric.value}
                  </p>
                  <p className="mt-1 text-xs text-brand-muted">{metric.meta}</p>
                </div>
              </article>
            ))}
          </section>
        )}

        {/* Inject dynamic page content (Tables, Video Grids, etc.) here */}
        {children && <section className="mt-6">{children}</section>}

        {/* Footer Note */}
        {note && (
          <article className="rounded-2xl border border-foreground/10 bg-background/40 backdrop-blur-xl p-5 shadow-2xl text-sm text-foreground/70 flex items-start gap-3">
            <span className="flex-shrink-0 w-1.5 h-1.5 mt-2 rounded-full bg-brand-primary block shadow-[0_0_8px_var(--color-brand-primary)]" />
            <p>{note}</p>
          </article>
        )}
      </div>
    </div>
  );
};

export default AdminSectionPage;