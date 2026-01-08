# ...existing code...
try:
    from PIL import Image, ImageDraw  # pyright: ignore[reportMissingImports]
except ModuleNotFoundError:
    import sys
    print("Missing dependency: Pillow (PIL). Install with:\n  python -m pip install --user pillow")
    sys.exit(1)

import math

W, H = 320, 240
FRAMES = 28
frames = []

for f in range(FRAMES):
    im = Image.new("RGB", (W, H), "#fff7f0")
    d = ImageDraw.Draw(im)

    # background subtle gradient
    for y in range(H):
        blend = int(240 - (y / H) * 40)
        d.line([(0, y), (W, y)], fill=(255, blend, blend-20))

    # box coordinates
    box_left, box_right = 70, 250
    box_top, box_bottom = 120, 200

    # lid lifts up across frames (0 = closed, -> open)
    lift = int((f / (FRAMES - 1)) * 60)
    lid_top = box_top - 40 - lift
    lid_bottom = box_top - 4 - lift

    # shadow under lid when lifted
    shadow_alpha = int((lift / 60) * 120)
    d.rectangle([box_left, lid_bottom, box_right, lid_bottom + 6], fill=(0,0,0,shadow_alpha))

    # box body
    d.rectangle([box_left, box_top, box_right, box_bottom], fill="#d94842", outline="#a22a2a", width=3)

    # lid (slightly rotated effect using a polygon)
    lid_inset = 6
    lid = [
        (box_left - lid_inset, lid_top),
        (box_right + lid_inset, lid_top),
        (box_right + lid_inset, lid_bottom),
        (box_left - lid_inset, lid_bottom),
    ]
    # tilt based on lift
    tilt = (f / (FRAMES - 1)) * 8  # degrees
    cx = (box_left + box_right) / 2
    cy = (lid_top + lid_bottom) / 2
    def rot(pt):
        x,y = pt
        a = math.radians(tilt)
        xr = cx + (x-cx)*math.cos(a) - (y-cy)*math.sin(a)
        yr = cy + (x-cx)*math.sin(a) + (y-cy)*math.cos(a)
        return (xr, yr)
    lid_rot = [rot(p) for p in lid]
    d.polygon(lid_rot, fill="#b5302f", outline="#8b1f1f")

    # ribbon (vertical + horizontal) - a little bounce when opening
    bounce = int(math.sin(f / FRAMES * math.pi) * 6)
    ribbon_color = "#ffd84d"
    center_x = (box_left + box_right) // 2
    d.rectangle([center_x - 8, box_top, center_x + 8, box_bottom], fill=ribbon_color)
    d.rectangle([box_left, box_top + 40 + bounce, box_right, box_top + 56 + bounce], fill=ribbon_color)

    # bow - two loops
    loop_offset = 18 + int((f / FRAMES) * 8)
    bow_top = lid_top + 6
    left_loop = [(center_x, bow_top), (center_x - loop_offset, bow_top + 10), (center_x, bow_top + 20)]
    right_loop = [(center_x, bow_top), (center_x + loop_offset, bow_top + 10), (center_x, bow_top + 20)]
    d.polygon(left_loop, fill="#ffeb99", outline="#c89d3a")
    d.polygon(right_loop, fill="#ffeb99", outline="#c89d3a")
    d.ellipse([center_x-6, bow_top+8, center_x+6, bow_top+20], fill="#ffeb99", outline="#c89d3a")

    # small sparkles around the gift
    for s in range(6):
        angle = (s * 60 + f*8) % 360
        r = 90 + (s % 2) * 20
        sx = int(center_x + math.cos(math.radians(angle)) * r)
        sy = int((box_top + box_bottom)/2 + math.sin(math.radians(angle)) * (r/2))
        size = 2 + (s % 3)
        d.ellipse([sx-size, sy-size, sx+size, sy+size], fill="#fff7cc")

    frames.append(im)

# save animated GIF
out_path = "gift.gif"
frames[0].save(out_path, save_all=True, append_images=frames[1:], duration=70, loop=0, optimize=True)
print(f"Saved {out_path}")
# ...existing code...gi