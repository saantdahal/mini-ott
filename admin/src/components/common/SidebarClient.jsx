"use client";

import Link from "next/link";
import { usePathname, useRouter } from "next/navigation";
import React, { useEffect, useState } from "react";
import {
  LayoutDashboard,
  Video,
  Radio,
  Coins,
  Users,
  Settings,
  ChevronDown,
  ChevronRight,
  ChevronLeft,
  LogOut,
  History,
} from "lucide-react";
import { useAuth } from "@/contexts/AuthContext";
import Image from "next/image";

const SidebarClient = ({ initialAdminName = "Admin" }) => {
  const pathname = usePathname();
  const router = useRouter();
  const { logout } = useAuth();
  const [isExpanded, setIsExpanded] = useState(true);

  // Controls the accordion - keeps track of the currently open string
  const [openDropdown, setOpenDropdown] = useState(null);

  const [showLogoutConfirm, setShowLogoutConfirm] = useState(false);
  const [adminName] = useState(initialAdminName || "Admin");

  const handleLogout = async () => {
    await logout();
    router.replace("/");
    router.refresh();
  };

  const openLogoutConfirm = () => setShowLogoutConfirm(true);
  const closeLogoutConfirm = () => setShowLogoutConfirm(false);

  const confirmLogout = async () => {
    setShowLogoutConfirm(false);
    await handleLogout();
  };

  const toggleDropdown = (label) => {
    if (!isExpanded) {
      setIsExpanded(true);
      setOpenDropdown(label);
    } else {
      // If clicking the currently open one, close it. Otherwise, open the new one (closes old).
      setOpenDropdown(openDropdown === label ? null : label);
    }
  };

  const menuItems = [
    { icon: LayoutDashboard, label: "Dashboard", href: "/dashboard" },
    {
      icon: Video,
      label: "Video Library",
      href: "/dashboard/video-library/all-content",
      children: [
        { label: "All Content", href: "/dashboard/video-library" },
        { label: "Add Content", href: "/dashboard/video-library/new" },
        { label: "Categories", href: "/dashboard/video-library/categories" },
      ],
    },
    {
      icon: Radio,
      label: "Live & Voting",
      href: "/dashboard/live-voting/active-sessions",
      children: [
        {
          label: "Active Sessions",
          href: "/dashboard/live-voting/active-sessions",
        },
        { label: "Poll Results", href: "/dashboard/live-voting/poll-results" },
      ],
    },
    {
      icon: Coins,
      label: "Coin System",
      href: "/dashboard/coin-system/coin-management",
      children: [
        {
          label: "Coin Management",
          href: "/dashboard/coin-system/coin-management",
        },
      ],
    },
    {
      icon: Users,
      label: "User Management",
      href: "/dashboard/user-management",
    },
    { icon: History, label: "System Logs", href: "/dashboard/system-logs" },
  ];

  // Logic to determine if parent row should be highlighted
  const isItemActive = (item) => {
    if (pathname === item.href) return true;
    if (
      item.children?.some(
        (child) =>
          pathname === child.href || pathname.startsWith(`${child.href}/`),
      )
    )
      return true;
    if (item.href !== "/dashboard" && pathname.startsWith(`${item.href}/`))
      return true;
    return false;
  };

  // Open the correct dropdown on initial load based on URL
  useEffect(() => {
    const activeParent = menuItems.find((item) =>
      item.children?.some(
        (child) =>
          pathname === child.href || pathname.startsWith(`${child.href}/`),
      ),
    );
    if (activeParent) {
      setOpenDropdown(activeParent.label);
    }
  }, [pathname]);

  return (
    <aside
      className={`h-screen p-4 flex flex-col transition-[width] duration-300 ease-in-out ${
        isExpanded ? "w-72" : "w-24"
      }`}
    >
      <div className="bg-background border border-foreground/10 rounded-xl flex flex-col h-full shadow-2xl relative overflow-x-hidden">
        {/* Header / Logo */}
        <div
          className={`py-6 px-4 flex ${isExpanded ? "flex-row justify-between items-center" : "flex-col items-center gap-4"} border-b border-foreground/5 mb-4`}
        >
          <Link href="/dashboard" className="flex items-center cursor-pointer">
            <div className=" rounded-lg border-2 border-brand-primary flex items-center justify-center font-bold text-xl text-brand-primary shadow-[0_0_15px_var(--color-brand-primary)]">
              <Image
                src="/logo.png"
                alt="Logo"
                width={40}
                height={40}
                className="rounded-2xl"
              />
            </div>
            {isExpanded && (
              <span className="ml-3 font-bold text-xl tracking-tighter text-foreground cursor-pointer animate-in fade-in slide-in-from-left-2 duration-300">
                DSM
                <span className="text-brand-primary text-2xl font-black">
                  Tv
                </span>
              </span>
            )}
          </Link>

          <button
            onClick={() => setIsExpanded(!isExpanded)}
            className="p-2 bg-foreground/5 hover:bg-foreground/10 rounded-lg text-brand-muted hover:text-foreground transition-colors cursor-pointer border border-foreground/5"
          >
            {isExpanded ? (
              <ChevronLeft size={18} />
            ) : (
              <ChevronRight size={18} />
            )}
          </button>
        </div>

        {/* Navigation Area */}
        <nav className="flex-1 px-3 space-y-2 overflow-y-auto overflow-x-hidden custom-scrollbar">
          {menuItems.map((item, idx) => {
            const active = isItemActive(item);

            return (
              <div key={idx} className="flex flex-col relative group">
                {/* Parent Row Container (Ensures full row highlight) */}
                <div
                  className={`w-full flex items-stretch justify-between rounded-lg transition-colors overflow-hidden ${
                    active
                      ? "bg-brand-primary/10 text-brand-primary"
                      : "text-foreground/60 hover:bg-foreground/5 hover:text-foreground"
                  }`}
                >
                  {/* The actual Link spans the whole remaining area with p-3 */}
                  <Link
                    href={item.children ? item.children[0].href : item.href}
                    onClick={() => {
                      if (!isExpanded) setIsExpanded(true);
                      if (item.children) {
                        setOpenDropdown(item.label);
                      }
                    }}
                    className="flex items-center gap-4 flex-1 min-w-0 p-3 outline-none"
                  >
                    <item.icon size={22} className="min-w-5.5" />
                    {isExpanded && (
                      <span className="font-semibold text-sm cursor-pointer whitespace-nowrap truncate">
                        {item.label}
                      </span>
                    )}
                  </Link>

                  {/* Dropdown Toggle Chevron */}
                  {isExpanded && item.children && (
                    <button
                      onClick={e => {
                        e.preventDefault(); // Prevents navigating when just toggling
                        toggleDropdown(item.label);
                      }}
                      className="px-3 hover:bg-foreground/10 transition-colors flex items-center justify-center outline-none"
                    >
                      <div className="transition-transform duration-200">
                        {openDropdown === item.label ? (
                          <ChevronDown size={16} />
                        ) : (
                          <ChevronRight size={16} />
                        )}
                      </div>
                    </button>
                  )}

                  {/* Collapsed Tooltip */}
                  {!isExpanded && (
                    <span className="absolute left-full ml-6 px-3 py-2 bg-foreground text-background text-[10px] font-bold rounded-lg invisible opacity-0 -translate-x-3 transition-all group-hover:visible group-hover:opacity-100 group-hover:translate-x-0 z-[100] whitespace-nowrap shadow-xl uppercase tracking-widest pointer-events-none">
                      {item.label}
                    </span>
                  )}
                </div>

                {/* Sub-menu Dropdown */}
                {isExpanded && item.children && openDropdown === item.label && (
                  <div className="ml-[22px] pl-4 mt-2 mb-2 space-y-1 relative before:absolute before:left-0 before:top-1 before:bottom-1 before:w-[1px] before:bg-foreground/10 animate-in slide-in-from-top-2 duration-200">
                    {item.children.map((child, cIdx) => {
                      // Check exact match, except handle root paths differently to avoid highlighting multiple
                      const activeChild =
                        pathname === child.href ||
                        (child.href !== item.href &&
                          pathname.startsWith(`${child.href}/`));

                      return (
                        <Link
                          key={cIdx}
                          href={child.href}
                          className={`block w-full text-left p-2.5 text-xs font-medium rounded-lg transition-colors cursor-pointer relative outline-none ${
                            activeChild
                              ? "text-brand-primary bg-brand-primary/5 font-bold"
                              : "text-foreground/50 hover:text-brand-primary hover:bg-foreground/5"
                          }`}
                        >
                          {/* Active Pip Indicator */}
                          {activeChild && (
                            <span className="absolute -left-[17px] top-1/2 -translate-y-1/2 w-1 h-1 bg-brand-primary rounded-full shadow-[0_0_5px_var(--color-brand-primary)]" />
                          )}
                          {child.label}
                        </Link>
                      );
                    })}
                  </div>
                )}
              </div>
            );
          })}
        </nav>

        {/* Footer Area */}
        <div className="p-3 mt-auto border-t border-foreground/5 space-y-2 overflow-x-hidden">
          {/* Settings Link */}
          <Link
            href="/settings"
            className={`w-full flex items-center gap-4 p-3 transition-colors rounded-lg cursor-pointer group relative outline-none ${
              pathname === "/settings"
                ? "text-brand-primary bg-brand-primary/10"
                : "text-foreground/60 hover:bg-foreground/5 hover:text-foreground"
            }`}
          >
            <Settings size={22} className="min-w-5.5" />
            {isExpanded && (
              <span className="font-semibold text-sm">Settings</span>
            )}

            {!isExpanded && (
              <span className="absolute left-full ml-6 px-3 py-2 bg-foreground text-background text-[10px] font-bold rounded-lg invisible opacity-0 -translate-x-3 transition-all group-hover:visible group-hover:opacity-100 group-hover:translate-x-0 z-[100] whitespace-nowrap uppercase tracking-widest pointer-events-none">
                Settings
              </span>
            )}
          </Link>

          {/* User Profile / Logout */}
          <div
            className={`bg-foreground/5 rounded-lg transition-all duration-300 ${isExpanded ? "p-3" : "p-2 flex justify-center items-center"} group relative`}
          >
            <div
              className={`flex items-center ${isExpanded ? "justify-between w-full" : "justify-center"}`}
            >
              <div className="flex items-center gap-3">
                <div className="min-w-9 h-9 rounded-lg bg-brand-deep flex items-center justify-center text-white font-bold text-xs border border-white/10 shrink-0">
                  <Users size={18} />
                </div>
                {isExpanded && (
                  <div className="flex flex-col truncate animate-in fade-in duration-300">
                    <span className="text-xs font-bold text-foreground truncate w-24">
                      {adminName}
                    </span>
                    <span className="text-[10px] text-brand-muted uppercase font-bold tracking-tighter">
                      Admin
                    </span>
                  </div>
                )}
              </div>

              {isExpanded && (
                <button
                  onClick={openLogoutConfirm}
                  className="p-2 bg-brand-primary/10 text-brand-primary rounded-lg hover:bg-brand-primary hover:text-white transition-colors cursor-pointer outline-none"
                >
                  <LogOut size={16} />
                </button>
              )}
            </div>

            {!isExpanded && (
              <span className="absolute left-full ml-6 px-3 py-2 bg-foreground text-background text-[10px] font-bold rounded-lg invisible opacity-0 -translate-x-3 transition-all group-hover:visible group-hover:opacity-100 group-hover:translate-x-0 z-[100] whitespace-nowrap shadow-xl uppercase tracking-widest pointer-events-none">
                {adminName} (Logout)
              </span>
            )}
          </div>
        </div>
      </div>

      {/* Logout Confirmation Modal */}
      {showLogoutConfirm && (
        <div className="fixed inset-0 z-[999] flex items-center justify-center bg-black/60 backdrop-blur-sm p-4 animate-in fade-in duration-200">
          <div className="w-full max-w-sm rounded-xl border border-brand-primary/20 bg-background/95 p-6 shadow-[0_0_50px_rgba(0,0,0,0.5)]">
            <h3 className="text-lg font-bold text-foreground">Sign Out</h3>
            <p className="mt-2 text-sm text-foreground/70">
              Are you sure you want to end your session?
            </p>

            <div className="mt-6 flex items-center justify-end gap-3">
              <button
                type="button"
                onClick={closeLogoutConfirm}
                className="px-4 py-2 rounded-lg border border-foreground/10 text-sm font-medium text-foreground hover:bg-foreground/5 transition-colors outline-none"
              >
                Cancel
              </button>
              <button
                type="button"
                onClick={confirmLogout}
                className="px-4 py-2 rounded-lg bg-brand-primary text-white text-sm font-semibold hover:bg-brand-deep transition-all shadow-[0_0_15px_var(--color-brand-primary)] outline-none"
              >
                Sign Out
              </button>
            </div>
          </div>
        </div>
      )}
    </aside>
  );
};

export default SidebarClient;
