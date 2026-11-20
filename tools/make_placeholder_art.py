"""Generates the placeholder character art in art/ (run: python3 tools/make_placeholder_art.py).

Follows the design doc's art rules:
- 32x48 canvas for players and normal enemies, every layer on the same canvas.
- Anchor at the feet: the soles sit on row 45, so layers always line up with the body.
- Dark outline around every shape (added automatically around each layer).
- One shared palette (PALETTE below), in the reference sprite's tone: deep reds, golds, bone.

These are placeholders: one front-facing frame, meant to be replaced by real art.
"""
from pathlib import Path
from PIL import Image

W, H = 32, 48
ROOT = Path(__file__).resolve().parent.parent

# Shared palette: 32 colors. Names are used by the drawing code below.
PALETTE = {
    "outline": (24, 16, 28), "shadow": (48, 36, 52),
    "skin_light": (240, 196, 160), "skin": (214, 160, 124), "skin_dark": (164, 108, 84),
    "hair": (86, 52, 40), "hair_dark": (58, 34, 30), "eye": (30, 26, 40),
    "bone_light": (236, 226, 204), "bone": (204, 190, 164), "bone_dark": (152, 136, 116),
    "red_light": (196, 60, 60), "red": (150, 34, 44), "red_dark": (96, 22, 34),
    "gold_light": (252, 214, 104), "gold": (222, 164, 52), "gold_dark": (156, 102, 34),
    "cloth_light": (150, 112, 76), "cloth": (112, 80, 54), "cloth_dark": (78, 54, 38),
    "steel_light": (190, 196, 210), "steel": (136, 142, 160), "steel_dark": (88, 92, 112),
    "ember_light": (255, 200, 90), "ember": (240, 120, 40), "ember_dark": (176, 64, 30),
    "void_light": (196, 120, 220), "void": (130, 60, 170), "void_dark": (72, 34, 104),
    "gem_pink": (255, 110, 180), "star_blue": (110, 190, 255), "pants": (58, 52, 74),
}
assert len(PALETTE) == 32


class Layer:
    def __init__(self):
        self.px = {}

    def rect(self, x0, y0, x1, y1, color):
        """Fill x0..x1, y0..y1 (inclusive)."""
        for y in range(y0, y1 + 1):
            for x in range(x0, x1 + 1):
                self.px[(x, y)] = PALETTE[color]

    def dot(self, x, y, color):
        self.px[(x, y)] = PALETTE[color]

    def image(self):
        img = Image.new("RGBA", (W, H), (0, 0, 0, 0))
        for (x, y), c in self.px.items():
            img.putpixel((x, y), c + (255,))
        # Outline: every empty pixel touching a filled one (4 directions).
        out = PALETTE["outline"] + (255,)
        for y in range(H):
            for x in range(W):
                if (x, y) in self.px:
                    continue
                if any((x + dx, y + dy) in self.px for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1))):
                    img.putpixel((x, y), out)
        return img


def body():
    b = Layer()
    # Legs and bare feet.
    b.rect(11, 31, 14, 42, "pants"); b.rect(17, 31, 20, 42, "pants")
    b.rect(11, 43, 14, 45, "skin"); b.rect(17, 43, 20, 45, "skin")
    b.rect(10, 45, 14, 45, "skin"); b.rect(17, 45, 21, 45, "skin")
    b.rect(10, 29, 21, 32, "pants")
    # Torso: plain linen undershirt.
    b.rect(10, 19, 21, 30, "bone"); b.rect(19, 19, 21, 30, "bone_dark"); b.rect(10, 19, 11, 26, "bone_light")
    # Arms: short sleeves, then skin.
    b.rect(7, 19, 9, 22, "bone"); b.rect(22, 19, 24, 22, "bone_dark")
    b.rect(7, 23, 9, 30, "skin"); b.rect(22, 23, 24, 30, "skin_dark")
    # Neck and head.
    b.rect(14, 17, 17, 18, "skin_dark")
    b.rect(10, 6, 21, 16, "skin"); b.rect(19, 9, 21, 16, "skin_dark"); b.rect(11, 9, 12, 13, "skin_light")
    b.dot(13, 11, "eye"); b.dot(13, 12, "eye"); b.dot(18, 11, "eye"); b.dot(18, 12, "eye")
    b.rect(15, 14, 16, 14, "skin_dark")
    # Hair.
    b.rect(10, 4, 21, 7, "hair"); b.rect(9, 6, 10, 11, "hair"); b.rect(21, 6, 22, 11, "hair_dark")
    b.rect(12, 8, 15, 8, "hair"); b.rect(18, 4, 21, 6, "hair_dark")
    return b


def chest_cloth():
    c = Layer()  # Tier 1: Cloth tunic with a rope belt.
    c.rect(9, 18, 22, 33, "cloth"); c.rect(19, 18, 22, 33, "cloth_dark"); c.rect(9, 18, 11, 28, "cloth_light")
    c.rect(7, 19, 9, 24, "cloth"); c.rect(22, 19, 24, 24, "cloth_dark")
    c.rect(14, 18, 17, 19, "skin_dark"); c.rect(15, 20, 16, 21, "skin_dark")  # V-neck
    c.rect(9, 29, 22, 29, "bone_dark"); c.dot(13, 30, "bone_dark"); c.dot(13, 31, "bone_dark")
    return c


def chest_iron():
    c = Layer()  # Tier 3: Iron breastplate with pauldrons and a red tabard.
    c.rect(9, 18, 22, 31, "steel"); c.rect(19, 18, 22, 31, "steel_dark"); c.rect(10, 19, 12, 26, "steel_light")
    c.rect(6, 18, 10, 22, "steel"); c.rect(21, 18, 25, 22, "steel_dark")
    c.rect(7, 18, 9, 18, "steel_light")
    c.rect(13, 24, 18, 33, "red"); c.rect(17, 24, 18, 33, "red_dark"); c.rect(13, 24, 13, 33, "red_light")
    c.dot(15, 27, "gold"); c.dot(16, 27, "gold_dark")
    c.dot(11, 20, "steel_dark"); c.dot(20, 20, "steel_light")  # rivets
    c.rect(9, 31, 22, 31, "steel_dark")
    return c


def palette_image():
    img = Image.new("RGBA", (8 * 8, 4 * 8))
    for i, color in enumerate(PALETTE.values()):
        x, y = (i % 8) * 8, (i // 8) * 8
        for yy in range(y, y + 8):
            for xx in range(x, x + 8):
                img.putpixel((xx, yy), color + (255,))
    return img


def main():
    out = ROOT / "art" / "characters"
    out.mkdir(parents=True, exist_ok=True)
    body().image().save(out / "body_base.png")
    chest_cloth().image().save(out / "chest_cloth.png")
    chest_iron().image().save(out / "chest_iron.png")
    palette_image().save(ROOT / "art" / "palette.png")
    print("Wrote art to", ROOT / "art")


if __name__ == "__main__":
    main()
