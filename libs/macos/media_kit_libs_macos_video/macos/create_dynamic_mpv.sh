#!/bin/bash

# Create a dynamic library wrapper for the static Mpv framework
# This allows media-kit to load mpv symbols at runtime

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FRAMEWORKS_DIR="$SCRIPT_DIR/Frameworks"
OUTPUT_DIR="$FRAMEWORKS_DIR/Mpv.framework"

if [ ! -d "$OUTPUT_DIR" ]; then
    echo "Error: Mpv.framework not found at $OUTPUT_DIR"
    exit 1
fi

# Get the path to the static library
STATIC_LIB="$OUTPUT_DIR/Mpv"

if [ ! -f "$STATIC_LIB" ]; then
    echo "Error: Static Mpv library not found at $STATIC_LIB"
    exit 1
fi

echo "Converting static Mpv framework to dynamic..."

# Create a temporary directory for the build
TMP_DIR=$(mktemp -d)
cd "$TMP_DIR"

# Create a simple C file that re-exports all mpv symbols
cat > mpv_wrapper.c << 'EOF'
// Dynamic wrapper for static Mpv framework
// Re-exports all mpv symbols for runtime loading

// This allows the static framework to be loaded dynamically by media-kit
__attribute__((visibility("default"))) void __mpv_dynamic_wrapper_init(void) {
    // Initialization function for the dynamic wrapper
}
EOF

# Extract object files from the static library
ar -x "$STATIC_LIB"

# Create a dynamic library from the object files
clang -shared -fPIC \
    -arch arm64 -arch x86_64 \
    -mmacosx-version-min=10.9 \
    -framework Foundation \
    -framework CoreFoundation \
    -framework CoreMedia \
    -framework VideoToolbox \
    -framework AudioToolbox \
    -install_name "@rpath/Mpv.framework/Mpv" \
    mpv_wrapper.c *.o \
    -o Mpv_dynamic

# Replace the static library with the dynamic one
mv Mpv_dynamic "$STATIC_LIB"

# Clean up
cd "$SCRIPT_DIR"
rm -rf "$TMP_DIR"

echo "Successfully converted Mpv framework to dynamic library"