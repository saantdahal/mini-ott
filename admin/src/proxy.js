import { NextResponse } from "next/server";
import { verifyToken } from "@/services/auth/verifyToken";

export async function proxy(request) {
  const token = request.cookies.get("admin_access_token")?.value;

  if (!token) {
    return NextResponse.redirect(new URL("/", request.url));
  }

  const payload = await verifyToken(token);

  if (!payload || payload.role !== "admin") {
    return NextResponse.redirect(new URL("/", request.url));
  }

  return NextResponse.next();
}

export const config = {
  matcher: ["/dashboard/:path*"],
};
