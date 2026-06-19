"use client";

import { useEffect, useRef, useState } from "react";
import { useRouter } from "next/navigation";
import apiClient from "@/lib/api/client";

export default function CreateCoinPackageForm() {
  const router = useRouter();
  const formRef = useRef(null);
  const [showMsg, setShowMsg] = useState(false);
  const [isPending, setIsPending] = useState(false);
  const [state, setState] = useState(null);

  useEffect(() => {
    if (state?.message) {
      setShowMsg(true);

      const timer = setTimeout(() => setShowMsg(false), 3000);

      if (state.success) {
        formRef.current?.reset();
      }
      return () => clearTimeout(timer);
    }
  }, [state]);

  async function handleSubmit(event) {
    event.preventDefault();

    const formData = new FormData(event.currentTarget);
    const sortOrderRaw = formData.get("sort_order");
    const sortOrderTrimmed = String(sortOrderRaw ?? "").trim();
    const sortOrderProvided = sortOrderTrimmed.length > 0;

    const payload = {
      title: formData.get("title"),
      description: formData.get("description") || "",
      coins: parseInt(formData.get("coins"), 10),
      bonus_coins: parseInt(formData.get("bonus_coins"), 10) || 0,
      price_amount: parseFloat(formData.get("price_amount")),
      currency: "NPR",
      is_popular: formData.get("is_popular") === "on",
      sort_order: sortOrderProvided ? parseInt(sortOrderTrimmed, 10) : null,
      status: formData.get("status") || "active",
    };

    setIsPending(true);
    setState(null);

    try {
      await apiClient.post("/coin-packages/create", payload);
      router.refresh();
      setState({
        success: true,
        message: "Coin package created successfully!",
      });
      formRef.current?.reset();
    } catch (error) {
      const message = error?.message || "Unable to create coin package.";
      if (
        error?.code === "COIN_PACKAGE_SORT_ORDER_TAKEN" ||
        error?.status === 409
      ) {
        setState({
          success: false,
          message,
          fieldErrors: { sort_order: message },
        });
      } else {
        setState({ success: false, message });
      }
    } finally {
      setIsPending(false);
    }
  }

  return (
    <div className="rounded-lg border border-foreground/10 bg-background p-4 md:p-6">
      <h3 className="text-lg font-semibold mb-6">Create New Coin Package</h3>

      {showMsg && state?.message && (
        <div
          className={`mb-4 p-4 rounded-lg text-sm border transition-opacity duration-500 ${
            state.success
              ? "bg-green-50 text-green-700 border-green-200"
              : "bg-red-50 text-red-700 border-red-200"
          }`}
        >
          {state.message}
        </div>
      )}

      <form ref={formRef} onSubmit={handleSubmit} className="space-y-5">
        <div>
          <label className="block text-sm font-medium mb-1">Title *</label>
          <input
            name="title"
            type="text"
            required
            className="w-full px-3 py-2 rounded-lg border border-foreground/10 bg-background text-sm focus:ring-1 focus:ring-brand-primary outline-none"
          />
        </div>

        <div>
          <label className="block text-sm font-medium mb-1">Description</label>
          <textarea
            name="description"
            rows="2"
            className="w-full px-3 py-2 rounded-lg border border-foreground/10 bg-background text-sm focus:ring-1 focus:ring-brand-primary outline-none"
          />
        </div>

        <div className="grid grid-cols-1 sm:grid-cols-2 gap-4 md:gap-5">
          <div>
            <label className="block text-sm font-medium mb-1">Coins *</label>
            <input
              name="coins"
              type="number"
              required
              className="w-full px-3 py-2 rounded-lg border border-foreground/10 bg-background text-sm"
            />
          </div>
          <div>
            <label className="block text-sm font-medium mb-1">
              Bonus Coins
            </label>
            <input
              name="bonus_coins"
              type="number"
              defaultValue="0"
              className="w-full px-3 py-2 rounded-lg border border-foreground/10 bg-background text-sm"
            />
          </div>
        </div>

        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4 md:gap-5">
          <div>
            <label className="block text-sm font-medium mb-1">
              Price (NPR) *
            </label>
            <input
              name="price_amount"
              type="number"
              step="0.01"
              required
              className="w-full px-3 py-2 rounded-lg border border-foreground/10 bg-background text-sm"
            />
          </div>
          <div>
            <label className="block text-sm font-medium mb-1">Status</label>
            <select
              name="status"
              className="w-full px-3 py-2 rounded-lg border border-foreground/10 bg-background text-sm"
            >
              <option value="active">Active</option>
              <option value="inactive">Inactive</option>
            </select>
          </div>
          <div>
            <label className="block text-sm font-medium mb-1">Sort Order</label>
            <input
              name="sort_order"
              type="number"
              className="w-full px-3 py-2 rounded-lg border border-foreground/10 bg-background text-sm"
            />
            {state?.fieldErrors?.sort_order && (
              <p className="mt-1 text-xs text-red-600">
                {state.fieldErrors.sort_order}
              </p>
            )}
          </div>
        </div>

        <div className="flex items-center gap-3">
          <input
            type="checkbox"
            name="is_popular"
            id="is_popular"
            className="w-4 h-4 accent-brand-primary cursor-pointer"
          />
          <label
            htmlFor="is_popular"
            className="text-sm font-medium cursor-pointer"
          >
            Mark as Popular
          </label>
        </div>

        <div className="flex justify-start pt-2">
          <button
            type="submit"
            disabled={isPending}
            className="w-full sm:w-auto px-8 py-2.5 bg-brand-primary text-white font-semibold rounded-lg hover:bg-brand-deep disabled:opacity-50 transition-all shadow-md text-sm md:text-base"
          >
            {isPending ? "Connecting..." : "Create Coin Package"}
          </button>
        </div>
      </form>
    </div>
  );
}
