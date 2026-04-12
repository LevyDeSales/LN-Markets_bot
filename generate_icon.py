#!/usr/bin/env python3
"""
Gera o ícone do LN Markets Bot (1024x1024 PNG).
Robot com raio da Lightning Network.
Requer: pip install Pillow
"""
import math, os
from PIL import Image, ImageDraw

SIZE   = 1024
ORANGE = (247, 147, 26, 255)
DARK   = (13,  13,  13, 255)
PANEL  = (26,  26,  26, 255)
WHITE  = (255, 255, 255, 255)

def rr(draw, xy, r, fill=None, outline=None, width=1):
    draw.rounded_rectangle(xy, radius=r, fill=fill, outline=outline, width=width)

def generate(out="assets/icon/icon.png"):
    img  = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    S    = SIZE

    # ── Fundo arredondado ──────────────────────────────────────────────────
    rr(draw, [0, 0, S, S], 200, fill=DARK)

    # ── Cabeça do robô ─────────────────────────────────────────────────────
    M = 55
    rr(draw, [M, M+30, S-M, S-M], 110,
       fill=PANEL, outline=ORANGE, width=9)

    # antena
    draw.rectangle([S//2-6, M-48, S//2+6, M+36], fill=ORANGE)
    draw.ellipse(  [S//2-22, M-70, S//2+22, M-26], fill=ORANGE)

    # orelhas / laterais do robô
    ear_w, ear_h = 28, 80
    for ex in [M - ear_w, S - M]:
        rr(draw, [ex, 390, ex+ear_w, 390+ear_h], 10, fill=ORANGE)

    # ── Olhos ──────────────────────────────────────────────────────────────
    ey, er = 330, 68
    for cx in [300, S - 300]:
        draw.ellipse([cx-er, ey-er, cx+er, ey+er], fill=ORANGE)
        pr = 28
        draw.ellipse([cx-pr, ey-pr, cx+pr, ey+pr], fill=DARK)

    # ── Boca (barra + "dentes") ───────────────────────────────────────────
    rr(draw, [240, 480, S-240, 516], 14, fill=ORANGE)
    for i in range(5):
        tx = 270 + i * 100
        draw.rectangle([tx, 516, tx+50, 548], fill=ORANGE)

    # ── Raio Lightning (centrado na parte inferior da cabeça) ───────────
    bx, by = S // 2, 680
    bw, bh = 115, 195
    bolt = [
        (bx + bw*0.45, by - bh*0.50),
        (bx - bw*0.10, by - bh*0.02),
        (bx + bw*0.18, by - bh*0.02),
        (bx - bw*0.45, by + bh*0.50),
        (bx + bw*0.10, by + bh*0.04),
        (bx - bw*0.18, by + bh*0.04),
    ]
    # sombra suave
    glow = [(x+4, y+4) for x,y in bolt]
    draw.polygon(glow, fill=(180, 100, 10, 140))
    draw.polygon(bolt, fill=ORANGE)

    # ── Reflexo de brilho no canto superior esquerdo da cabeça ───────────
    draw.ellipse([M+18, M+48, M+80, M+90],
                 fill=(255, 220, 160, 35))

    os.makedirs(os.path.dirname(out), exist_ok=True)
    img.save(out, "PNG")
    print(f"✓ Ícone gerado em: {out}")

if __name__ == "__main__":
    generate()
