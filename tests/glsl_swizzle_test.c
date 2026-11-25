#include <assert.h>
#include <string.h>

typedef unsigned char GLboolean;
#define GL_FALSE 0
#define GL_TRUE 1
#include "glsl_swizzle_impl.h"

static void test_hcr_pixelate_shader_identifiers_remain_distinct(void) {
    char source[] =
        "float t=v_texCoord.t;"
        "float s=v_texCoord.s;"
        "float x=qs*floor(s/qs)+xOffset;"
        "float y=qt*floor(t/qt);"
        "vec2 texc=vec2(x,y);";
    const char expected[] =
        "float t=v_texCoord.y;"
        "float s=v_texCoord.x;"
        "float x=qs*floor(s/qs)+xOffset;"
        "float y=qt*floor(t/qt);"
        "vec2 texc=vec2(x,y);";

    glsl_translate_stpq_swizzles(source);
    assert(strcmp(source, expected) == 0);
}

static void test_member_swizzles_do_not_rename_identifiers(void) {
    char source[] =
        "a.s+a.t+a.st+a.ts+a.ss+a.tt+a.p+a.q+"
        "a.sts+a.stpq+a.stts+a.texture+s+t+st+ts+ss+tt+"
        "left . s+right.\t tt;";
    const char expected[] =
        "a.x+a.y+a.xy+a.yx+a.xx+a.yy+a.z+a.w+"
        "a.xyx+a.xyzw+a.xyyx+a.texture+s+t+st+ts+ss+tt+"
        "left . x+right.\t yy;";

    glsl_translate_stpq_swizzles(source);
    assert(strcmp(source, expected) == 0);
}

int main(void) {
    test_hcr_pixelate_shader_identifiers_remain_distinct();
    test_member_swizzles_do_not_rename_identifiers();
}
