#!/usr/bin/env bash

# Stop execution on errors
set -e

# Helper functions for output
log_error() { echo "❌ $1" >&2; exit 1; }
log_success() { echo "✅ $1"; }
log_info() { echo "ℹ️ $1"; }

# Input

TMP_DIR=$1
PREV_ABI_DUMP_PATH=$2
CURRENT_ABI_DUMP_PATH=$3
PREV_API_DUMP_PATH=$4
CURRENT_API_DUMP_PATH=$5
BUMP_TYPE=$6

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

report_has_breaking_changes() {
	local has_breaking_changes=1

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
				has_breaking_changes=0
            fi
        else
            log_error "Invalid output line: $line"
        fi
    done < $1

	return $has_breaking_changes
}

bump_type_from_report() {
    local abi_report_path=$1
	local api_report_path=$2
    local bump_type=$3
    local suitable_bump="patch"

	if report_has_breaking_changes $abi_report_path; then
		suitable_bump="minor"
	fi

	# TODO: api breakage does not work as intented
	# if report_has_breaking_changes $api_report_path; then
	# 	suitable_bump="major"
	# fi

    # Validate real and expected bump types
    weight_bump_type=$(get_priority "$bump_type")
    weight_suitable_bump=$(get_priority "$suitable_bump")
    if (( weight_bump_type < weight_suitable_bump )); then
        log_error "Wrong bump_type '$bump_type' specified. Suitable is '$suitable_bump'."
    else
        log_success "Suitable bump_type is '$suitable_bump', specified is '$bump_type'"
    fi
}

if [[ -f "$FILE_VAR" ]]; then
    echo "$FILE_VAR exists and is a regular file."
else
    echo "$FILE_VAR is not a regular file or does not exist."
fi

# Loading an old dump

# Prepare old dump (remove all "deprecated")
# log_info "Prepare old dump"
# old_prepared_path="$TMP_DIR/old-prepared.json"
# prepare_dump "$PREV_ABI_DUMP_PATH" "$old_prepared_path"
# log_success "Dump prepared"

# ABI compare
abi_report_path="$TMP_DIR/abi_breakage-report.log"
log_info "Comparing ABI..."

# WARNING: does not work for x86_64
set +e # Allow swift-api-digester to return a non-zero code
xcrun swift-api-digester \
    -diagnose-sdk \
    -input-paths "$PREV_ABI_DUMP_PATH" \
    -input-paths "$CURRENT_ABI_DUMP_PATH" \
    -disable-fail-on-error \
    -compiler-style-diags \
    -abi \
    -error-on-abi-breakage 2> "$abi_report_path"
set -e

# API compare
api_report_path="$TMP_DIR/api-breakage-report.log"
log_info "Comparing API..."

# WARNING: does not work for x86_64
set +e # Allow swift-api-digester to return a non-zero code
xcrun swift-api-digester \
    -diagnose-sdk \
    -input-paths "$PREV_API_DUMP_PATH" \
    -input-paths "$CURRENT_API_DUMP_PATH" \
    -disable-fail-on-error \
    -compiler-style-diags \
    -error-on-abi-breakage 2> "$api_report_path"
set -e

bump_type_from_report $abi_report_path $api_report_path $BUMP_TYPE
