#!/usr/bin/env python3
"""Draws the app icon of Block Tiles, by code (no image tool, no external asset).

The design: one ivory mahjong tile on its jade back, slightly tilted, engraved with a block
piece (three vermilion squares and a gold one), on the night-blue background of the game with
a soft gold glow. Colours and proportions follow game/data/tile_art.gd and
game/board/tile_drawing.gd.
Needs numpy and Pillow (see assets/LICENSES.md).

Usage (from the project root):
    python3 -I tools/assets/make_icon.py                # writes assets/icon/*.png
    python3 -I tools/assets/make_icon.py --preview out.png   # also writes a preview sheet

Outputs:
    icon.png                     512 x 512, full square (project icon, store listing)
    android_main_192.png         192 x 192, rounded square (legacy launcher icon)
    android_foreground_432.png   432 x 432, transparent, art inside the 66 dp safe zone
    android_background_432.png   432 x 432, opaque background
    android_monochrome_432.png   432 x 432, white silhouette (themed icons, Android 13)
"""

import argparse
from pathlib import Path

import numpy as np
from PIL import Image, ImageChops, ImageDraw, ImageFilter

# Everything is drawn SUPERSAMPLE times bigger, then reduced (anti-aliasing).
SUPERSAMPLE = 4

# Palette (game/data/tile_art.gd).
TILE_FACE = (0xF4, 0xEE, 0xDC)
TILE_RIM = (0xFC, 0xFA, 0xF5)
TILE_SEAM = (0xD9, 0xCF, 0xB4)
TILE_BACK = (0x2E, 0x7D, 0x62)
TILE_BACK_LIP = (0x1F, 0x5A, 0x46)
GOLD = (0xE8, 0xB6, 0x4C)
VERMILION = (0xD2, 0x45, 0x2F)
NIGHT_TOP = (0x24, 0x30, 0x58)
NIGHT_BOTTOM = (0x0B, 0x12, 0x22)

# Tile proportions, as fractions of the tile's side (TileDrawing; the back is a little
# thicker than in the game so that the jade still shows at 48 px).
SIDE = 0.17
LIP = 0.06
SEAM = 0.03
CORNER = 0.19
RIM = 0.03
LIGHT_HEIGHT = 0.5
LIGHT_ALPHA = 0.32

# The engraved block piece: a 2 x 2 of rounded squares, as fractions of the face's width.
BLOCK_SIZE = 0.27
BLOCK_GAP = 0.055
BLOCK_CORNER = 0.07
ENGRAVE_SHADOW = 0.014
ENGRAVE_LIGHT = 0.02
# The gold piece is a disc, like the circle of a mahjong tile, with a ring inlaid in ivory
# (TileDrawing's inlays); ring radius and width as fractions of the block.
DISC_CORNER = 0.5
INLAY_RADIUS = 0.25
INLAY_WIDTH = 0.085
# (column, row, colour, corner): an L of vermilion blocks and the gold disc it calls for.
BLOCKS = (
    (0, 0, VERMILION, BLOCK_CORNER),
    (0, 1, VERMILION, BLOCK_CORNER),
    (1, 1, VERMILION, BLOCK_CORNER),
    (1, 0, GOLD, DISC_CORNER),
)

# Tilt of the tile, in degrees (counter-clockwise).
TILT = 9.0
# Side of the tile as a fraction of the canvas: full icon, and adaptive foreground (the tile
# must stay inside the safe zone, a circle of 66 dp out of 108).
TILE_SCALE_ICON = 0.6
TILE_SCALE_ADAPTIVE = 0.44
# Lights behind the tile, added to the background: a wide blue halo and a tighter gold glow
# (radius as a fraction of the canvas, light added at the centre).
HALO_RADIUS = 0.62
HALO_LIGHT = (22, 38, 92)
GLOW_RADIUS = 0.44
GLOW_LIGHT = (58, 40, 6)
# Corner radius of the legacy icon, as a fraction of its side.
LEGACY_CORNER = 0.22

OUTPUT_DIR = Path(__file__).resolve().parents[2] / "assets" / "icon"


def darkened(color: tuple, amount: float) -> tuple:
    return tuple(round(channel * (1.0 - amount)) for channel in color)


def background(size: int) -> Image.Image:
    """The night-blue gradient, lit from the centre by a gold glow."""
    ys, xs = np.mgrid[0:size, 0:size].astype(np.float32) / (size - 1)
    top = np.array(NIGHT_TOP, np.float32)
    bottom = np.array(NIGHT_BOTTOM, np.float32)
    # Lighter towards the top centre, darker in the bottom corners.
    shade = np.clip(ys * 0.75 + ((xs - 0.5) ** 2 + (ys - 0.42) ** 2) * 0.9, 0.0, 1.0)
    pixels = top + (bottom - top) * shade[..., None]
    # Light is added, not mixed: gold mixed into blue turns grey.
    distance = np.sqrt((xs - 0.5) ** 2 + (ys - 0.5) ** 2)
    halo = np.exp(-((distance / HALO_RADIUS) ** 2) * 2.2)
    pixels = pixels + np.array(HALO_LIGHT, np.float32) * halo[..., None]
    glow = np.exp(-((distance / GLOW_RADIUS) ** 2) * 2.2)
    pixels = pixels + np.array(GLOW_LIGHT, np.float32) * glow[..., None]
    image = Image.fromarray(np.clip(pixels, 0, 255).astype(np.uint8), "RGB")
    return image.convert("RGBA")


def _rounded(draw: ImageDraw.ImageDraw, box: tuple, radius: float, fill: tuple) -> None:
    """A rounded rectangle; a radius of half the side or more makes a disc."""
    box = [round(value) for value in box]
    radius = min(round(radius), (box[2] - box[0]) // 2, (box[3] - box[1]) // 2)
    draw.rounded_rectangle(box, radius=max(radius, 0), fill=fill)


def _engraved_block(image: Image.Image, box: tuple, radius: float, ink: tuple, unit: float) -> None:
    """A rounded square sunk in the face: shadow above, light below, darker edge, soft top."""
    draw = ImageDraw.Draw(image, "RGBA")
    x0, y0, x1, y1 = box
    light = unit * ENGRAVE_LIGHT
    shadow = unit * ENGRAVE_SHADOW
    _rounded(draw, (x0, y0 + light, x1, y1 + light), radius, (255, 255, 255, 215))
    _rounded(draw, (x0, y0 - shadow, x1, y1 - shadow), radius, darkened(ink, 0.45) + (150,))
    _rounded(draw, box, radius, darkened(ink, 0.28) + (255,))
    edge = unit * 0.012
    _rounded(draw, (x0 + edge, y0 + edge * 1.6, x1 - edge, y1 - edge), radius - edge, ink + (255,))
    # A faint sheen on the lower half, as lacquer catches the light.
    sheen = Image.new("RGBA", image.size, (0, 0, 0, 0))
    sheen_draw = ImageDraw.Draw(sheen)
    middle = (y0 + y1) / 2.0
    _rounded(
        sheen_draw, (x0 + edge * 2, middle, x1 - edge * 2, y1 - edge * 2), radius, (255, 255, 255, 22)
    )
    image.alpha_composite(sheen)


def tile(side: int, symbol: bool = True) -> Image.Image:
    """An upright tile of `side` pixels with its block symbol, on a transparent square with a
    margin of side / 2 all around (room to turn it)."""
    margin = side // 2
    image = Image.new("RGBA", (side + margin * 2, side + margin * 2), (0, 0, 0, 0))
    draw = ImageDraw.Draw(image, "RGBA")
    x0, y0, x1, y1 = margin, margin, margin + side, margin + side
    radius = side * CORNER
    _rounded(draw, (x0, y0, x1, y1), radius, TILE_BACK_LIP + (255,))
    _rounded(draw, (x0, y0, x1, y1 - side * LIP), radius, TILE_BACK + (255,))
    face_bottom = y1 - side * SIDE
    _rounded(draw, (x0, y0, x1, face_bottom + side * SEAM), radius, TILE_SEAM + (255,))
    _rounded(draw, (x0, y0, x1, face_bottom), radius, TILE_RIM + (255,))
    rim = side * RIM
    face = Image.new("RGBA", image.size, (0, 0, 0, 0))
    _rounded(ImageDraw.Draw(face), (x0 + rim, y0 + rim, x1 + rim, face_bottom + rim), radius, TILE_FACE + (255,))
    face_mask = Image.new("L", image.size, 0)
    _rounded(ImageDraw.Draw(face_mask), (x0, y0, x1, face_bottom), radius, 255)
    face.putalpha(ImageChops.multiply(face.getchannel("A"), face_mask))
    image.alpha_composite(face)
    # Soft light falling on the top of the face.
    height = image.size[1]
    rows = np.zeros(height, np.float32)
    light_rows = round((face_bottom - y0) * LIGHT_HEIGHT)
    rows[y0 : y0 + light_rows] = np.linspace(LIGHT_ALPHA * 255, 0, light_rows)
    light_alpha = Image.fromarray(np.tile(rows[:, None], (1, image.size[0])).astype(np.uint8), "L")
    light = Image.new("RGBA", image.size, (255, 255, 255, 0))
    light.putalpha(ImageChops.multiply(light_alpha, face_mask))
    image.alpha_composite(light)
    if symbol:
        center_x = (x0 + x1) / 2.0
        center_y = (y0 + face_bottom) / 2.0
        block = side * BLOCK_SIZE
        gap = side * BLOCK_GAP
        for column, row, ink, corner in BLOCKS:
            left = center_x - block - gap / 2.0 + column * (block + gap)
            top = center_y - block - gap / 2.0 + row * (block + gap)
            box = (left, top, left + block, top + block)
            _engraved_block(image, box, side * corner, ink, side)
            if corner == DISC_CORNER:
                ring = block * INLAY_RADIUS
                middle = (left + block / 2.0, top + block / 2.0)
                ImageDraw.Draw(image, "RGBA").ellipse(
                    [middle[0] - ring, middle[1] - ring, middle[0] + ring, middle[1] + ring],
                    outline=TILE_FACE + (225,),
                    width=round(block * INLAY_WIDTH),
                )
    return image


def foreground(size: int, tile_scale: float, shadow: bool = True) -> Image.Image:
    """The tilted tile and its shadow, centred on a transparent canvas of `size` pixels."""
    big = size * SUPERSAMPLE
    turned = tile(round(big * tile_scale)).rotate(TILT, resample=Image.BICUBIC)
    layer = Image.new("RGBA", (big, big), (0, 0, 0, 0))
    offset = ((big - turned.size[0]) // 2, (big - turned.size[1]) // 2 - round(big * 0.008))
    if shadow:
        alpha = Image.new("L", (big, big), 0)
        alpha.paste(turned.getchannel("A"), (offset[0], offset[1] + round(big * 0.035)))
        alpha = alpha.filter(ImageFilter.GaussianBlur(big * 0.022)).point(lambda value: value * 0.6)
        dark = Image.new("RGBA", (big, big), (4, 7, 16, 0))
        dark.putalpha(alpha)
        layer.alpha_composite(dark)
    layer.alpha_composite(turned, offset)
    return layer.resize((size, size), Image.LANCZOS)


def monochrome(size: int, tile_scale: float) -> Image.Image:
    """A white silhouette of the tile with its blocks cut out: Android tints it itself."""
    big = size * SUPERSAMPLE
    side = round(big * tile_scale)
    margin = side // 2
    alpha = Image.new("L", (side + margin * 2, side + margin * 2), 0)
    draw = ImageDraw.Draw(alpha)
    _rounded(draw, (margin, margin, margin + side, margin + side), side * CORNER, 255)
    face_bottom = margin + side * (1.0 - SIDE)
    # The line between the face and the back.
    band = Image.new("L", alpha.size, 0)
    band_draw = ImageDraw.Draw(band)
    _rounded(band_draw, (margin, margin, margin + side, face_bottom + side * 0.045), side * CORNER, 255)
    _rounded(band_draw, (margin, margin, margin + side, face_bottom), side * CORNER, 0)
    alpha = ImageChops.subtract(alpha, band)
    draw = ImageDraw.Draw(alpha)
    center_x = margin + side / 2.0
    center_y = (margin + face_bottom) / 2.0
    block = side * BLOCK_SIZE
    gap = side * BLOCK_GAP
    for column, row, _ink, corner in BLOCKS:
        left = center_x - block - gap / 2.0 + column * (block + gap)
        top = center_y - block - gap / 2.0 + row * (block + gap)
        _rounded(draw, (left, top, left + block, top + block), side * corner, 0)
        if corner == DISC_CORNER:
            # The disc keeps its heart: it stays different from the blocks without colour.
            inset = block * 0.24
            _rounded(
                draw,
                (left + inset, top + inset, left + block - inset, top + block - inset),
                side * corner,
                255,
            )
    alpha = alpha.rotate(TILT, resample=Image.BICUBIC)
    canvas = Image.new("L", (big, big), 0)
    canvas.paste(alpha, ((big - alpha.size[0]) // 2, (big - alpha.size[1]) // 2))
    image = Image.new("RGBA", (big, big), (255, 255, 255, 0))
    image.putalpha(canvas)
    return image.resize((size, size), Image.LANCZOS)


def full_icon(size: int) -> Image.Image:
    """The whole icon, square and opaque."""
    image = background(size)
    image.alpha_composite(foreground(size, TILE_SCALE_ICON))
    return image


def shape_mask(size: int, shape: str) -> Image.Image:
    """A launcher mask: "circle", "squircle" (superellipse) or "rounded" (legacy icon)."""
    big = size * SUPERSAMPLE
    if shape == "squircle":
        ys, xs = (np.mgrid[0:big, 0:big].astype(np.float32) + 0.5) / big * 2.0 - 1.0
        inside = (np.abs(xs) ** 4.5 + np.abs(ys) ** 4.5) <= 1.0
        mask = Image.fromarray((inside * 255).astype(np.uint8), "L")
    else:
        mask = Image.new("L", (big, big), 0)
        radius = big / 2.0 if shape == "circle" else big * LEGACY_CORNER
        ImageDraw.Draw(mask).rounded_rectangle([0, 0, big - 1, big - 1], radius=radius, fill=255)
    return mask.resize((size, size), Image.LANCZOS)


def masked(image: Image.Image, shape: str) -> Image.Image:
    result = image.copy()
    result.putalpha(ImageChops.multiply(result.getchannel("A"), shape_mask(image.size[0], shape)))
    return result


def make_all() -> dict:
    return {
        "icon.png": full_icon(512),
        "android_main_192.png": masked(full_icon(192), "rounded"),
        "android_foreground_432.png": foreground(432, TILE_SCALE_ADAPTIVE),
        "android_background_432.png": background(432).convert("RGB"),
        "android_monochrome_432.png": monochrome(432, TILE_SCALE_ADAPTIVE),
    }


def _wallpaper(width: int, height: int, light: bool) -> Image.Image:
    ys, xs = np.mgrid[0:height, 0:width].astype(np.float32)
    mix = (xs / width * 0.5 + ys / height * 0.5)[..., None]
    if light:
        start, end = np.array((0xE9, 0xEE, 0xF4), np.float32), np.array((0xC9, 0xD6, 0xE6), np.float32)
    else:
        start, end = np.array((0x2A, 0x1F, 0x3A), np.float32), np.array((0x10, 0x14, 0x1C), np.float32)
    return Image.fromarray((start + (end - start) * mix).astype(np.uint8), "RGB").convert("RGBA")


def preview(images: dict) -> Image.Image:
    """A sheet for review: the icon at several sizes, then as launchers show it (adaptive
    layers under a circle and a squircle, legacy icon, themed icon) on two wallpapers."""
    sheet = Image.new("RGBA", (1200, 1040), (0x1A, 0x1C, 0x22, 255))
    icon = images["icon.png"].convert("RGBA")
    x = 24
    for size in (512, 192, 96, 48):
        sheet.alpha_composite(icon.resize((size, size), Image.LANCZOS), (x, 24))
        x += size + 28
    # The 48 px icon again, enlarged without smoothing, to see what is left of it.
    small = icon.resize((48, 48), Image.LANCZOS).resize((192, 192), Image.NEAREST)
    sheet.alpha_composite(small, (564, 260))
    # What a launcher shows of the adaptive icon: the middle 72 dp of the 108 dp layers.
    adaptive = images["android_background_432.png"].convert("RGBA")
    adaptive.alpha_composite(images["android_foreground_432.png"])
    adaptive = adaptive.crop((72, 72, 360, 360))
    themed_light = Image.new("RGBA", (432, 432), (0xD7, 0xE3, 0xF8, 255))
    tint = Image.new("RGBA", (432, 432), (0x1B, 0x2F, 0x52, 255))
    tint.putalpha(images["android_monochrome_432.png"].getchannel("A"))
    themed_light.alpha_composite(tint)
    themed_light = themed_light.crop((72, 72, 360, 360))
    for row, light in enumerate((True, False)):
        top = 560 + row * 240
        sheet.alpha_composite(_wallpaper(1152, 220, light), (24, top))
        x = 60
        for size in (144, 96, 48):
            for shape in ("circle", "squircle"):
                shown = masked(adaptive.resize((size, size), Image.LANCZOS), shape)
                sheet.alpha_composite(shown, (x, top + (220 - size) // 2))
                x += size + 28
        legacy = images["android_main_192.png"].resize((96, 96), Image.LANCZOS)
        sheet.alpha_composite(legacy, (x + 20, top + 62))
        themed = masked(themed_light.resize((96, 96), Image.LANCZOS), "circle")
        sheet.alpha_composite(themed, (x + 150, top + 62))
        sheet.alpha_composite(masked(themed_light.resize((48, 48), Image.LANCZOS), "circle"), (x + 270, top + 86))
    return sheet.convert("RGB")


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    parser.add_argument("--out-dir", type=Path, default=OUTPUT_DIR)
    parser.add_argument("--preview", type=Path, help="also write a review sheet to this PNG")
    arguments = parser.parse_args()
    images = make_all()
    arguments.out_dir.mkdir(parents=True, exist_ok=True)
    for name, image in images.items():
        image.save(arguments.out_dir / name, optimize=True)
        print(f"{arguments.out_dir / name}: {image.size[0]} x {image.size[1]}")
    if arguments.preview:
        arguments.preview.parent.mkdir(parents=True, exist_ok=True)
        preview(images).save(arguments.preview, optimize=True)
        print(arguments.preview)


if __name__ == "__main__":
    main()
