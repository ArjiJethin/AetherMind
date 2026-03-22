#include <flutter/runtime_effect.glsl>

uniform sampler2D uTexture;
uniform vec2 uSize;
uniform float uTime;

out vec4 fragColor;

void main() {

    // ============================
    // 🧠 CORRECT UV (FIX SQUASHING)
    // ============================

    vec2 uv = FlutterFragCoord().xy / uSize;

    // preserve aspect ratio
    float aspect = uSize.x / uSize.y;
    vec2 centered = (uv - 0.5) * vec2(aspect, 1.0) + 0.5;

    // discard outside image
    if (centered.x < 0.0 || centered.x > 1.0 ||
        centered.y < 0.0 || centered.y > 1.0) {
        discard;
    }

    vec2 texUV = centered;
    float t = uTime;

    // ============================
    // 🪽 WING MASKS (UNCHANGED)
    // ============================

    float leftWing = step(texUV.x, 0.28) *
                     smoothstep(0.42, 0.50, texUV.y) *
                     (1.0 - smoothstep(0.50, 0.62, texUV.y));

    float rightWing = step(0.72, texUV.x) *
                      smoothstep(0.42, 0.50, texUV.y) *
                      (1.0 - smoothstep(0.50, 0.62, texUV.y));

    float innerWing = smoothstep(0.35, 0.65, texUV.x) *
                      smoothstep(0.55, 0.62, texUV.y) *
                      (1.0 - smoothstep(0.62, 0.75, texUV.y));

    // ============================
    // 🪽 MOTION (YOUR WORKING VERSION)
    // ============================

    float mainMotion = sin(t * 3.0) * 0.014;
    float innerMotion = sin(t * 2.5 + 0.6) * 0.010;

    float pivotMain = 0.58;
    float pivotInner = 0.66;

    float dMain = (texUV.y - pivotMain);
    float dInner = (texUV.y - pivotInner);

    float spread = (texUV.x - 0.5);

    texUV.y += mainMotion * leftWing * dMain * 2.0;
    texUV.x += mainMotion * leftWing * (-spread) * 0.25;

    texUV.y += mainMotion * rightWing * dMain * 2.0;
    texUV.x += mainMotion * rightWing * spread * 0.25;

    texUV.y += innerMotion * innerWing * dInner * 1.8;
    texUV.x += innerMotion * innerWing * spread * 0.15;

    // ============================
    // 🎨 TEXTURE SAMPLE
    // ============================

    vec4 color = texture(uTexture, texUV);

    if (color.a < 0.1) discard;

    fragColor = color;
}