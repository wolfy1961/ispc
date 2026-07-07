// Verifies that a gather index derived from 64-bit hash math does not crash
// the compiler. The gather-index analysis used to compute the power-of-two
// divisor for a right-shift as a 32-bit int, so shifts of 31/32 on 64-bit
// values overflowed to a non-positive value and tripped an assertion in
// lAllDivBaseEqual.
// See https://github.com/ispc/ispc/issues/3881

// RUN: %{ispc} %s --target=avx2-i32x16 --arch=x86_64 -O2 --nowrap --emit-llvm-text -o - | FileCheck %s

// REQUIRES: X86_ENABLED

// CHECK-LABEL: @repro64
// CHECK: @llvm.x86.avx2.gather
export void repro64(uniform int n, uniform int colorCount,
                    const uniform int* uniform lut, uniform int* uniform result) {
    foreach (index = 0 ... n) {
        unsigned int64 z = (unsigned int64)index * 0xD1B54A32D192ED03;
        z = (z ^ (z >> 30)) * 0xBF58476D1CE4E5B9;
        z = z ^ (z >> 31);
        unsigned int32 r = (unsigned int32)(z >> 32);
        int lutIdx = (int)(((unsigned int64)r * (unsigned int32)colorCount) >> 32);
        result[index] = lut[lutIdx];
    }
}

// 32-bit variant: a right-shift by 31 of a 32-bit value hit the same
// `1 << 31 == INT_MIN` overflow in the divisor computation.
// CHECK-LABEL: @repro32
// CHECK: @llvm.x86.avx2.gather
export void repro32(uniform int n, uniform int colorCount,
                    const uniform int* uniform lut, uniform int* uniform result) {
    foreach (index = 0 ... n) {
        unsigned int32 z = (unsigned int32)index * 0x9E3779B1;
        z = (z ^ (z >> 15)) * 0x85EBCA77;
        z = z ^ (z >> 31);
        int lutIdx = (int)(((unsigned int64)z * (unsigned int32)colorCount) >> 32);
        result[index] = lut[lutIdx];
    }
}
