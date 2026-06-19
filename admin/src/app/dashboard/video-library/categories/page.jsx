"use client";

import AdminSectionPage from "@/components/common/AdminSectionPage";
import { Plus, Search, Edit2, Trash2, X } from "lucide-react";
import React, { useState } from "react";

// Dummy Data for Categories
const dummyCategories = [
  {
    id: 1,
    name: "Action & Adventure",
    slug: "action-adventure",
    count: 42,
    status: "Active",
  },
  {
    id: 2,
    name: "Sci-Fi & Fantasy",
    slug: "sci-fi-fantasy",
    count: 28,
    status: "Active",
  },
  {
    id: 3,
    name: "Documentary",
    slug: "documentary",
    count: 15,
    status: "Active",
  },
  { id: 4, name: "Drama", slug: "drama", count: 56, status: "Inactive" },
];

export default function CategoriesPage() {
  const [isModalOpen, setIsModalOpen] = useState(false);

  return (
    <AdminSectionPage
      eyebrow="Library"
      title="Categories & Genres"
      description="Manage the classification tags used to organize content across the platform."
    >
      {/* Top Bar */}
      <div className="flex flex-col sm:flex-row items-center justify-between gap-4 mb-6 rounded-xl border border-foreground/10 bg-background/40 backdrop-blur-xl p-4 shadow-lg">
        <div className="relative w-full sm:w-96">
          <Search
            className="absolute left-3 top-1/2 -translate-y-1/2 text-foreground/50"
            size={18}
          />
          <input
            type="text"
            placeholder="Search categories..."
            className="w-full bg-foreground/5 border border-foreground/10 rounded-lg pl-10 pr-4 py-2 text-sm text-foreground focus:outline-none focus:border-brand-primary transition-colors"
          />
        </div>
        <button
          onClick={() => setIsModalOpen(true)}
          className="w-full sm:w-auto flex items-center justify-center gap-2 px-4 py-2 rounded-lg bg-brand-primary text-white text-sm font-medium hover:bg-brand-deep transition-all shadow-[0_0_15px_var(--color-brand-primary)] outline-none"
        >
          <Plus size={16} /> Add Category
        </button>
      </div>

      {/* Categories Table */}
      <div className="rounded-xl border border-foreground/10 bg-background/40 backdrop-blur-xl overflow-hidden shadow-2xl">
        <table className="w-full text-left text-sm text-foreground/80">
          <thead className="bg-foreground/5 border-b border-foreground/10 text-xs uppercase font-semibold text-foreground/60">
            <tr>
              <th className="px-6 py-4">Category Name</th>
              <th className="px-6 py-4">Slug</th>
              <th className="px-6 py-4">Content Count</th>
              <th className="px-6 py-4">Status</th>
              <th className="px-6 py-4 text-right">Actions</th>
            </tr>
          </thead>
          <tbody className="divide-y divide-foreground/10">
            {dummyCategories.map((cat) => (
              <tr
                key={cat.id}
                className="hover:bg-foreground/5 transition-colors group"
              >
                <td className="px-6 py-4 font-bold text-foreground">
                  {cat.name}
                </td>
                <td className="px-6 py-4 text-foreground/60 font-mono text-xs">
                  /{cat.slug}
                </td>
                <td className="px-6 py-4">
                  <span className="px-2 py-1 rounded bg-foreground/5 border border-foreground/10 text-xs font-medium">
                    {cat.count} items
                  </span>
                </td>
                <td className="px-6 py-4">
                  <span
                    className={`px-2 py-1 rounded text-[10px] font-bold uppercase tracking-wider ${
                      cat.status === "Active"
                        ? "bg-green-500/20 text-green-500"
                        : "bg-foreground/10 text-foreground/50"
                    }`}
                  >
                    {cat.status}
                  </span>
                </td>
                <td className="px-6 py-4 text-right">
                  <div className="flex items-center justify-end gap-2">
                    <button className="p-2 rounded hover:bg-foreground/10 text-foreground/60 hover:text-brand-primary transition-colors">
                      <Edit2 size={16} />
                    </button>
                    <button className="p-2 rounded hover:bg-brand-primary/10 text-foreground/60 hover:text-brand-primary transition-colors">
                      <Trash2 size={16} />
                    </button>
                  </div>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>

      {/* Add Category Modal */}
      {isModalOpen && (
        <div className="fixed inset-0 z-[999] flex items-center justify-center bg-black/60 backdrop-blur-sm p-4 animate-in fade-in duration-200">
          <div className="w-full max-w-md rounded-xl border border-brand-primary/20 bg-background p-6 shadow-[0_0_50px_rgba(0,0,0,0.5)]">
            <div className="flex justify-between items-center mb-6">
              <h3 className="text-lg font-bold text-foreground">
                Create New Category
              </h3>
              <button
                onClick={() => setIsModalOpen(false)}
                className="text-foreground/50 hover:text-foreground"
              >
                <X size={20} />
              </button>
            </div>

            <form
              className="space-y-4"
              onSubmit={(e) => {
                e.preventDefault();
                setIsModalOpen(false);
              }}
            >
              <div>
                <label className="text-xs font-semibold text-foreground/70 uppercase">
                  Category Name
                </label>
                <input
                  type="text"
                  className="w-full mt-1 bg-foreground/5 border border-foreground/10 rounded-lg px-4 py-2 text-sm text-foreground focus:border-brand-primary outline-none"
                  placeholder="e.g. Thriller"
                  required
                />
              </div>

              <div>
                <label className="text-xs font-semibold text-foreground/70 uppercase">
                  Slug (URL)
                </label>
                <input
                  type="text"
                  className="w-full mt-1 bg-foreground/5 border border-foreground/10 rounded-lg px-4 py-2 text-sm text-foreground focus:border-brand-primary outline-none"
                  placeholder="e.g. thriller"
                  required
                />
              </div>

              <div>
                <label className="text-xs font-semibold text-foreground/70 uppercase">
                  Status
                </label>
                <select className="w-full mt-1 bg-foreground/5 border border-foreground/10 rounded-lg px-4 py-2 text-sm text-foreground focus:border-brand-primary outline-none">
                  <option value="active">Active</option>
                  <option value="inactive">Inactive</option>
                </select>
              </div>

              <div className="mt-8 flex justify-end gap-3 pt-4 border-t border-foreground/10">
                <button
                  type="button"
                  onClick={() => setIsModalOpen(false)}
                  className="px-4 py-2 rounded-lg text-sm font-medium hover:bg-foreground/5 transition-colors"
                >
                  Cancel
                </button>
                <button
                  type="submit"
                  className="px-4 py-2 rounded-lg bg-brand-primary text-white text-sm font-semibold hover:bg-brand-deep transition-all shadow-[0_0_15px_var(--color-brand-primary)]"
                >
                  Save Category
                </button>
              </div>
            </form>
          </div>
        </div>
      )}
    </AdminSectionPage>
  );
}
