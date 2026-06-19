#!/bin/sh
set -e

# Copies the correct GoogleService-Info plist into the built app bundle
# Use PRODUCT_BUNDLE_IDENTIFIER to decide between dev and prod.

SRC_DIR="${PROJECT_DIR}/Runner"
TARGET="${BUILT_PRODUCTS_DIR}/${PRODUCT_NAME}.app/GoogleService-Info.plist"

echo "[copy_google_service_info] PRODUCT_BUNDLE_IDENTIFIER=$PRODUCT_BUNDLE_IDENTIFIER"

if [ -z "$PRODUCT_BUNDLE_IDENTIFIER" ]; then
  echo "[copy_google_service_info] PRODUCT_BUNDLE_IDENTIFIER is not set. Defaulting to prod plist."
  cp "${SRC_DIR}/GoogleService-Info-Prod.plist" "$TARGET"
  exit 0
fi

if echo "$PRODUCT_BUNDLE_IDENTIFIER" | grep -q "\.dev$"; then
  echo "[copy_google_service_info] Using Dev plist"
  cp "${SRC_DIR}/GoogleService-Info-Dev.plist" "$TARGET"
else
  echo "[copy_google_service_info] Using Prod plist"
  cp "${SRC_DIR}/GoogleService-Info-Prod.plist" "$TARGET"
fi
