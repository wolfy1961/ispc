#include "test_static.isph"
task void f_f(uniform float RET[], uniform float aFOO[]) {
    uint8 a;
    for (uniform int i = 0; i < programCount; ++i)
        a = insert(a, i, (uint8)i);
    RET[programIndex] = a; 
}

task void result(uniform float RET[]) {
    RET[programIndex] = programIndex;
}
