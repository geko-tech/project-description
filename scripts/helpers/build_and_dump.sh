#!/usr/bin/env bash

# Stop execution on errors
set -e

# Helper functions for output
log_error() { echo "❌ $1" >&2; exit 1; }

# Input
tmp_dir=$1
tmp_build_dir="$tmp_dir/build"
module_name="ProjectDescription"
configuration="Release"
framework_path="${tmp_build_dir}/${configuration}"
output_path="$tmp_dir/current-abi.json"

xcrun xcodebuild -scheme ProjectDescription \
    -configuration "$configuration" \
    -destination "generic/platform=macOS" \
    BUILD_LIBRARY_FOR_DISTRIBUTION=YES \
    ARCHS='arm64 x86_64' \
    BUILD_DIR=$tmp_build_dir \
    clean build > /dev/null

sdk_path=$(xcodebuild -showsdks -json | jq -r '.[] | select(.platform == "macosx" and .isBaseSdk == true) | .sdkPath' | head -n 1)
if [ -z "$sdk_path" ]; then log_error "SDK not found for platform 'macosx'"; fi

xcrun swift-api-digester \
        -dump-sdk \
        -abort-on-module-fail \
        -module "$module_name" \
        -use-interface-for-module "$module_name" \
        -F "$framework_path" \
        -I "$framework_path" \
        -avoid-tool-args \
        -avoid-location \
        -abi \
        -sdk "$sdk_path" \
        -target "arm64-apple-macos" \
        -o "$output_path"

echo $output_path