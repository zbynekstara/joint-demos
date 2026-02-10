#!/usr/bin/env bash
set -euo pipefail

SITE_DIR="_site"
FAILED=()
BUILT=()
SKIPPED=()

rm -rf "$SITE_DIR"
mkdir -p "$SITE_DIR"

for demo_dir in */; do
    demo_name="${demo_dir%/}"

    # Skip dotfiles, _site, and node_modules
    case "$demo_name" in
        .* | _site | node_modules) continue ;;
    esac

    # Pick version: ts/ preferred, then js/, then react-ts/, else skip
    if [[ -d "$demo_dir/ts" ]]; then
        build_dir="$demo_dir/ts"
    elif [[ -d "$demo_dir/js" ]]; then
        build_dir="$demo_dir/js"
    elif [[ -d "$demo_dir/vue-ts" ]]; then
        build_dir="$demo_dir/vue-ts"
    else
        echo ":: Skipping $demo_name (no ts/, js/, or vue-ts/ subdirectory)"
        SKIPPED+=("$demo_name")
        continue
    fi

    # Detect build tool and set flags for relative asset paths
    build_flags="--mode=production"
    if grep -q '"vite build"' "$build_dir/package.json" 2>/dev/null; then
        build_flags="--base=./ --mode=production"
    fi

    echo ":: Building $demo_name from $build_dir ($build_flags)"

    if (
        cd "$build_dir"
        npm install --ignore-scripts=false
        npm run build -- $build_flags
    ); then
        if [[ -d "$build_dir/dist" ]]; then
            cp -r "$build_dir/dist/." "$SITE_DIR/$demo_name/"
            BUILT+=("$demo_name")
            echo ":: Done $demo_name"
        else
            echo ":: WARNING: $demo_name built but no dist/ found"
            FAILED+=("$demo_name")
        fi
    else
        echo ":: WARNING: $demo_name build failed, continuing..."
        FAILED+=("$demo_name")
    fi
done

echo ""
echo "=== Build summary ==="
echo "Built: ${#BUILT[@]} demos"
if [[ ${#FAILED[@]} -gt 0 ]]; then
    echo "Failed: ${#FAILED[@]} demos: ${FAILED[*]}"
else
    echo "Failed: 0"
fi
if [[ ${#SKIPPED[@]} -gt 0 ]]; then
    echo "Skipped: ${#SKIPPED[@]} demos: ${SKIPPED[*]}"
else
    echo "Skipped: 0"
fi
