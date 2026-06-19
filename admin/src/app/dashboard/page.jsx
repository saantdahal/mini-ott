"use client";

import {
  Calendar,
  Eye,
  Film,
  Play,
  Radio,
  TrendingUp,
  UserCheck,
} from "lucide-react";
import React, { useState } from "react";
import {
  Area,
  AreaChart,
  Bar,
  BarChart,
  CartesianGrid,
  Cell,
  Pie,
  PieChart,
  ResponsiveContainer,
  Tooltip,
  XAxis,
  YAxis,
} from "recharts";

// --- DUMMY DATA --- //
const summaryCards = [
  {
    title: "Total Content",
    value: "248",
    growth: "+12 this week",
    icon: Film,
  },
  {
    title: "Live Sessions",
    value: "06",
    growth: "+2 active now",
    icon: Radio,
  },
  {
    title: "Total Views",
    value: "1.2M",
    growth: "+8.4% this month",
    icon: Eye,
  },
  {
    title: "Premium Access",
    value: "3,940",
    growth: "+5.1% this month",
    icon: UserCheck,
  },
];

const weeklyData = [
  { name: "17 Sun", thisWeek: 240, lastWeek: 180 },
  { name: "18 Mon", thisWeek: 139, lastWeek: 200 },
  { name: "19 Tue", thisWeek: 380, lastWeek: 250 },
  { name: "20 Wed", thisWeek: 390, lastWeek: 280 },
  { name: "21 Thu", thisWeek: 290, lastWeek: 210 },
  { name: "22 Fri", thisWeek: 330, lastWeek: 260 },
  { name: "23 Sat", thisWeek: 250, lastWeek: 200 },
];

const distributionData = [
  { name: "Movies", value: 400 },
  { name: "Series", value: 300 },
  { name: "Live TV", value: 200 },
  { name: "Podcasts", value: 100 },
];
const COLORS = ["#6818a5", "#f9626c", "#3d3195", "#fbfaff"];

const earningsData = [
  { name: "Jan", subscriptions: 4000, ads: 2400 },
  { name: "Feb", subscriptions: 3000, ads: 1398 },
  { name: "Mar", subscriptions: 2000, ads: 9800 },
  { name: "Apr", subscriptions: 2780, ads: 3908 },
  { name: "May", subscriptions: 1890, ads: 4800 },
  { name: "Jun", subscriptions: 2390, ads: 3800 },
  { name: "Jul", subscriptions: 3490, ads: 4300 },
];

const CustomTooltip = ({ active, payload, label }) => {
  if (active && payload && payload.length) {
    return (
      <div className="rounded-lg border border-foreground/10 bg-background/80 backdrop-blur-md p-3 shadow-xl">
        <p className="text-sm font-semibold text-foreground mb-2">{label}</p>
        {payload.map((entry, index) => (
          <p
            key={`item-${index}`}
            className="text-xs text-foreground/80 flex items-center gap-2"
          >
            <span
              className="h-2 w-2 rounded-full"
              style={{ backgroundColor: entry.color }}
            />
            {entry.name}: {entry.value}
          </p>
        ))}
      </div>
    );
  }
  return null;
};

const DashboardPage = () => {
  const [timeFilter, setTimeFilter] = useState("12 months");

  return (
    <div className="relative min-h-screen w-full">
      {/* Background with dim effect */}
      <div className="fixed inset-0 z-0 bg-[url('/background.jpg')] bg-cover bg-center bg-no-repeat opacity-10 pointer-events-none" />

      {/* Main Content Container with extra margins */}
      <div className="relative z-10 p-4 md:p-8 mx-auto max-w-[1600px] space-y-6">
        {/* HEADER */}
        <header className="flex flex-col md:flex-row md:items-end justify-between gap-4">
          <div>
            <h1 className="text-2xl md:text-3xl font-bold text-foreground">
              Welcome To Dashboard
            </h1>
            <p className="text-sm text-brand-muted mt-1">
              Here's what happening with your platform today
            </p>
          </div>
          <div className="flex items-center gap-3 rounded-lg border border-foreground/10 bg-background/40 backdrop-blur-xl px-4 py-2 shadow-sm">
            <Calendar size={16} className="text-brand-primary" />
            <span className="text-sm text-foreground/80 font-medium">
              Sep 01, 2025 - Sep 30, 2025
            </span>
          </div>
        </header>

        {/* TOP ROW: Summary Cards & Trending Media */}
        <div className="grid grid-cols-1 lg:grid-cols-12 gap-6">
          {/* Summary Cards */}
          <div className="lg:col-span-7 grid grid-cols-1 sm:grid-cols-2 gap-4 md:gap-6">
            {summaryCards.map((card, idx) => (
              <article
                key={card.title}
                className="relative overflow-hidden rounded-2xl border border-foreground/10 bg-background/40 backdrop-blur-xl p-5 md:p-6 shadow-2xl flex flex-col justify-between h-[140px]"
              >
                {/* Subtle gradient overlay to mimic the image's colored cards, but keeping to the red theme */}
                <div
                  className="absolute inset-0 opacity-[0.03] pointer-events-none"
                  style={{
                    background: `linear-gradient(135deg, ${idx % 2 === 0 ? "#db0000" : "#831010"} 0%, transparent 100%)`,
                  }}
                />

                <div className="relative z-10 flex items-start justify-between gap-3">
                  <p className="text-sm font-medium text-foreground/70">
                    {card.title}
                  </p>
                  <div className="h-8 w-8 rounded-lg bg-brand-primary/10 text-brand-primary flex items-center justify-center">
                    <card.icon size={16} />
                  </div>
                </div>

                <div className="relative z-10 mt-auto">
                  <p className="text-2xl md:text-3xl font-bold text-foreground">
                    {card.value}
                  </p>
                  <p className="text-xs text-brand-muted mt-1 flex items-center gap-1">
                    <TrendingUp size={12} className="text-brand-primary" />
                    {card.growth}
                  </p>
                </div>
              </article>
            ))}
          </div>

          {/* Featured/Trending Media Panel */}
          <div className="lg:col-span-5 rounded-2xl border border-foreground/10 bg-background/40 backdrop-blur-xl p-6 shadow-2xl flex flex-col">
            <h2 className="text-base font-semibold text-foreground mb-4">
              Trending Episode
            </h2>
            <div className="relative flex-1 rounded-xl overflow-hidden bg-foreground/5 border border-foreground/10 group cursor-pointer min-h-[220px]">
              {/* Fallback pattern/gradient if no image */}
              <div className="absolute inset-0 bg-gradient-to-tr from-brand-deep to-background opacity-20" />

              <div className="absolute inset-0 flex flex-col items-center justify-center bg-black/20 transition-all group-hover:bg-black/40">
                <div className="h-16 w-16 rounded-full bg-brand-primary flex items-center justify-center shadow-[0_0_30px_rgba(219,0,0,0.4)] transition-transform group-hover:scale-110">
                  <Play
                    size={28}
                    className="text-white ml-1"
                    fill="currentColor"
                  />
                </div>
              </div>

              <div className="absolute bottom-0 left-0 right-0 p-4 bg-gradient-to-t from-background via-background/80 to-transparent">
                <span className="px-2 py-1 rounded text-[10px] uppercase tracking-wider font-bold bg-brand-primary text-white mb-2 inline-block">
                  Featured
                </span>
                <h3 className="text-lg font-bold text-foreground">
                  The Dark Horizon - S02 E04
                </h3>
                <p className="text-sm text-foreground/60 line-clamp-1 mt-1">
                  1.2M watching now • Sci-Fi Thriller
                </p>
              </div>
            </div>
          </div>
        </div>

        {/* MIDDLE ROW: Bar Chart & Donut Chart */}
        <div className="grid grid-cols-1 lg:grid-cols-12 gap-6">
          {/* Bar Chart Panel */}
          <article className="lg:col-span-8 rounded-2xl border border-foreground/10 bg-background/40 backdrop-blur-xl p-5 md:p-6 shadow-2xl">
            <div className="flex flex-col sm:flex-row sm:items-center justify-between mb-6 gap-4">
              <h2 className="text-base font-semibold text-foreground">
                Weekly Views Overview
              </h2>
              <div className="flex items-center gap-4 text-xs font-medium">
                <div className="flex items-center gap-1.5">
                  <span className="block w-3 h-3 rounded-sm bg-brand-primary"></span>
                  <span className="text-foreground/70">This week</span>
                </div>
                <div className="flex items-center gap-1.5">
                  <span className="block w-3 h-3 rounded-sm bg-brand-muted"></span>
                  <span className="text-foreground/70">Last week</span>
                </div>
              </div>
            </div>

            <div className="h-[300px] w-full">
              <ResponsiveContainer width="100%" height="100%">
                <BarChart
                  data={weeklyData}
                  margin={{ top: 10, right: 10, left: -20, bottom: 0 }}
                >
                  <CartesianGrid
                    strokeDasharray="3 3"
                    vertical={false}
                    stroke="var(--color-foreground)"
                    strokeOpacity={0.1}
                  />
                  <XAxis
                    dataKey="name"
                    axisLine={false}
                    tickLine={false}
                    tick={{ fill: "var(--color-muted)", fontSize: 12 }}
                    dy={10}
                  />
                  <YAxis
                    axisLine={false}
                    tickLine={false}
                    tick={{ fill: "var(--color-muted)", fontSize: 12 }}
                    tickFormatter={value => `${value}k`}
                  />
                  <Tooltip
                    content={<CustomTooltip />}
                    cursor={{ fill: "var(--color-foreground)", opacity: 0.05 }}
                  />
                  <Bar
                    dataKey="thisWeek"
                    fill="#6818a5"
                    radius={[4, 4, 0, 0]}
                    barSize={12}
                  />
                  <Bar
                    dataKey="lastWeek"
                    fill="#f2ebfb"
                    radius={[4, 4, 0, 0]}
                    barSize={12}
                  />
                </BarChart>
              </ResponsiveContainer>
            </div>
          </article>

          {/* Donut Chart Panel */}
          <article className="lg:col-span-4 rounded-2xl border border-foreground/10 bg-background/40 backdrop-blur-xl p-5 md:p-6 shadow-2xl flex flex-col">
            <div className="flex items-center justify-between mb-2">
              <h2 className="text-base font-semibold text-foreground">
                Content Distribution
              </h2>
              <select className="bg-background/50 border border-foreground/10 text-xs text-foreground/80 rounded-md px-2 py-1 outline-none">
                <option>This Week</option>
                <option>This Month</option>
              </select>
            </div>

            <div className="flex-1 flex flex-col justify-center relative min-h-[250px]">
              <ResponsiveContainer width="100%" height="100%">
                <PieChart>
                  <Pie
                    data={distributionData}
                    cx="50%"
                    cy="50%"
                    innerRadius={60}
                    outerRadius={90}
                    paddingAngle={5}
                    dataKey="value"
                    stroke="none"
                  >
                    {distributionData.map((entry, index) => (
                      <Cell
                        key={`cell-${index}`}
                        fill={COLORS[index % COLORS.length]}
                      />
                    ))}
                  </Pie>
                  <Tooltip content={<CustomTooltip />} />
                </PieChart>
              </ResponsiveContainer>

              <div className="mt-2 space-y-2 px-2">
                {distributionData.map((item, index) => (
                  <div
                    key={item.name}
                    className="flex items-center justify-between text-xs"
                  >
                    <div className="flex items-center gap-2">
                      <span
                        className="w-2.5 h-2.5 rounded-full"
                        style={{
                          backgroundColor: COLORS[index % COLORS.length],
                        }}
                      />
                      <span className="text-foreground/70">{item.name}</span>
                    </div>
                    <span className="font-semibold text-foreground">
                      {((item.value / 1000) * 100).toFixed(0)}%
                    </span>
                  </div>
                ))}
              </div>
            </div>
          </article>
        </div>

        {/* BOTTOM ROW: Area Chart */}
        <article className="rounded-2xl border border-foreground/10 bg-background/40 backdrop-blur-xl p-5 md:p-6 shadow-2xl">
          <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4 mb-6">
            <div>
              <h2 className="text-xs text-brand-muted uppercase tracking-wider font-medium">
                Statistics
              </h2>
              <h3 className="text-base font-semibold text-foreground mt-1">
                Earnings Summary
              </h3>
            </div>

            <div className="flex items-center gap-4">
              <div className="hidden md:flex items-center gap-4 text-xs font-medium mr-4">
                <div className="flex items-center gap-1.5">
                  <span className="block w-2 h-2 rounded-full bg-brand-primary"></span>
                  <span className="text-foreground/70">Subscriptions</span>
                </div>
                <div className="flex items-center gap-1.5">
                  <span className="block w-2 h-2 rounded-full bg-brand-deep"></span>
                  <span className="text-foreground/70">Ads Revenue</span>
                </div>
              </div>

              <div className="flex p-1 rounded-lg border border-foreground/10 bg-background/50 backdrop-blur-md">
                {["7 days", "30 days", "12 months"].map(filter => (
                  <button
                    key={filter}
                    onClick={() => setTimeFilter(filter)}
                    className={`px-3 py-1.5 text-xs font-medium rounded-md transition-colors ${
                      timeFilter === filter
                        ? "bg-foreground text-background"
                        : "text-foreground/70 hover:text-foreground hover:bg-foreground/5"
                    }`}
                  >
                    {filter}
                  </button>
                ))}
              </div>
            </div>
          </div>

          <div className="h-[300px] w-full">
            <ResponsiveContainer width="100%" height="100%">
              <AreaChart
                data={earningsData}
                margin={{ top: 10, right: 0, left: -20, bottom: 0 }}
              >
                <defs>
                  <linearGradient id="colorSub" x1="0" y1="0" x2="0" y2="1">
                    <stop offset="5%" stopColor="#6818a5" stopOpacity={0.3} />
                    <stop offset="95%" stopColor="#6818a5" stopOpacity={0} />
                  </linearGradient>
                  <linearGradient id="colorAds" x1="0" y1="0" x2="0" y2="1">
                    <stop offset="5%" stopColor="#6818a5" stopOpacity={0.3} />
                    <stop offset="95%" stopColor="#6818a5" stopOpacity={0} />
                  </linearGradient>
                </defs>
                <CartesianGrid
                  strokeDasharray="3 3"
                  vertical={false}
                  stroke="var(--color-foreground)"
                  strokeOpacity={0.05}
                />
                <XAxis
                  dataKey="name"
                  axisLine={false}
                  tickLine={false}
                  tick={{ fill: "var(--color-muted)", fontSize: 12 }}
                  dy={10}
                />
                <YAxis
                  axisLine={false}
                  tickLine={false}
                  tick={{ fill: "var(--color-muted)", fontSize: 12 }}
                  tickFormatter={value => `${value / 1000}M`}
                />
                <Tooltip content={<CustomTooltip />} />
                <Area
                  type="monotone"
                  dataKey="subscriptions"
                  stroke="#6818a5"
                  strokeWidth={3}
                  fillOpacity={1}
                  fill="url(#colorSub)"
                />
                <Area
                  type="monotone"
                  dataKey="ads"
                  stroke="#6818a5"
                  strokeWidth={3}
                  fillOpacity={1}
                  fill="url(#colorAds)"
                />
              </AreaChart>
            </ResponsiveContainer>
          </div>
        </article>
      </div>
    </div>
  );
};

export default DashboardPage;
