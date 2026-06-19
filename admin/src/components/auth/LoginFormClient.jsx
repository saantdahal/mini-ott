"use client";

import React, { useEffect, useRef, useState, useCallback } from "react";
import Image from "next/image";
import { Eye, EyeOff } from "lucide-react";
import { useRouter } from "next/navigation";
import { useAuth } from "@/contexts/AuthContext";

const LoginFormClient = () => {
  const [showPassword, setShowPassword] = useState(false);
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [error, setError] = useState("");
  const router = useRouter();
  const abortControllerRef = useRef(null);
  const { login, isLoading } = useAuth();

  useEffect(() => {
    return () => {
      if (abortControllerRef.current) {
        abortControllerRef.current.abort();
      }
    };
  }, []);

  const handleSubmit = useCallback(
    async e => {
      e.preventDefault();
      setError("");

      const normalizedEmail = email.trim().toLowerCase();
      if (!normalizedEmail || !password) {
        setError("Email and password are required.");
        return;
      }

      abortControllerRef.current = new AbortController();

      try {
        await login(
          normalizedEmail,
          password,
          abortControllerRef.current.signal,
        );
        router.replace("/dashboard");
      } catch (submitError) {
        if (submitError?.name === "AbortError") {
          return;
        }

        setError(submitError?.message || "Unable to login right now.");
      }
    },
    [email, password, login, router],
  );

  return (
    <div className="min-h-screen w-full flex items-center justify-center bg-brand-deep/5 backdrop-blur-3xl p-4">
      <div className="bg-background w-full max-w-4xl rounded-lg shadow-2xl overflow-hidden flex flex-col md:flex-row border border-foreground/10 animate-in fade-in zoom-in duration-500">
        <div className="hidden md:flex w-1/2 bg-foreground/5 items-center justify-center p-8 relative border-r border-foreground/10">
          <div className="relative w-full aspect-square">
            <Image
              src="/form.jpg"
              alt="Login illustration"
              fill
              className="object-contain rounded-lg"
              priority
            />
          </div>
        </div>

        <div className="w-full md:w-1/2 p-8 md:p-12 flex flex-col justify-center">
          <div className="space-y-6">
            <div className="space-y-1">
              <h1 className="text-2xl font-bold tracking-tight text-foreground">
                Login to{" "}
                <span className="text-brand-primary font-extrabold">
                  Bytecode
                </span>
              </h1>
              <p className="text-brand-muted text-xs font-medium">
                Access your OTT administrative controls
              </p>
            </div>

            <form className="space-y-5" onSubmit={handleSubmit}>
              <div className="space-y-2">
                <label className="text-[10px] font-bold uppercase tracking-widest text-brand-muted ml-1">
                  Email Address
                </label>
                <input
                  type="email"
                  value={email}
                  onChange={e => setEmail(e.target.value)}
                  placeholder="admin@bytecode.com"
                  autoComplete="email"
                  disabled={isLoading}
                  className="w-full p-3 rounded-lg bg-foreground/5 border border-foreground/10 focus:border-brand-primary focus:ring-1 focus:ring-brand-primary outline-none transition-all placeholder:text-brand-muted/40 text-sm"
                />
              </div>

              <div className="space-y-2">
                <div className="flex justify-between items-center ml-1">
                  <label className="text-[10px] font-bold uppercase tracking-widest text-brand-muted">
                    Password
                  </label>
                  <button
                    type="button"
                    className="text-[10px] font-bold text-brand-primary hover:text-brand-deep transition-colors cursor-pointer"
                  >
                    Forgot password?
                  </button>
                </div>
                <div className="relative">
                  <input
                    type={showPassword ? "text" : "password"}
                    value={password}
                    onChange={e => setPassword(e.target.value)}
                    placeholder="••••••••••••"
                    autoComplete="current-password"
                    disabled={isLoading}
                    className="w-full p-3 rounded-lg bg-foreground/5 border border-foreground/10 focus:border-brand-primary focus:ring-1 focus:ring-brand-primary outline-none transition-all placeholder:text-brand-muted/40 text-sm pr-10"
                  />
                  <button
                    type="button"
                    onClick={() => setShowPassword(!showPassword)}
                    className="absolute right-3 top-1/2 -translate-y-1/2 text-brand-muted hover:text-foreground cursor-pointer transition-colors"
                  >
                    {showPassword ? <EyeOff size={18} /> : <Eye size={18} />}
                  </button>
                </div>
              </div>

              {error ? (
                <p
                  className="text-xs font-medium text-red-500"
                  role="alert"
                  aria-live="polite"
                >
                  {error}
                </p>
              ) : null}

              <button
                type="submit"
                disabled={isLoading}
                className="w-full bg-brand-primary text-foreground font-bold py-3 rounded-lg hover:bg-brand-deep hover:shadow-lg active:scale-[0.99] transition-all disabled:opacity-70 disabled:cursor-not-allowed text-sm"
              >
                {isLoading ? "LOGGING IN..." : "LOGIN"}
              </button>
            </form>

            <div className="text-center pt-2">
              <p className="text-xs text-brand-muted">
                Don't have an account?{" "}
                <button className="font-bold text-brand-primary hover:underline cursor-pointer">
                  Request access
                </button>
              </p>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
};

export default LoginFormClient;
