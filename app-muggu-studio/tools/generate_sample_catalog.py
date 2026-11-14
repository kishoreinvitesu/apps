import json
import math
from pathlib import Path

from PIL import Image, ImageDraw


ROOT = Path(__file__).resolve().parents[1]
CATALOG_PATH = ROOT / "assets" / "designs" / "catalog.json"
THUMBNAIL_DIR = ROOT / "assets" / "designs" / "thumbnails"
SIZE = 320
MARGIN = 28


def polar(radius, angle, center=(0.5, 0.5)):
    return [
        center[0] + radius * math.cos(angle),
        center[1] + radius * math.sin(angle),
    ]


def polygon(sides, radius, rotation=-math.pi / 2, center=(0.5, 0.5)):
    return [
        polar(radius, rotation + index * 2 * math.pi / sides, center)
        for index in range(sides)
    ]


def star(points, outer, inner, rotation=-math.pi / 2):
    return [
        polar(outer if index % 2 == 0 else inner,
              rotation + index * math.pi / points)
        for index in range(points * 2)
    ]


def circle(radius, points=48, center=(0.5, 0.5)):
    return [
        polar(radius, index * 2 * math.pi / points, center)
        for index in range(points)
    ]


def petal(angle, distance=0.2, length=0.22, width=0.09):
    center = (0.5 + distance * math.cos(angle), 0.5 + distance * math.sin(angle))
    return [
        [
            center[0] + length * math.cos(angle) * math.cos(t)
            - width * math.sin(angle) * math.sin(t),
            center[1] + length * math.sin(angle) * math.cos(t)
            + width * math.cos(angle) * math.sin(t),
        ]
        for t in [index * 2 * math.pi / 20 for index in range(20)]
    ]


def make_strokes(paths):
    return [
        {
            "id": f"stroke_{index + 1:02}",
            "points": points,
            "closed": closed,
        }
        for index, (points, closed) in enumerate(paths)
    ]


def sample_paths():
    return [
        [
            (polygon(4, 0.39, math.pi / 4), True),
            (polygon(4, 0.27, 0), True),
            ([[0.5, 0.11], [0.5, 0.89]], False),
            ([[0.11, 0.5], [0.89, 0.5]], False),
        ],
        [
            (star(8, 0.42, 0.22), True),
            (circle(0.13), True),
            ([[0.5, 0.08], [0.5, 0.92]], False),
            ([[0.08, 0.5], [0.92, 0.5]], False),
        ],
        [
            (polygon(6, 0.42), True),
            (polygon(6, 0.28), True),
            (polygon(6, 0.14), True),
            *[( [polar(0.14, angle), polar(0.42, angle)], False)
              for angle in [index * math.pi / 3 for index in range(6)]],
        ],
        [
            *[(petal(index * math.pi / 4), True) for index in range(8)],
            (circle(0.11), True),
        ],
        [
            (circle(0.4), True),
            (circle(0.29), True),
            (circle(0.16), True),
            *[([polar(0.17, angle), polar(0.4, angle)], False)
              for angle in [index * math.pi / 4 for index in range(8)]],
        ],
        [
            (polygon(3, 0.42), True),
            (polygon(3, 0.42, math.pi / 2), True),
            (polygon(6, 0.22), True),
        ],
        [
            (
                [
                    [0.12, 0.12], [0.88, 0.12], [0.88, 0.88],
                    [0.22, 0.88], [0.22, 0.22], [0.78, 0.22],
                    [0.78, 0.78], [0.32, 0.78], [0.32, 0.32],
                    [0.68, 0.32], [0.68, 0.68], [0.42, 0.68],
                    [0.42, 0.42], [0.58, 0.42], [0.58, 0.58],
                    [0.5, 0.58],
                ],
                False,
            ),
        ],
        [
            (polygon(4, 0.42, math.pi / 4), True),
            (polygon(4, 0.3), True),
            (polygon(4, 0.18, math.pi / 4), True),
            *[([polar(0.18, angle), polar(0.42, angle)], False)
              for angle in [index * math.pi / 2 for index in range(4)]],
        ],
        [
            (star(12, 0.42, 0.3), True),
            (circle(0.22), True),
            (circle(0.11), True),
            *[([polar(0.22, angle), polar(0.42, angle)], False)
              for angle in [index * math.pi / 6 for index in range(12)]],
        ],
        [
            (polygon(4, 0.4, math.pi / 4), True),
            (polygon(4, 0.4, 0), True),
            (circle(0.22), True),
            (polygon(8, 0.13), True),
        ],
    ]


def draw_thumbnail(strokes, destination):
    image = Image.new("RGB", (SIZE, SIZE), "#FFF5E8")
    draw = ImageDraw.Draw(image)
    scale = SIZE - 2 * MARGIN
    for index, stroke in enumerate(strokes):
        points = [
            (MARGIN + point[0] * scale, MARGIN + point[1] * scale)
            for point in stroke["points"]
        ]
        if stroke["closed"]:
            points.append(points[0])
        draw.line(
            points,
            fill="#862B37" if index % 2 == 0 else "#D8A13B",
            width=4,
            joint="curve",
        )
    image.save(destination, format="WEBP", quality=90, method=6)


def main():
    THUMBNAIL_DIR.mkdir(parents=True, exist_ok=True)
    difficulty = ["easy", "easy", "easy", "intermediate", "intermediate",
                  "intermediate", "advanced", "advanced", "advanced", "advanced"]
    designs = []
    for index, paths in enumerate(sample_paths(), start=1):
        design_id = f"geometric_sample_{index:03}"
        strokes = make_strokes(paths)
        thumbnail = f"assets/designs/thumbnails/{design_id}.webp"
        designs.append({
            "id": design_id,
            "localizedName": {"en": f"Geometric Sample {index:02}"},
            "localizedDescription": {
                "en": "Original geometric line pattern."
            },
            "region": None,
            "tradition": None,
            "technique": "geometric_lines",
            "difficulty": difficulty[index - 1],
            "grid": None,
            "searchTags": [
                "geometric", "sample", "line pattern",
                ["diamond", "star", "hexagon", "radial", "triangle",
                 "spiral", "symmetry", "polygon", "star", "square"][index - 1],
            ],
            "thumbnail": thumbnail,
            "strokes": strokes,
            "contentReview": {
                "status": "pending",
                "reviewer": "",
                "sourceOrPermission": "Original app-generated geometric vector; no regional or traditional attribution assigned.",
            },
        })
        draw_thumbnail(strokes, ROOT / thumbnail)

    CATALOG_PATH.parent.mkdir(parents=True, exist_ok=True)
    CATALOG_PATH.write_text(
        json.dumps({"schemaVersion": 1, "designs": designs}, indent=2) + "\n",
        encoding="utf-8",
    )
    print(f"Wrote {len(designs)} designs and {len(designs)} WebP thumbnails.")


if __name__ == "__main__":
    main()
