"""Tạo texture palette gradient kiểu Sushi Roll 3D (mặc định 32x32).

Mỗi màu gốc thành một cột swatch: đỉnh sáng hơn, đáy tối và đậm hơn.
Biên độ mặc định lấy từ số đo trên 172 palette của bộ SushiRoll3D:
trung vị V(đỉnh) - V(đáy) = 0.32, S(đáy) - S(đỉnh) = 0.13.

Ví dụ:
    python make_palette.py burger_palette.png --colors "#E8742C,#F2C14E,#3E8E3A,#7A3B1E,#F4E6C8"
    python make_palette.py sushi_palette.png --from-image concept.png --count 8

Ngoài PNG, script ghi thêm file .json cùng tên chứa vùng UV (gốc Unity: v=0 ở đáy)
của từng swatch để đặt UV trong Blender: dồn UV của mặt vào cột u_center và trải
theo chiều dọc trong [v_min, v_max].
"""

import argparse
import colorsys
import json
from pathlib import Path

from PIL import Image

MAX_COLUMNS_PER_ROW = 8


def parse_hex(value):
    value = value.strip().lstrip("#")
    if len(value) != 6:
        raise ValueError(f"Mã màu không hợp lệ: #{value}")
    return tuple(int(value[i:i + 2], 16) / 255 for i in (0, 2, 4))


def extract_colors(image_path, count):
    """Lấy `count` màu chủ đạo (bỏ pixel trong suốt), sắp theo độ phổ biến."""
    image = Image.open(image_path).convert("RGBA")
    image.thumbnail((256, 256))
    raw = image.tobytes()
    opaque = [tuple(raw[i:i + 3]) for i in range(0, len(raw), 4) if raw[i + 3] >= 128]
    if not opaque:
        raise ValueError("Ảnh không có pixel nào đủ đục để lấy màu")
    flat = Image.new("RGB", (len(opaque), 1))
    flat.putdata(opaque)
    quantized = flat.quantize(colors=count, method=Image.Quantize.MEDIANCUT)
    palette = quantized.getpalette()
    usage = sorted(quantized.getcolors(), reverse=True)
    return [tuple(c / 255 for c in palette[i * 3:i * 3 + 3]) for _, i in usage]


def clamp01(x):
    return min(1.0, max(0.0, x))


def gradient_color(base_rgb, t, value_range, saturation_range, hue_shift_deg):
    """t = 0 ở đỉnh swatch, t = 1 ở đáy."""
    h, s, v = colorsys.rgb_to_hsv(*base_rgb)
    k = t - 0.5
    v = clamp01(v - k * value_range)
    if s >= 0.15:  # màu trung tính (trắng/xám/đen) chỉ đổi độ sáng
        s = clamp01(s + k * saturation_range)
        h = (h + k * hue_shift_deg / 360) % 1.0
    return tuple(round(c * 255) for c in colorsys.hsv_to_rgb(h, s, v))


def build_palette(colors, size, value_range, saturation_range, hue_shift_deg):
    rows = 1 if len(colors) <= MAX_COLUMNS_PER_ROW else 2
    per_row = -(-len(colors) // rows)
    image = Image.new("RGB", (size, size), (255, 255, 255))
    pixels = image.load()
    swatches = []
    row_height = size // rows
    for index, base in enumerate(colors):
        row, column = divmod(index, per_row)
        x0 = column * size // per_row
        x1 = (column + 1) * size // per_row
        y0 = row * row_height
        y1 = y0 + row_height
        for y in range(y0, y1):
            t = (y - y0) / max(1, row_height - 1)
            rgb = gradient_color(base, t, value_range, saturation_range, hue_shift_deg)
            for x in range(x0, x1):
                pixels[x, y] = rgb
        # Lùi nửa texel để filter bilinear không lấy màu cột bên cạnh.
        half_texel = 0.5 / size
        swatches.append({
            "index": index,
            "base_hex": "#%02X%02X%02X" % tuple(round(c * 255) for c in base),
            "u_center": (x0 + x1) / 2 / size,
            "u_min": x0 / size + half_texel,
            "u_max": x1 / size - half_texel,
            "v_min": 1 - y1 / size + half_texel,
            "v_max": 1 - y0 / size - half_texel,
        })
    return image, swatches


def main():
    parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument("output", type=Path, help="File PNG đầu ra")
    source = parser.add_mutually_exclusive_group(required=True)
    source.add_argument("--colors", help="Danh sách mã hex, cách nhau bởi dấu phẩy")
    source.add_argument("--from-image", type=Path, help="Ảnh concept để trích màu chủ đạo")
    parser.add_argument("--count", type=int, default=8, help="Số màu khi dùng --from-image (mặc định 8)")
    parser.add_argument("--size", type=int, default=32, help="Kích thước texture vuông (mặc định 32)")
    parser.add_argument("--value-range", type=float, default=0.32, help="Chênh độ sáng đỉnh-đáy (mặc định 0.32)")
    parser.add_argument("--saturation-range", type=float, default=0.13, help="Chênh độ bão hòa đáy-đỉnh (mặc định 0.13)")
    parser.add_argument("--hue-shift", type=float, default=0.0, help="Lệch hue đáy so với đỉnh, độ (mặc định 0)")
    args = parser.parse_args()

    try:
        if args.colors:
            colors = [parse_hex(c) for c in args.colors.split(",") if c.strip()]
        else:
            colors = extract_colors(args.from_image, args.count)
    except (OSError, ValueError) as error:
        parser.error(str(error))
    if not 1 <= len(colors) <= 2 * MAX_COLUMNS_PER_ROW:
        parser.error(f"Cần từ 1 đến {2 * MAX_COLUMNS_PER_ROW} màu, nhận {len(colors)}")
    if args.size < 2 * MAX_COLUMNS_PER_ROW:
        parser.error(f"--size phải >= {2 * MAX_COLUMNS_PER_ROW}")

    image, swatches = build_palette(colors, args.size, args.value_range, args.saturation_range, args.hue_shift)
    image.save(args.output)
    args.output.with_suffix(".json").write_text(json.dumps(swatches, indent=2), encoding="utf-8")
    print(f"Đã ghi {args.output} ({args.size}x{args.size}, {len(colors)} swatch) và {args.output.with_suffix('.json').name}")


if __name__ == "__main__":
    main()
