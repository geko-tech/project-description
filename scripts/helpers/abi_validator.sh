#!/bin/bash

# Stop execution on errors
set -e

# Helper functions for output
log_error() { echo "❌ $1" >&2; exit 1; }
log_success() { echo "✅ $1"; }
log_info() { echo "ℹ️ $1"; }

# Input
ABI_URL="https://github.com/geko-tech/ProjectDescription/releases/download"

NEW_BUMP_TYPE=$1
LATEST_VERSION=$2
PROJECT_DESCRIPTION_ABI_URL="${ABI_URL}"

# A function for removing keys from JSON
prepare_dump() {
    local input_path=$1
    local output_path=$2
    # Using jq to recursively remove the "deprecated" key
    jq 'walk(if type == "object" then del(.deprecated) else . end)' "$input_path" > "$output_path"
}

get_priority() {
    case "$1" in
        major) echo 3 ;;
        minor) echo 2 ;;
        patch) echo 1 ;;
        *)     echo 0 ;;
    esac
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

check_abi_stability() {
    local bump_type=$1
    local version=$2
    
    local tmp_dir=$(mktemp -d)
    
    log_info "Building ProjectDescription..."
    local current_abi_dump_path=$(./scripts/helpers/build_and_dump.sh $tmp_dir)
    log_success "BUILD SUCCEEDED $current_abi_dump_path"

    # Loading an old dump
    local old_abi_dump_path="$tmp_dir/old-abi.json"
    local url="${PROJECT_DESCRIPTION_ABI_URL}/${version}/current-abi.json"
    
    log_info "Downloading old ABI dump..."
    local code=$(curl -L -s -w "%{http_code}" "$url" -o "$old_abi_dump_path")
    if [ "$code" != "200" ]; then
        log_error "Failed to download API dumps. URL: $url (Status: $code)"
    fi

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
}


check_abi_stability $NEW_BUMP_TYPE $LATEST_VERSION
