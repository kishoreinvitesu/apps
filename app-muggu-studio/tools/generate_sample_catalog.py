import argparse
import json
import math
import tempfile
from pathlib import Path

from PIL import Image, ImageDraw


ROOT = Path(__file__).resolve().parents[1]
CATALOG_PATH = ROOT / "assets" / "designs" / "catalog.json"
THUMBNAIL_DIR = ROOT / "assets" / "designs" / "thumbnails"
SIZE = 320
MARGIN = 28
SCHEMA_VERSION = 3


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
        polar(
            outer if index % 2 == 0 else inner,
            rotation + index * math.pi / points,
        )
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
            *[
                ([polar(0.14, angle), polar(0.42, angle)], False)
                for angle in [index * math.pi / 3 for index in range(6)]
            ],
        ],
        [
            *[(petal(index * math.pi / 4), True) for index in range(8)],
            (circle(0.11), True),
        ],
        [
            (circle(0.4), True),
            (circle(0.29), True),
            (circle(0.16), True),
            *[
                ([polar(0.17, angle), polar(0.4, angle)], False)
                for angle in [index * math.pi / 4 for index in range(8)]
            ],
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
            *[
                ([polar(0.18, angle), polar(0.42, angle)], False)
                for angle in [index * math.pi / 2 for index in range(4)]
            ],
        ],
        [
            (star(12, 0.42, 0.3), True),
            (circle(0.22), True),
            (circle(0.11), True),
            *[
                ([polar(0.22, angle), polar(0.42, angle)], False)
                for angle in [index * math.pi / 6 for index in range(12)]
            ],
        ],
        [
            (polygon(4, 0.4, math.pi / 4), True),
            (polygon(4, 0.4, 0), True),
            (circle(0.22), True),
            (polygon(8, 0.13), True),
        ],
    ]


def _point_command(point, command_type):
    return {"type": command_type, "x": point[0], "y": point[1]}


def _polyline_path(path_id, group_id, points, closed):
    commands = [
        _point_command(point, "moveTo" if index == 0 else "lineTo")
        for index, point in enumerate(points)
    ]
    if closed:
        commands.append({"type": "close"})
    return {"id": path_id, "groupId": group_id, "commands": commands}


def radial_flower(petal_count, outer_radius=0.36, petal_width=0.095):
    if not 3 <= petal_count <= 24:
        raise ValueError("petal_count must be between 3 and 24.")
    if not 0.15 <= outer_radius <= 0.42:
        raise ValueError("outer_radius must be between 0.15 and 0.42.")
    if not 0.03 <= petal_width <= 0.14:
        raise ValueError("petal_width must be between 0.03 and 0.14.")

    paths = []
    center = (0.5, 0.5)
    for index in range(petal_count):
        angle = -math.pi / 2 + index * 2 * math.pi / petal_count
        axis = (math.cos(angle), math.sin(angle))
        normal = (-axis[1], axis[0])
        tip = (
            center[0] + outer_radius * axis[0],
            center[1] + outer_radius * axis[1],
        )
        first_control = (
            center[0] + outer_radius * 0.42 * axis[0]
            + petal_width * 0.55 * normal[0],
            center[1] + outer_radius * 0.42 * axis[1]
            + petal_width * 0.55 * normal[1],
        )
        second_control = (
            tip[0] - outer_radius * 0.28 * axis[0]
            + petal_width * 0.2 * normal[0],
            tip[1] - outer_radius * 0.28 * axis[1]
            + petal_width * 0.2 * normal[1],
        )
        third_control = (
            tip[0] - outer_radius * 0.28 * axis[0]
            - petal_width * 0.2 * normal[0],
            tip[1] - outer_radius * 0.28 * axis[1]
            - petal_width * 0.2 * normal[1],
        )
        fourth_control = (
            center[0] + outer_radius * 0.42 * axis[0]
            - petal_width * 0.55 * normal[0],
            center[1] + outer_radius * 0.42 * axis[1]
            - petal_width * 0.55 * normal[1],
        )
        paths.append({
            "id": f"petal_path_{index + 1:02}",
            "groupId": f"petal_{index + 1:02}",
            "commands": [
                _point_command(center, "moveTo"),
                {
                    "type": "cubicTo",
                    "control1X": first_control[0],
                    "control1Y": first_control[1],
                    "control2X": second_control[0],
                    "control2Y": second_control[1],
                    "x": tip[0],
                    "y": tip[1],
                },
                {
                    "type": "cubicTo",
                    "control1X": third_control[0],
                    "control1Y": third_control[1],
                    "control2X": fourth_control[0],
                    "control2Y": fourth_control[1],
                    "x": center[0],
                    "y": center[1],
                },
                {"type": "close"},
            ],
        })
    return paths


def dot_grid(rows=5, columns=5, layout="square", margin=0.12):
    if rows < 3 or columns < 3 or rows > 15 or columns > 15:
        raise ValueError("Grid dimensions must be between 3 and 15.")
    if layout not in {"square", "rectangular", "staggered", "diamond"}:
        raise ValueError(f"Unsupported dot-grid layout: {layout}.")
    if not 0 <= margin < 0.3:
        raise ValueError("margin must be between 0 and 0.3.")

    dots = []
    for row in range(rows):
        row_offset = 0.5 if layout == "staggered" and row % 2 else 0
        row_width = columns - 1 + row_offset
        for column in range(columns):
            x = margin + (1 - 2 * margin) * (
                (column + row_offset) / row_width
            )
            y = margin + (1 - 2 * margin) * row / max(rows - 1, 1)
            if layout == "diamond":
                x, y = 0.5 + (x - 0.5 + y - 0.5) * 0.5, (
                    0.5 + (y - 0.5 - (x - 0.5)) * 0.5
                )
            dots.append([x, y])
    return {
        "layout": layout if layout != "square" else (
            "square" if rows == columns else "rectangular"
        ),
        "rows": rows,
        "columns": columns,
        "dots": dots,
    }


def dot_grid_diamonds(grid):
    rows = grid["rows"]
    columns = grid["columns"]
    if rows % 2 == 0 or columns % 2 == 0:
        raise ValueError("Diamond motifs require odd grid dimensions.")
    center_row = rows // 2
    center_column = columns // 2
    dots = grid["dots"]
    paths = []
    for depth in range(1, min(center_row, center_column) + 1):
        points = [
            dots[(center_row - depth) * columns + center_column],
            dots[center_row * columns + center_column + depth],
            dots[(center_row + depth) * columns + center_column],
            dots[center_row * columns + center_column - depth],
        ]
        group_id = f"ring_{depth:02}"
        paths.append(
            _polyline_path(f"{group_id}_path", group_id, points, True)
        )
    return paths


def _base_design(design_id, name, description, difficulty, paths, tags):
    return {
        "id": design_id,
        "localizedName": {"en": name},
        "localizedDescription": {"en": description},
        "region": None,
        "tradition": None,
        "technique": "geometric_lines",
        "localizedTechnique": {"en": "Geometric lines"},
        "difficulty": difficulty,
        "grid": None,
        "searchTags": tags,
        "thumbnail": f"assets/designs/thumbnails/{design_id}.webp",
        "paths": paths,
        "recipe": None,
        "lessonSteps": [],
        "rightsReview": {
            "status": "pending",
            "reviewer": "",
            "evidence": (
                "Original app-generated geometric vector; provenance and "
                "rights documentation pending."
            ),
        },
        "culturalReview": {"status": "pending", "reviewer": "", "evidence": ""},
        "localizationReview": {
            "status": "pending",
            "reviewer": "",
            "evidence": "",
        },
        "lessonReview": {"status": "pending", "reviewer": "", "evidence": ""},
    }


def build_catalog(radial_petals=8, grid_size=5, grid_layout="square"):
    difficulty = [
        "easy", "easy", "easy", "intermediate", "intermediate",
        "intermediate", "advanced", "advanced", "advanced", "advanced",
    ]
    tags = [
        "diamond", "star", "hexagon", "radial", "triangle",
        "spiral", "symmetry", "polygon", "star", "square",
    ]
    designs = []
    for index, paths in enumerate(sample_paths(), start=1):
        design_id = f"geometric_sample_{index:03}"
        vector_paths = [
            _polyline_path(
                f"path_{path_index + 1:02}",
                f"group_{path_index + 1:02}",
                points,
                closed,
            )
            for path_index, (points, closed) in enumerate(paths)
        ]
        designs.append(
            _base_design(
                design_id,
                f"Geometric Sample {index:02}",
                "Original geometric line pattern.",
                difficulty[index - 1],
                vector_paths,
                ["geometric", "sample", "line pattern", tags[index - 1]],
            )
        )

    radial_id = "generated_radial_001"
    radial = _base_design(
        radial_id,
        f"Original Radial Pattern {radial_petals}",
        "An original geometric flower generated from reusable parameters.",
        "easy",
        radial_flower(radial_petals),
        ["generated", "radial", "flower", "geometric"],
    )
    radial["recipe"] = {
        "generatorId": "radial_flower",
        "version": 1,
        "parameters": {
            "petalCount": radial_petals,
            "outerRadius": 0.36,
            "petalWidth": 0.095,
        },
    }
    designs.append(radial)

    grid_id = "generated_dot_grid_001"
    grid = dot_grid(grid_size, grid_size, grid_layout)
    dot_pattern = _base_design(
        grid_id,
        f"Original {grid_size} by {grid_size} Dot-grid Pattern",
        "An original geometric pattern arranged around an explicit dot grid.",
        "intermediate",
        dot_grid_diamonds(grid),
        ["generated", "dot grid", "geometric", "diamond"],
    )
    dot_pattern["grid"] = grid
    dot_pattern["recipe"] = {
        "generatorId": "dot_grid_diamonds",
        "version": 1,
        "parameters": {
            "rows": grid_size,
            "columns": grid_size,
            "layout": grid["layout"],
            "margin": 0.12,
        },
    }
    designs.append(dot_pattern)
    return designs


def _flatten_path(commands, curve_steps=16):
    points = []
    current = None
    start = None
    for command in commands:
        command_type = command["type"]
        if command_type == "moveTo":
            current = (command["x"], command["y"])
            start = current
            points.append(current)
        elif command_type == "lineTo":
            current = (command["x"], command["y"])
            points.append(current)
        elif command_type == "quadraticTo":
            origin = current
            control = (command["controlX"], command["controlY"])
            end = (command["x"], command["y"])
            for step in range(1, curve_steps + 1):
                t = step / curve_steps
                inv = 1 - t
                points.append((
                    inv * inv * origin[0]
                    + 2 * inv * t * control[0]
                    + t * t * end[0],
                    inv * inv * origin[1]
                    + 2 * inv * t * control[1]
                    + t * t * end[1],
                ))
            current = end
        elif command_type == "cubicTo":
            origin = current
            first = (command["control1X"], command["control1Y"])
            second = (command["control2X"], command["control2Y"])
            end = (command["x"], command["y"])
            for step in range(1, curve_steps + 1):
                t = step / curve_steps
                inv = 1 - t
                points.append((
                    inv**3 * origin[0]
                    + 3 * inv**2 * t * first[0]
                    + 3 * inv * t**2 * second[0]
                    + t**3 * end[0],
                    inv**3 * origin[1]
                    + 3 * inv**2 * t * first[1]
                    + 3 * inv * t**2 * second[1]
                    + t**3 * end[1],
                ))
            current = end
        elif command_type == "arcTo":
            center = (command["x"], command["y"])
            radius_x = command["radiusX"]
            radius_y = command["radiusY"]
            start_angle = command["startAngle"]
            sweep_angle = command["sweepAngle"]
            arc_start = (
                center[0] + radius_x * math.cos(start_angle),
                center[1] + radius_y * math.sin(start_angle),
            )
            if current != arc_start:
                points.append(arc_start)
            for step in range(1, curve_steps + 1):
                angle = start_angle + sweep_angle * step / curve_steps
                points.append((
                    center[0] + radius_x * math.cos(angle),
                    center[1] + radius_y * math.sin(angle),
                ))
            current = points[-1]
        elif command_type == "close" and start is not None:
            points.append(start)
            current = start
    return points


def draw_thumbnail(paths, destination, grid=None):
    image = Image.new("RGB", (SIZE, SIZE), "#FFF5E8")
    draw = ImageDraw.Draw(image)
    scale = SIZE - 2 * MARGIN
    if grid is not None:
        for x, y in grid["dots"]:
            point = (MARGIN + x * scale, MARGIN + y * scale)
            radius = 3
            draw.ellipse(
                (
                    point[0] - radius,
                    point[1] - radius,
                    point[0] + radius,
                    point[1] + radius,
                ),
                fill="#55775D",
            )
    for index, design_path in enumerate(paths):
        points = [
            (MARGIN + x * scale, MARGIN + y * scale)
            for x, y in _flatten_path(design_path["commands"])
        ]
        if len(points) < 2:
            continue
        draw.line(
            points,
            fill="#862B37" if index % 2 == 0 else "#D8A13B",
            width=4,
            joint="curve",
        )
    image.save(
        destination,
        format="WEBP",
        lossless=True,
        quality=100,
        method=6,
    )


def _catalog_json(designs):
    return json.dumps(
        {"schemaVersion": SCHEMA_VERSION, "designs": designs},
        indent=2,
        ensure_ascii=False,
    ) + "\n"


def _json_values_match(actual, expected):
    """Compare generated JSON while tolerating platform libm float noise."""
    if isinstance(actual, bool) or isinstance(expected, bool):
        return type(actual) is type(expected) and actual == expected
    if isinstance(actual, (int, float)) and isinstance(expected, (int, float)):
        return math.isclose(actual, expected, rel_tol=0.0, abs_tol=1e-12)
    if isinstance(actual, dict) and isinstance(expected, dict):
        return actual.keys() == expected.keys() and all(
            _json_values_match(actual[key], expected[key]) for key in actual
        )
    if isinstance(actual, list) and isinstance(expected, list):
        return len(actual) == len(expected) and all(
            _json_values_match(actual_item, expected_item)
            for actual_item, expected_item in zip(actual, expected)
        )
    return type(actual) is type(expected) and actual == expected


def _decoded_thumbnail(path):
    with Image.open(path) as image:
        image.load()
        converted = image.convert("RGB")
        return converted.size, converted.tobytes()


def write_catalog(catalog_path=CATALOG_PATH, thumbnail_dir=THUMBNAIL_DIR):
    designs = build_catalog()
    thumbnail_dir.mkdir(parents=True, exist_ok=True)
    for design in designs:
        draw_thumbnail(
            design["paths"],
            thumbnail_dir / f"{design['id']}.webp",
            design["grid"],
        )
    catalog_path.parent.mkdir(parents=True, exist_ok=True)
    catalog_path.write_text(_catalog_json(designs), encoding="utf-8")
    return designs


def main():
    parser = argparse.ArgumentParser(description="Generate the sample catalog.")
    parser.add_argument(
        "--check",
        action="store_true",
        help="Fail if the checked-in catalog differs from generated output.",
    )
    arguments = parser.parse_args()
    if arguments.check:
        with tempfile.TemporaryDirectory() as temporary_directory:
            temporary_path = Path(temporary_directory)
            expected_catalog = temporary_path / "catalog.json"
            expected_thumbnails = temporary_path / "thumbnails"
            write_catalog(expected_catalog, expected_thumbnails)
            catalog_matches = False
            if CATALOG_PATH.exists():
                try:
                    catalog_matches = _json_values_match(
                        json.loads(CATALOG_PATH.read_text(encoding="utf-8")),
                        json.loads(expected_catalog.read_text(encoding="utf-8")),
                    )
                except (OSError, json.JSONDecodeError):
                    catalog_matches = False
            if not catalog_matches:
                raise SystemExit(
                    "catalog.json differs from generated output; run "
                    "python tools/generate_sample_catalog.py."
                )

            expected_files = {
                path.name: path
                for path in expected_thumbnails.glob("*.webp")
            }
            actual_files = {
                path.name: path
                for path in THUMBNAIL_DIR.glob("*.webp")
            }
            missing = sorted(expected_files.keys() - actual_files.keys())
            extra = sorted(actual_files.keys() - expected_files.keys())
            if missing or extra:
                raise SystemExit(
                    f"Thumbnail files differ; missing={missing}, extra={extra}. "
                    "Run python tools/generate_sample_catalog.py."
                )
            mismatched = [
                name
                for name, expected_path in expected_files.items()
                if _decoded_thumbnail(expected_path)
                != _decoded_thumbnail(actual_files[name])
            ]
            if mismatched:
                raise SystemExit(
                    f"Thumbnail artwork differs: {sorted(mismatched)}. "
                    "Run python tools/generate_sample_catalog.py."
                )
        print("Catalog and decoded thumbnail artwork match generated output.")
        return
    designs = write_catalog()
    print(
        f"Wrote schema {SCHEMA_VERSION} with {len(designs)} designs "
        "and WebP thumbnails."
    )


if __name__ == "__main__":
    main()

