#include "test_static.isph"
task void f_f(uniform float RET[], uniform float aFOO[]) {
    float a = aFOO[programIndex]; 
    uniform unsigned int64 pack[programCount];
    for (uniform int i = 0; i < programCount; ++i)
        pack[i] = 0;
    #pragma ignore warning(perf)
    packed_store_active(pack, (unsigned int64)a);
    #pragma ignore warning(perf)
    RET[programIndex] = pack[programIndex]; 
}

task void result(uniform float RET[]) {
    RET[programIndex] = 1 + programIndex;
}
