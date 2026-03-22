#version 300 es

precision highp float;
precision highp sampler2D;

in vec2 uv;
out vec4 out_color;

uniform vec2 u_resolution;
uniform float u_time;
uniform sampler2D u_textures[16];

void main() {

    // ----------------------------
    // Aspect-correct UV
    // ----------------------------
    vec2 aspect = vec2(u_resolution.x / u_resolution.y, 1.0);
    vec2 centered = (uv - 0.5) * aspect + 0.5;

    if (centered.x < 0.0 || centered.x > 1.0 || centered.y < 0.0 || centered.y > 1.0) {
        discard;
    }

    vec2 texUV = centered;
    float t = u_time;

// ============================
// 🪽 CLEAN WING MASKS (SOFT)
// ============================

float leftWing =
    smoothstep(0.48, 0.38, texUV.y) *
    (1.0 - smoothstep(0.62, 0.72, texUV.y)) *
    smoothstep(0.42, 0.10, texUV.x);

float rightWing =
    smoothstep(0.48, 0.38, texUV.y) *
    (1.0 - smoothstep(0.62, 0.72, texUV.y)) *
    smoothstep(0.58, 0.90, texUV.x);

// softer center protection
float centerFade = smoothstep(0.46, 0.50, texUV.x) *
                   (1.0 - smoothstep(0.50, 0.54, texUV.x));

leftWing *= (1.0 - centerFade * 0.7);
rightWing *= (1.0 - centerFade * 0.7);


// ============================
// 🪽 SOFT FLAP (REDUCED)
// ============================

vec2 leftPivot  = vec2(0.36, 0.58);
vec2 rightPivot = vec2(0.64, 0.58);

// slower + smoother motion
float flapL = sin(t * 3.2);
float flapR = sin(t * 3.2 + 0.9);

// MUCH smaller rotation (key change)
float angleL = flapL * 0.10;
float angleR = flapR * 0.10;

mat2 rotL = mat2(cos(angleL), -sin(angleL),
                 sin(angleL),  cos(angleL));

mat2 rotR = mat2(cos(-angleR), -sin(-angleR),
                 sin(-angleR),  cos(-angleR));

// pivot transform
vec2 l = texUV - leftPivot;
vec2 r = texUV - rightPivot;

vec2 lRot = rotL * l + leftPivot;
vec2 rRot = rotR * r + rightPivot;

// reduced influence (super important)
texUV = mix(texUV, lRot, leftWing * 0.45);
texUV = mix(texUV, rRot, rightWing * 0.45);


// ============================
// ✨ EXTRA POLISH (SUBTLE ARC)
// ============================

// adds a tiny vertical softness (makes it feel alive)
float softness = sin(t * 3.2) * 0.004;
texUV.y += softness * (leftWing + rightWing);

// ============================
// 🫧 BODY BREATHING (CALM)
// ============================

float inwardMask = smoothstep(0.25, 0.40, texUV.x) *
                   (1.0 - smoothstep(0.60, 0.75, texUV.x));

// tighten vertical influence → avoids head area
float innerBand = smoothstep(0.10, 0.058, texUV.y) *
                  (1.0 - smoothstep(0.058, 0.068, texUV.y));

float innerMask = inwardMask * innerBand;

// slower + softer
float breathe = sin(t * 1.4) * 0.003;

texUV.y += breathe * innerMask;
    // ============================
    // 🐾 LOWER BODY MOTION
    // ============================

    float lowerBand = smoothstep(0.060, 0.35, texUV.y) *
                      (1.0 - smoothstep(0.075, 1.00, texUV.y));

    float delay = texUV.y * 0.2;

    float wave = sin(t * 2.2 + delay) * 0.015;
    float squash = sin(t * 2.2 + delay) * 0.010;

    texUV.y += wave * lowerBand;
    texUV.x += squash * lowerBand;

    // ============================
    // 🧱 PIXELATION
    // ============================

    float pixelSize = 120.0;
    texUV = floor(texUV * pixelSize) / pixelSize;

    // ============================
    // 🎨 TEXTURE
    // ============================

    vec4 pet = texture(u_textures[0], texUV);

    if (pet.a < 0.1) discard;

    // ============================
    // ✨ GLOW
    // ============================

    float glow = smoothstep(0.0, 1.0, pet.a);
    vec3 glowColor = vec3(0.4, 1.0, 0.8) * glow * 0.18;

    out_color = vec4(pet.rgb + glowColor, pet.a);
}