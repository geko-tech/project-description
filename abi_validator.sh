#!/bin/bash

# Stop execution on errors
set -e

# Helper functions for output
log_error() { echo "❌ $1" >&2; exit 1; }
log_success() { echo "✅ $1"; }
log_info() { echo "ℹ️ $1"; }

# Input
ABI_URL="https://github.com/Vinogradov7511339/ProjectDescription/releases/download"

PROJECT_DESCRIPTION_ABI_URL="${ABI_URL}"
NEW_BUMP_TYPE=""
if [[ $INPUT_TITLE =~ \[(.*)\] ]]; then
    NEW_BUMP_TYPE="${BASH_REMATCH[1]}"
else
    log_error "Bump type not found"
fi

# A function for removing keys from JSON
prepare_dump() {
    local input_path=$1
    local output_path=$2
    # Using jq to recursively remove the "deprecated" key
    jq 'walk(if type == "object" then del(.deprecated) else . end)' "$input_path" > "$output_path"
}

abi_dump() {
    local module_name=$1
    local output_path=$2
    local framework_path=$3
    
    # Finding the SDK path via xcodebuild
    local sdk_path=$(xcodebuild -showsdks -json | jq -r '.[] | select(.platform == "macosx" and .isBaseSdk == true) | .sdkPath' | head -n 1)
    
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
}

bump_type_from_report() {
    local report_path=$1
    local bump_type=$2
    local suitable_bump="patch"

    while IFS= read -r line; do
        # Skip system messages
        [[ $line =~ ^[0-9]+\ (error|warning)s?\ generated\. ]] && continue
        [[ $line =~ xcodebuild\[.*\]\ Requested\ but\ did\ not\ find\ extension\ point ]] && continue
        [[ -z "$line" ]] && continue

        # Parse: <file>:<line>: <type>: <message>
        if [[ $line =~ :([0-9]+):\ (error|warning):\ (.+)$ ]]; then
            local type="${BASH_REMATCH[2]}"
            local message="${BASH_REMATCH[3]}"

            if [[ "$type" == "warning" ]]; then
                echo "⚠️  $message"
            elif [[ "$type" == "error" ]]; then
                echo "⛔️ $message"
                suitable_bump="minor"
            fi
        else
            log_error "Invalid output line: $line"
        fi
    done < $report_path

    # Validate real and expected bump types
    weights=("patch" "minor" "major")
    log_info "suitable_bump $suitable_bump"
    if [ ${weights[$bump_type]} <= ${weights[$suitable_bump]} ]; then
        log_error "Wrong bump_type '$bump_type' specified. Suitable is '$suitable_bump'."
    else
        log_success "Suitable bump_type is '$suitable_bump', specified is '$bump_type'"
    fi
}

check_abi_stability() {
    local bump_type=$1
    local version=$2
    
    local tmp_dir=$(mktemp -d)
    local tmp_build_dir="$tmp_dir/build"
    local configuration="Release"
    
    log_info "Building ProjectDescription..."
    xcrun xcodebuild -scheme ProjectDescription \
        -configuration "Release" \
        -destination "generic/platform=macOS" \
        BUILD_LIBRARY_FOR_DISTRIBUTION=YES \
        ARCHS='arm64 x86_64' \
        BUILD_DIR=$tmp_build_dir \
        clean build > /dev/null
    log_success "BUILD SUCCEEDED"

    # Loading an old dump
    local old_abi_dump_path="$tmp_dir/old-abi.json"
    local url="${PROJECT_DESCRIPTION_ABI_URL}/${version}/current-abi.json"
    
    log_info "Downloading old ABI dump..."
    local code=$(curl -L -s -w "%{http_code}" "$url" -o "$old_abi_dump_path")
    if [ "$code" != "200" ]; then
        log_error "Failed to download API dumps. URL: $url (Status: $code)"
    fi

    # Creating a dump of the current state
    log_info "Creating a dump of the current state"
    local current_abi_dump_path="$tmp_dir/current-abi.json"
    abi_dump "ProjectDescription" "$current_abi_dump_path" "${tmp_build_dir}/${configuration}"
    log_success "Dump created"

    # Prepare old dump (remove all "deprecated")
    log_info "Prepare old dump"
    local old_prepared_path="$tmp_dir/old-prepared.json"
    prepare_dump "$old_abi_dump_path" "$old_prepared_path"
    log_success "Dump prepeared"

    # ABI compare
    local report_path="$tmp_dir/breakage-report.log"
    log_info "Comparing ABI..."

    # WARNING: not work on x86_64
    set +e # Allow swift-api-digester to return a non-zero code
    xcrun swift-api-digester \
        -diagnose-sdk \
        -input-paths "$old_prepared_path" \
        -input-paths "$current_abi_dump_path" \
        -disable-fail-on-error \
        -compiler-style-diags \
        -abi \
        -error-on-abi-breakage 2> "$report_path"
    set -e

    # Determining the real bump type
    bump_type_from_report $report_path $bump_type
    log_success "Finish"
}


check_abi_stability $NEW_BUMP_TYPE $LATEST_VERSION
