// RUN: %{ispc} %s --target=host --lto --emit-llvm-text -O2 -o - 2>&1 | FileCheck --check-prefixes=CHECK_ALL,CHECK_SPLIT1,CHECK_FULL %s
// RUN: %{ispc} %s --target=host --lto=full --emit-llvm-text -O2 -o - 2>&1 | FileCheck --check-prefixes=CHECK_ALL,CHECK_SPLIT1,CHECK_FULL %s
// RUN: %{ispc} %s --target=host --lto=thin --emit-llvm-text -O2 -o - 2>&1 | FileCheck --check-prefixes=CHECK_ALL,CHECK_SPLIT0,CHECK_THIN %s
// RUN: %{ispc} %s --target=host --lto=full --unified-lto --emit-llvm-text -O2 -o - 2>&1 | FileCheck --check-prefixes=CHECK_ALL,CHECK_SPLIT1,CHECK_UNIFIED %s
// RUN: %{ispc} %s --target=host --lto=thin --unified-lto --emit-llvm-text -O2 -o - 2>&1 | FileCheck --check-prefixes=CHECK_ALL,CHECK_SPLIT1,CHECK_UNIFIED %s
// RUN: %{ispc} %s --target=host --lto=none --emit-llvm-text -O2 -o - 2>&1 | FileCheck --check-prefixes=CHECK_NONE %s

// RUN: %{ispc} %s --target=host --unified-lto --emit-llvm-text -O2 -o - 2>&1 | FileCheck --check-prefixes=CHECK_OUTPUT_WARN1 %s
// RUN: %{ispc} %s --target=host --lto --emit-obj -O2 -o - 2>&1 | FileCheck --check-prefixes=CHECK_OUTPUT_WARN2 %s
void func0() {
}

void func1() {
}

// CHECK_ALL:          define void @func0__{{.*}}
// CHECK_ALL:          define void @func1__{{.*}}
// CHECK_NONE:         define void @func0__{{.*}}
// CHECK_NONE:         define void @func1__{{.*}}
// CHECK_UNIFIED:      !{{[0-9]+}} = !{i32 1, !"UnifiedLTO", i32 1}
// CHECK_FULL-NOT:     !{{[0-9]+}} = !{i32 1, !"UnifiedLTO", i32 1}
// CHECK_THIN-NOT:     !{{[0-9]+}} = !{i32 1, !"UnifiedLTO", i32 1}
// CHECK_SPLIT0:       !{{[0-9]+}} = !{i32 1, !"EnableSplitLTOUnit", i32 0}
// CHECK_SPLIT1:       !{{[0-9]+}} = !{i32 1, !"EnableSplitLTOUnit", i32 1}
// CHECK_FULL:         !{{[0-9]+}} = !{i32 1, !"ThinLTO", i32 0}
// CHECK_UNIFIED-NOT:  !{{[0-9]+}} = !{i32 1, !"ThinLTO", i32 0}
// CHECK_NONE-NOT:     !{{[0-9]+}} = !{i32 1, !"UnifiedLTO"
// CHECK_NONE-NOT:     !{{[0-9]+}} = !{i32 1, !"EnableSplitLTOUnit"
// CHECK_NONE-NOT:     !{{[0-9]+}} = !{i32 1, !"ThinLTO"

// CHECK_ALL:          ^{{[0-9]+}} = gv: (name: "func0___"
// CHECK_ALL:          ^{{[0-9]+}} = gv: (name: "func1___"

// CHECK_OUTPUT_WARN1: Requesting Unified LTO has no effect without also requesting LTO.
// CHECK_OUTPUT_WARN2: --emit-obj is ignored with LTO.
