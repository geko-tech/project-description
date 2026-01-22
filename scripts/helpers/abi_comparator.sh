#!/usr/bin/env bash

# Stop execution on errors
set -e

# Helper functions for output
log_error() { echo "❌ $1" >&2; exit 1; }
log_success() { echo "✅ $1"; }
log_info() { echo "ℹ️ $1"; }

# Input

ABI_URL="https://github.com/geko-tech/ProjectDescription/releases/download"
PROJECT_DESCRIPTION_ABI_URL="${ABI_URL}"

TMP_DIR=$1
LATEST_VERSION=$2
CURRENT_ABI_DUMP_PATH=$3
BUMP_TYPE=$4


get_priority() {
    case "$1" in
        major) echo 3 ;;
        minor) echo 2 ;;
        patch) echo 1 ;;
        *)     echo 0 ;;
    esac
}

# A function for removing keys from JSON
prepare_dump() {
    local input_path=$1
    local output_path=$2
    # Using jq to recursively remove the "deprecated" key
    jq 'walk(if type == "object" then del(.deprecated) else . end)' "$input_path" > "$output_path"
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
    weight_bump_type=$(get_priority "$bump_type")
    weight_suitable_bump=$(get_priority "$suitable_bump")
    if (( weight_bump_type < weight_suitable_bump )); then
        log_error "Wrong bump_type '$bump_type' specified. Suitable is '$suitable_bump'."
    else
        log_success "Suitable bump_type is '$suitable_bump', specified is '$bump_type'"
    fi
}

# Loading an old dump
old_abi_dump_path="$TMP_DIR/old-abi.json"
url="${PROJECT_DESCRIPTION_ABI_URL}/${LATEST_VERSION}/current-abi.json"

log_info "Downloading old ABI dump..."
code=$(curl -L -s -w "%{http_code}" "$url" -o "$old_abi_dump_path")
if [ "$code" != "200" ]; then
    log_error "Failed to download API dumps. URL: $url (Status: $code)"
fi

# Prepare old dump (remove all "deprecated")
log_info "Prepare old dump"
old_prepared_path="$TMP_DIR/old-prepared.json"
prepare_dump "$old_abi_dump_path" "$old_prepared_path"
log_success "Dump prepared"

# ABI compare
report_path="$TMP_DIR/breakage-report.log"
log_info "Comparing ABI..."

# WARNING: not work on x86_64
set +e # Allow swift-api-digester to return a non-zero code
xcrun swift-api-digester \
    -diagnose-sdk \
    -input-paths "$old_prepared_path" \
    -input-paths "$CURRENT_ABI_DUMP_PATH" \
    -disable-fail-on-error \
    -compiler-style-diags \
    -abi \
    -error-on-abi-breakage 2> "$report_path"
set -e

bump_type_from_report $report_path $BUMP_TYPE
