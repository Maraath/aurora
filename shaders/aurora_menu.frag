// Aurora dos pilares do menu do computador (docs/prototipo/cortinas.html).
//
// UMA aurora para a janela toda: duas fitas que serpenteiam, com raios verticais
// finos pendurados, borda de baixo verde e forte (com um fio claro), alto subindo
// para violeta e rosa e um brilho difuso em volta. Os pilares das áreas são
// "janelas" onde ela aparece com força (bordas suaves); nos vãos ela continua
// fraca (uFundo) e sobre a área aberta quase some, menos na hora de abrir, quando
// sobe como uma cortina grande. Cada pilar ganha um toque da cor da área.
// Perto do mouse a fita ondula e acende. Saída em alfa pré-multiplicado.
#version 460 core
#include <flutter/runtime_effect.glsl>

uniform vec2 uTamanho;  // tamanho da tela pintada (px lógicos)
uniform float uTempo;   // segundos
uniform vec3 uMouse;    // x, y, força 0..1
uniform float uFundo;   // aurora fora dos pilares (vãos)
uniform float uEscuro;  // 1 tema escuro, 0 claro
uniform float uAtivo;   // índice da área aberta
// Retângulos dos 8 lugares (x, y, largura, altura); largura 0 = não existe.
uniform vec4 uR0;
uniform vec4 uR1;
uniform vec4 uR2;
uniform vec4 uR3;
uniform vec4 uR4;
uniform vec4 uR5;
uniform vec4 uR6;
uniform vec4 uR7;
// Cor da área (rgb) e força da aurora naquele lugar (a).
uniform vec4 uC0;
uniform vec4 uC1;
uniform vec4 uC2;
uniform vec4 uC3;
uniform vec4 uC4;
uniform vec4 uC5;
uniform vec4 uC6;
uniform vec4 uC7;

out vec4 fragColor;

float hash(vec2 p) {
  return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
}

float ruido(vec2 p) {
  vec2 i = floor(p);
  vec2 f = fract(p);
  vec2 u = f * f * (3.0 - 2.0 * f);
  return mix(mix(hash(i), hash(i + vec2(1.0, 0.0)), u.x),
             mix(hash(i + vec2(0.0, 1.0)), hash(i + vec2(1.0, 1.0)), u.x), u.y);
}

float fbm(vec2 p) {
  float v = 0.0;
  float a = 0.5;
  for (int k = 0; k < 5; k++) {
    v += a * ruido(p);
    p = p * 2.03 + vec2(1.7, 9.2);
    a *= 0.5;
  }
  return v;
}

float caixa(vec2 p, vec2 b, float r) {
  vec2 q = abs(p) - b + r;
  return length(max(q, 0.0)) + min(max(q.x, q.y), 0.0) - r;
}

vec4 aurora(vec2 p) {
  float h0 = uTamanho.y;
  vec2 q = p / h0;
  float t = uTempo;
  vec2 dm = p - uMouse.xy;
  float perto = exp(-dot(dm, dm) / (2.0 * 120.0 * 120.0)) * uMouse.z;
  // A fita se curva: deformação lenta do espaço, mais forte perto do mouse.
  float wx = q.x + 0.10 * (fbm(vec2(q.x * 1.2 + t * 0.025, q.y * 1.4 - t * 0.02)) - 0.5)
           + perto * 0.025 * sin(q.y * 26.0 - t * 3.5 + fbm(vec2(q.x * 4.0, t * 0.4)) * 3.0);
  vec3 luz = vec3(0.0);
  float alfa = 0.0;
  for (int b = 0; b < 2; b++) {
    float fb = float(b);
    float base = (b == 0 ? 0.70 : 0.47)
               + 0.11 * sin(wx * 2.1 + t * 0.055 + fb * 2.3)
               + 0.06 * sin(wx * 5.3 - t * 0.08 + fb * 1.1)
               + 0.06 * (fbm(vec2(wx * 1.8, t * 0.04 + fb * 7.0)) - 0.5);
    float h = base - q.y; // altura acima da borda de baixo da fita
    // Raios: estrias finas verticais que andam devagar de lado.
    float r1 = fbm(vec2(wx * 42.0 + fb * 13.0 - t * 0.35, q.y * 1.2 - t * 0.18));
    float r2 = fbm(vec2(wx * 90.0 + fb * 5.0 + t * 0.2, q.y * 0.6));
    float raios = 0.45 + 2.6 * pow(r1, 2.0) + 0.4 * r2;
    float dobras = 0.55 + 0.45 * sin(wx * 16.0 + fbm(vec2(wx * 3.0, t * 0.08)) * 7.0 + t * 0.15);
    float acesa = (b == 0 ? 1.0 : 0.75)
                * (0.38 + 0.62 * smoothstep(0.2, 0.7, fbm(vec2(wx * 1.4 - t * 0.035, fb * 3.0 + t * 0.01))));
    float sobe = 0.19 + 0.08 * fb + 0.06 * fbm(vec2(wx * 6.0, t * 0.1));
    float corpo = h > 0.0 ? exp(-h / sobe) : exp(h / 0.016);
    float i = corpo * raios * dobras * acesa * (1.0 + perto * 0.9) * 1.35;
    float alto = h > 0.0 ? smoothstep(0.04, 0.30, h) : 0.0;
    vec3 verde = vec3(0.20, 1.0, 0.52);
    vec3 teal = vec3(0.16, 0.88, 0.78);
    vec3 rosa = vec3(0.98, 0.30, 0.70);
    vec3 violeta = vec3(0.52, 0.40, 1.0);
    vec3 c = mix(verde, teal, clamp(h * 6.0, 0.0, 1.0) * 0.35);
    c = mix(c, mix(violeta, rosa, 0.5 + 0.5 * sin(wx * 2.6 + t * 0.04 + fb)), alto);
    c += vec3(0.55, 1.0, 0.75) * exp(-abs(h) / 0.010) * 0.45 * raios;
    luz += c * i;
    alfa += i * 0.85;
  }
  float halo = exp(-pow((q.y - 0.55) / 0.30, 2.0)) * 0.16 * (0.5 + 0.5 * fbm(vec2(wx * 1.3, t * 0.04)));
  luz += vec3(0.16, 0.62, 0.55) * halo;
  alfa += halo;
  return vec4(luz, alfa);
}

// Soma a contribuição de um lugar (pilar ou área aberta) à máscara.
void lugar(vec2 p, vec4 r, vec4 c, float idx,
           inout float m, inout float noPainel, inout float kPainel, inout vec3 tinta, inout float peso) {
  if (r.z <= 0.0) return;
  float d = caixa(p - (r.xy + r.zw * 0.5), r.zw * 0.5, min(24.0, r.z * 0.5));
  float dentro = 1.0 - smoothstep(-10.0, 8.0, d);
  if (abs(idx - uAtivo) < 0.5) {
    noPainel = dentro;
    kPainel = c.a;
  } else {
    m = max(m, dentro * c.a);
  }
  tinta += c.rgb * dentro;
  peso += dentro;
}

void main() {
  vec2 p = FlutterFragCoord().xy;
  float m = uFundo;
  float noPainel = 0.0;
  float kPainel = 0.0;
  vec3 tinta = vec3(0.0);
  float peso = 0.0;
  lugar(p, uR0, uC0, 0.0, m, noPainel, kPainel, tinta, peso);
  lugar(p, uR1, uC1, 1.0, m, noPainel, kPainel, tinta, peso);
  lugar(p, uR2, uC2, 2.0, m, noPainel, kPainel, tinta, peso);
  lugar(p, uR3, uC3, 3.0, m, noPainel, kPainel, tinta, peso);
  lugar(p, uR4, uC4, 4.0, m, noPainel, kPainel, tinta, peso);
  lugar(p, uR5, uC5, 5.0, m, noPainel, kPainel, tinta, peso);
  lugar(p, uR6, uC6, 6.0, m, noPainel, kPainel, tinta, peso);
  lugar(p, uR7, uC7, 7.0, m, noPainel, kPainel, tinta, peso);
  m = mix(m, kPainel, noPainel);
  if (m < 0.003) {
    fragColor = vec4(0.0);
    return;
  }
  vec4 a = aurora(p);
  if (peso > 0.01) {
    vec3 tc = tinta / peso;
    a.rgb = mix(a.rgb, a.rgb * (0.55 + tc * 0.9), 0.35 * min(peso, 1.0));
  }
  a *= m * mix(0.6, 1.0, uEscuro);
  fragColor = vec4(min(a.rgb, vec3(1.0)), clamp(a.a, 0.0, 1.0));
}
