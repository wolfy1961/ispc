// Verifies that pre/post decrement of varying unsigned integers (all widths)
// emits a subtract-by-1 constant, not a no-op (zeroinitializer). See issue #3882:
// unsigned decrement was silently miscompiled into `v + 0` due to UB in a
// negative-double-to-unsigned-integer cast.
// RUN: %{ispc} %s --target=host --nostdlib --nowrap --emit-llvm-text -o - | FileCheck %s

// CHECK-LABEL: @u8_predec___
// CHECK-NOT: zeroinitializer
// CHECK: add <[[WIDTH:.*]] x i8> {{.*}}, splat (i8 -1)
void u8_predec(unsigned int8 v[]) {
    unsigned int8 x = v[programIndex];
    --x;
    v[programIndex] = x;
}

// CHECK-LABEL: @u8_postdec___
// CHECK-NOT: zeroinitializer
// CHECK: add <[[WIDTH]] x i8> {{.*}}, splat (i8 -1)
void u8_postdec(unsigned int8 v[]) {
    unsigned int8 x = v[programIndex];
    x--;
    v[programIndex] = x;
}

// CHECK-LABEL: @u16_predec___
// CHECK-NOT: zeroinitializer
// CHECK: add <[[WIDTH]] x i16> {{.*}}, splat (i16 -1)
void u16_predec(unsigned int16 v[]) {
    unsigned int16 x = v[programIndex];
    --x;
    v[programIndex] = x;
}

// CHECK-LABEL: @u32_predec___
// CHECK-NOT: zeroinitializer
// CHECK: add <[[WIDTH]] x i32> {{.*}}, splat (i32 -1)
void u32_predec(unsigned int32 v[]) {
    unsigned int32 x = v[programIndex];
    --x;
    v[programIndex] = x;
}

// CHECK-LABEL: @u64_predec___
// CHECK-NOT: zeroinitializer
// CHECK: add <[[WIDTH]] x i64> {{.*}}, splat (i64 -1)
void u64_predec(unsigned int64 v[]) {
    unsigned int64 x = v[programIndex];
    --x;
    v[programIndex] = x;
}
