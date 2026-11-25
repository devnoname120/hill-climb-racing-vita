#!/bin/sh
set -eu

root=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
build="$root/build/host-tests"
cc=${CC:-clang}
cxx=${CXX:-clang++}
san="-fsanitize=address,undefined -fno-omit-frame-pointer"

mkdir -p "$build"

# The surrounding translator needs Vita headers; test its unmodified static helper on the host.
python3 "$root/tests/extract_glsl_swizzle_helper.py" \
    "$root/lib/vitagl/source/utils/glsl_utils.c" "$build/glsl_swizzle_impl.h"
"$cc" -std=c11 -Wall -Wextra -Werror $san -I"$build" \
    "$root/tests/glsl_swizzle_test.c" \
    -o "$build/glsl_swizzle_test"
ASAN_OPTIONS=abort_on_error=1 UBSAN_OPTIONS=halt_on_error=1 "$build/glsl_swizzle_test"

"$cc" -std=gnu11 -Wall -Wextra -Werror -Wno-unknown-pragmas -Wno-unused-parameter \
    -Wno-unused-function $san \
    -I"$root/lib" -I"$root/lib/falso_jni" -I"$root/source" \
    "$root/tests/java_bridge_test.c" -o "$build/java_bridge_test"
ASAN_OPTIONS=abort_on_error=1 UBSAN_OPTIONS=halt_on_error=1 "$build/java_bridge_test"

"$cc" -std=c11 -Wall -Wextra -Werror $san -I"$root/lib" -I"$root/lib/falso_jni" -pthread \
    "$root/tests/jni_refs_test.c" -o "$build/jni_refs_test"
ASAN_OPTIONS=abort_on_error=1 UBSAN_OPTIONS=halt_on_error=1 "$build/jni_refs_test"

"$cxx" -std=c++20 -Wall -Wextra -Werror $san -I"$root/lib" -I"$root/lib/falso_jni" -pthread \
    "$root/tests/preferences_ownership_test.cpp" -o "$build/preferences_ownership_test"
ASAN_OPTIONS=abort_on_error=1 UBSAN_OPTIONS=halt_on_error=1 "$build/preferences_ownership_test"

"$cxx" -std=c++17 -Wall -Wextra -Werror -Wno-unknown-pragmas $san \
    -I"$root/tests/stubs" -I"$root/lib" -I"$root/lib/falso_jni" -pthread \
    "$root/tests/audio_lifetime_test.cpp" -o "$build/audio_lifetime_test"
ASAN_OPTIONS=abort_on_error=1 UBSAN_OPTIONS=halt_on_error=1 "$build/audio_lifetime_test"

python3 "$root/tests/test_render_lifecycle.py"

if [ "$#" -gt 0 ]; then
    python3 "$root/tests/check_package.py" "$1"
fi
