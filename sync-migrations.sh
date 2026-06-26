#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# ---------------------------------------------------------------------------
# Add new services here.  Format: "project_dir|default_source_path"
#   project_dir      – the subdirectory inside shared-docker-compose/ that
#                     has a prisma/migrations/ folder to sync into
#   default_source_path – relative (or absolute) path to the source project
# ---------------------------------------------------------------------------
SERVICES=(
	"client|../client/"
	"fragment-composer|../fragment-composer/"
)

# ---------------------------------------------------------------------------
# Generate a regex that matches one or more space-separated indices
# ---------------------------------------------------------------------------
max_index=$((${#SERVICES[@]} - 1))
valid_range="[0-${max_index}]"

echo "Available projects:"
for i in "${!SERVICES[@]}"; do
	IFS='|' read -r name _ <<<"${SERVICES[$i]}"
	printf "  %d -> %s\n" "$i" "$name"
done
echo

# Keep asking until we get at least one valid selection
while true; do
	read -r -p "Project number(s) to sync (space-separated, e.g. 0 1): " raw_selection
	# Split input into an array
	read -ra selected <<<"$raw_selection"
	if [ ${#selected[@]} -eq 0 ]; then
		echo "No numbers entered – try again."
		continue
	fi
	valid=true
	for sel in "${selected[@]}"; do
		if ! [[ $sel =~ ^$valid_range$ ]]; then
			echo "  Invalid number: $sel (must be 0..$max_index)"
			valid=false
		fi
	done
	$valid && break
done

echo

# Gather source paths for the selected services
declare -a selected_names selected_sources
for sel in "${selected[@]}"; do
	IFS='|' read -r name default_source <<<"${SERVICES[$sel]}"
	read -r -p "Source path for \"$name\" [$default_source]: " custom_source
	selected_names+=("$name")
	selected_sources+=("${custom_source:-$default_source}")
done

echo
echo "=== Syncing migrations ==="
echo

for idx in "${!selected_names[@]}"; do
	name="${selected_names[$idx]}"
	source_path="${selected_sources[$idx]}"
	target_dir="${SCRIPT_DIR}/${name}/prisma/migrations"

	# Strip trailing slash for cleaner display
	source_path="${source_path%/}"

	if [ ! -d "$source_path/prisma/migrations" ]; then
		echo "  [SKIP] $name – no prisma/migrations/ found at $source_path"
		continue
	fi

	echo "  [SYNC] $name"
	echo "    from: $source_path/prisma/migrations/"
	echo "    to:   $target_dir"

	rm -rf "$target_dir"
	mkdir -p "$(dirname "$target_dir")"
	cp -r "$source_path/prisma/migrations/" "$target_dir"

	echo "    done"
	echo
done

echo "=== All done ==="
