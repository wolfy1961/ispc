#include "test_static.isph"
task void f_f(uniform float RET[], uniform float aFOO[]) {
    float a = aFOO[programIndex];
    uniform int8 pack[2+programCount];
    for (uniform int i = 0; i < 2+programCount; ++i)
        pack[i] = 0;
    uniform int count = 0;
    if ((int)a & 1)
        count += packed_store_active2(&pack[2], (int8)a);
    RET[programIndex] = count;
}

task void result(uniform float RET[]) {
    RET[programIndex] = (programCount == 1) ? 1 : programCount/2;
}
