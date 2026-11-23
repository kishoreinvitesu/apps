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


def _base_design(
    design_id,
    name,
    description,
    difficulty,
    paths,
    tags,
    localized_name=None,
    localized_description=None,
    technique="geometric_lines",
    localized_technique=None,
):
    return {
        "id": design_id,
        "localizedName": localized_name or {"en": name},
        "localizedDescription": localized_description or {"en": description},
        "region": None,
        "tradition": None,
        "technique": technique,
        "localizedTechnique": localized_technique or {"en": "Geometric lines"},
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

    # ── Additional traditional dot-grid and motif designs ───────────────────
    extra_configs = [
        (
            "dot_grid_sample_001",
            "3×3 Chukkala Muggu (Little Star)",
            {"en": "3×3 Chukkala Muggu (Little Star)", "te": "3×3 చుక్కల ముగ్గు (చిన్న నక్షత్రం)", "ta": "3×3 புள்ளி கோலம் (சிறு நட்சத்திரம்)"},
            "A traditional 4-point star motif connecting corner loops on a 3 by 3 dot grid.",
            {"en": "A traditional 4-point star motif connecting corner loops on a 3 by 3 dot grid.", "te": "3x3 చుక్కల పై మూలల లూప్‌లతో రూపొందించిన సాంప్రదాయ నక్షత్ర ముగ్గు.", "ta": "3x3 புள்ளிகளில் மூலை சுழிகளுடன் கூடிய பாரம்பரிய நட்சத்திரக் கோலம்."},
            "easy",
            dot_grid(3, 3, "square"),
            dot_grid_chikka_star,
            ["dot grid", "chukkala", "muggu", "kolam", "3x3", "star", "beginner"],
        ),
        (
            "dot_grid_sample_002",
            "5×5 Pulli Kolam (Lotus Nelavu)",
            {"en": "5×5 Pulli Kolam (Lotus Nelavu)", "te": "5×5 చుక్కల ముగ్గు (కమలం)", "ta": "5×5 புள்ளி கோலம் (தாமரை நிலவு)"},
            "A classic stepped lotus and floral contour embracing a 5 by 5 dot grid.",
            {"en": "A classic stepped lotus and floral contour embracing a 5 by 5 dot grid.", "te": "5x5 చుక్కలపై కమల పుష్ప ఆకృతితో అమర్చిన ముగ్గు.", "ta": "5x5 புள்ளிகளில் அமைந்த பாரம்பரிய தாமரை இதழ் கோலம்."},
            "easy",
            dot_grid(5, 5, "square"),
            dot_grid_lotus_nelavu,
            ["dot grid", "pulli", "kolam", "lotus", "nelavu", "5x5", "flower"],
        ),
        (
            "dot_grid_sample_003",
            "5×5 Sikku Kolam (Brahma Mudi)",
            {"en": "5×5 Sikku Kolam (Brahma Mudi)", "te": "5×5 చిక్కు ముగ్గు (బ్రహ్మముడి)", "ta": "5×5 சிக்கு கோலம் (பிரம்முடி)"},
            "An unbroken auspicious knot looping symmetrically through a 5 by 5 dot grid.",
            {"en": "An unbroken auspicious knot looping symmetrically through a 5 by 5 dot grid.", "te": "5x5 చుక్కల మధ్య తిరుగుతూ సాగే పవిత్రమైన బ్రహ్మముడి చిక్కు ముగ్గు.", "ta": "5x5 புள்ளிகளைச் சுற்றி வளைந்து வரும் மங்களகரமான பிரம்முடி சிக்கு கோலம்."},
            "intermediate",
            dot_grid(5, 5, "square"),
            dot_grid_brahma_mudi,
            ["dot grid", "sikku", "kolam", "brahma mudi", "knot", "5x5", "traditional"],
        ),
        (
            "dot_grid_sample_004",
            "5×5 Padi Muggu (Step Diamond)",
            {"en": "5×5 Padi Muggu (Step Diamond)", "te": "5×5 పడి ముగ్గు (మెట్ల వజ్రం)", "ta": "5×5 படி கோலம் (படி வைரம்)"},
            "Concentric threshold stepped diamonds with auspicious corner lines.",
            {"en": "Concentric threshold stepped diamonds with auspicious corner lines.", "te": "గడప వద్ద వేసే సాంప్రదాయ మెట్ల వజ్ర పడి ముగ్గు.", "ta": "வாசல் படியில் போடும் மங்களகரமான படி வைரக் கோலம்."},
            "easy",
            dot_grid(5, 5, "square"),
            dot_grid_padi_muggu,
            ["dot grid", "padi", "muggu", "kolam", "step", "diamond", "5x5"],
        ),
        (
            "dot_grid_sample_005",
            "5×5 Deepam Muggu (Four Lamps)",
            {"en": "5×5 Deepam Muggu (Four Lamps)", "te": "5×5 దీపం ముగ్గు (నాలుగు దీపాలు)", "ta": "5×5 தீபம் கோலம் (நான்கு விளக்குகள்)"},
            "Four festive oil lamps radiating outward from a central flower on 5 by 5 dots.",
            {"en": "Four festive oil lamps radiating outward from a central flower on 5 by 5 dots.", "te": "మధ్య కమలం నుండి నాలుగు దిక్కులా వెలిగే దీపాలతో కూడిన ముగ్గు.", "ta": "மைய மலரிலிருந்து நான்கு திசைகளிலும் ஒளிரும் அகல் விளக்குகள் கொண்ட கோலம்."},
            "intermediate",
            dot_grid(5, 5, "square"),
            dot_grid_deepam,
            ["dot grid", "deepam", "diya", "lamp", "festival", "karthika", "5x5"],
        ),
        (
            "dot_grid_sample_006",
            "7×7 Suzhi Kolam (Star of Harmony)",
            {"en": "7×7 Suzhi Kolam (Star of Harmony)", "te": "7×7 సుడి ముగ్గు (సామరస్య నక్షత్రం)", "ta": "7×7 சுழி கோலம் (இசைவு நட்சத்திரம்)"},
            "Intricate multi-loop intertwining knot rings across a 7 by 7 dot grid.",
            {"en": "Intricate multi-loop intertwining knot rings across a 7 by 7 dot grid.", "te": "7x7 చుక్కలపై వలయాలుగా అల్లుకున్న క్లిష్టమైన సుడి ముగ్గు.", "ta": "7x7 புள்ளிகளில் பின்னப்பட்ட நுணுக்கமான சுழி கோல நட்சத்திரம்."},
            "advanced",
            dot_grid(7, 7, "square"),
            dot_grid_suzhi_star,
            ["dot grid", "suzhi", "sikku", "kolam", "7x7", "advanced", "star"],
        ),
        (
            "dot_grid_sample_007",
            "7×7 Sankranti Ratham (Chariot)",
            {"en": "7×7 Sankranti Ratham (Chariot)", "te": "7×7 సంక్రాంతి రథం ముగ్గు", "ta": "7×7 பொங்கல் தேர் கோலம்"},
            "A festive temple chariot with wheels, canopy gopuram, and pinnacle flag on 7 by 7 dots.",
            {"en": "A festive temple chariot with wheels, canopy gopuram, and pinnacle flag on 7 by 7 dots.", "te": "సంక్రాంతి పండుగ సందర్భంగా వేసే సాంప్రదాయ రథం ముగ్గు.", "ta": "மார்கழி, பொங்கல் திருநாளில் வரையும் மங்களகரமான தேர் கோலம்."},
            "advanced",
            dot_grid(7, 7, "square"),
            dot_grid_ratham,
            ["dot grid", "ratham", "chariot", "sankranti", "pongal", "7x7", "festival"],
        ),
        (
            "dot_grid_sample_008",
            "5×5 Hridaya Kamalam (8-Petal Lotus)",
            {"en": "5×5 Hridaya Kamalam (8-Petal Lotus)", "te": "5×5 హృదయ కమలం (అష్టదళ పద్మం)", "ta": "5×5 இதய கமலம் (எட்டு இதழ் தாமரை)"},
            "Sacred 8-petal lotus drawn with continuous loops from center to perimeter dots.",
            {"en": "Sacred 8-petal lotus drawn with continuous loops from center to perimeter dots.", "te": "పూజాగదుల్లో వేసే పవిత్రమైన అష్టదళ హృదయ కమల ముగ్గు.", "ta": "பூஜை அறைகளில் வரையும் மங்களகரமான எட்டு இதழ் இதய கமலக் கோலம்."},
            "intermediate",
            dot_grid(5, 5, "square"),
            dot_grid_hridaya_kamalam,
            ["dot grid", "hridaya kamalam", "lotus", "pooja", "spiritual", "5x5"],
        ),
    ]

    for (
        extra_id,
        name,
        loc_name,
        desc,
        loc_desc,
        diff,
        grid_obj,
        generator_fn,
        extra_tags,
    ) in extra_configs:
        design_item = _base_design(
            extra_id,
            name,
            desc,
            diff,
            generator_fn(grid_obj),
            extra_tags,
            localized_name=loc_name,
            localized_description=loc_desc,
        )
        design_item["grid"] = grid_obj
        designs.append(design_item)

    return designs


def dot_grid_chikka_star(grid):
    cols = grid["columns"]
    dots = grid["dots"]

    def pt(r, c):
        return dots[r * cols + c]

    return [
        _polyline_path(
            "star_center",
            "group_center",
            [pt(0, 1), pt(1, 2), pt(2, 1), pt(1, 0)],
            True,
        ),
        _polyline_path(
            "corner_nw",
            "group_corners",
            [pt(0, 1), pt(0, 0), pt(1, 0)],
            True,
        ),
        _polyline_path(
            "corner_ne",
            "group_corners",
            [pt(0, 1), pt(0, 2), pt(1, 2)],
            True,
        ),
        _polyline_path(
            "corner_se",
            "group_corners",
            [pt(2, 1), pt(2, 2), pt(1, 2)],
            True,
        ),
        _polyline_path(
            "corner_sw",
            "group_corners",
            [pt(2, 1), pt(2, 0), pt(1, 0)],
            True,
        ),
    ]


def dot_grid_lotus_nelavu(grid):
    cols = grid["columns"]
    dots = grid["dots"]

    def pt(r, c):
        return dots[r * cols + c]

    outer = [
        pt(0, 1),
        pt(0, 2),
        pt(0, 3),
        pt(1, 4),
        pt(2, 4),
        pt(3, 4),
        pt(4, 3),
        pt(4, 2),
        pt(4, 1),
        pt(3, 0),
        pt(2, 0),
        pt(1, 0),
    ]
    return [
        _polyline_path(
            "lotus_core",
            "group_core",
            [pt(1, 2), pt(2, 3), pt(3, 2), pt(2, 1)],
            True,
        ),
        _polyline_path(
            "petal_north",
            "group_petals",
            [pt(1, 1), pt(0, 2), pt(1, 3), pt(2, 2)],
            True,
        ),
        _polyline_path(
            "petal_east",
            "group_petals",
            [pt(1, 3), pt(2, 4), pt(3, 3), pt(2, 2)],
            True,
        ),
        _polyline_path(
            "petal_south",
            "group_petals",
            [pt(3, 3), pt(4, 2), pt(3, 1), pt(2, 2)],
            True,
        ),
        _polyline_path(
            "petal_west",
            "group_petals",
            [pt(3, 1), pt(2, 0), pt(1, 1), pt(2, 2)],
            True,
        ),
        _polyline_path("outer_frame", "group_frame", outer, True),
    ]


def dot_grid_brahma_mudi(grid):
    cols = grid["columns"]
    dots = grid["dots"]

    def pt(r, c):
        return dots[r * cols + c]

    return [
        _polyline_path(
            "mudi_center",
            "group_center",
            [pt(1, 2), pt(2, 3), pt(3, 2), pt(2, 1)],
            True,
        ),
        _polyline_path(
            "loop_nw",
            "group_loops",
            [pt(0, 2), pt(1, 1), pt(2, 0), pt(1, 2)],
            True,
        ),
        _polyline_path(
            "loop_ne",
            "group_loops",
            [pt(0, 2), pt(1, 3), pt(2, 4), pt(1, 2)],
            True,
        ),
        _polyline_path(
            "loop_se",
            "group_loops",
            [pt(4, 2), pt(3, 3), pt(2, 4), pt(3, 2)],
            True,
        ),
        _polyline_path(
            "loop_sw",
            "group_loops",
            [pt(4, 2), pt(3, 1), pt(2, 0), pt(3, 2)],
            True,
        ),
        _polyline_path(
            "diag_nw_se",
            "group_diags",
            [pt(0, 0), pt(1, 1), pt(3, 3), pt(4, 4)],
            False,
        ),
        _polyline_path(
            "diag_ne_sw",
            "group_diags",
            [pt(0, 4), pt(1, 3), pt(3, 1), pt(4, 0)],
            False,
        ),
    ]


def dot_grid_padi_muggu(grid):
    cols = grid["columns"]
    dots = grid["dots"]

    def pt(r, c):
        return dots[r * cols + c]

    return [
        _polyline_path(
            "padi_inner",
            "group_diamonds",
            [pt(1, 2), pt(2, 3), pt(3, 2), pt(2, 1)],
            True,
        ),
        _polyline_path(
            "padi_mid",
            "group_diamonds",
            [pt(1, 1), pt(1, 3), pt(3, 3), pt(3, 1)],
            True,
        ),
        _polyline_path(
            "padi_outer",
            "group_diamonds",
            [pt(0, 2), pt(2, 4), pt(4, 2), pt(2, 0)],
            True,
        ),
        _polyline_path(
            "step_nw", "group_steps", [pt(0, 1), pt(1, 1), pt(1, 0)], False
        ),
        _polyline_path(
            "step_ne", "group_steps", [pt(0, 3), pt(1, 3), pt(1, 4)], False
        ),
        _polyline_path(
            "step_se", "group_steps", [pt(4, 3), pt(3, 3), pt(3, 4)], False
        ),
        _polyline_path(
            "step_sw", "group_steps", [pt(4, 1), pt(3, 1), pt(3, 0)], False
        ),
    ]


def dot_grid_deepam(grid):
    cols = grid["columns"]
    dots = grid["dots"]

    def pt(r, c):
        return dots[r * cols + c]

    return [
        _polyline_path(
            "center_flower",
            "group_center",
            [pt(1, 2), pt(2, 3), pt(3, 2), pt(2, 1)],
            True,
        ),
        _polyline_path(
            "diya_north_base",
            "group_lamps",
            [pt(1, 1), pt(1, 2), pt(1, 3), pt(0, 2)],
            True,
        ),
        _polyline_path(
            "diya_north_flame",
            "group_flames",
            [pt(0, 1), pt(0, 2), pt(0, 3)],
            True,
        ),
        _polyline_path(
            "diya_east_base",
            "group_lamps",
            [pt(1, 3), pt(2, 3), pt(3, 3), pt(2, 4)],
            True,
        ),
        _polyline_path(
            "diya_east_flame",
            "group_flames",
            [pt(1, 4), pt(2, 4), pt(3, 4)],
            True,
        ),
        _polyline_path(
            "diya_south_base",
            "group_lamps",
            [pt(3, 1), pt(3, 2), pt(3, 3), pt(4, 2)],
            True,
        ),
        _polyline_path(
            "diya_south_flame",
            "group_flames",
            [pt(4, 1), pt(4, 2), pt(4, 3)],
            True,
        ),
        _polyline_path(
            "diya_west_base",
            "group_lamps",
            [pt(1, 1), pt(2, 1), pt(3, 1), pt(2, 0)],
            True,
        ),
        _polyline_path(
            "diya_west_flame",
            "group_flames",
            [pt(1, 0), pt(2, 0), pt(3, 0)],
            True,
        ),
    ]


def dot_grid_suzhi_star(grid):
    cols = grid["columns"]
    dots = grid["dots"]

    def pt(r, c):
        return dots[r * cols + c]

    return [
        _polyline_path(
            "suzhi_inner",
            "group_rings",
            [pt(2, 3), pt(3, 4), pt(4, 3), pt(3, 2)],
            True,
        ),
        _polyline_path(
            "suzhi_mid",
            "group_rings",
            [pt(1, 3), pt(3, 5), pt(5, 3), pt(3, 1)],
            True,
        ),
        _polyline_path(
            "suzhi_outer",
            "group_rings",
            [pt(0, 3), pt(3, 6), pt(6, 3), pt(3, 0)],
            True,
        ),
        _polyline_path(
            "suzhi_nw",
            "group_corners",
            [pt(0, 3), pt(1, 1), pt(3, 0), pt(2, 2)],
            True,
        ),
        _polyline_path(
            "suzhi_ne",
            "group_corners",
            [pt(0, 3), pt(1, 5), pt(3, 6), pt(2, 4)],
            True,
        ),
        _polyline_path(
            "suzhi_se",
            "group_corners",
            [pt(6, 3), pt(5, 5), pt(3, 6), pt(4, 4)],
            True,
        ),
        _polyline_path(
            "suzhi_sw",
            "group_corners",
            [pt(6, 3), pt(5, 1), pt(3, 0), pt(4, 2)],
            True,
        ),
    ]


def dot_grid_ratham(grid):
    cols = grid["columns"]
    dots = grid["dots"]

    def pt(r, c):
        return dots[r * cols + c]

    return [
        _polyline_path(
            "ratham_flag", "group_flag", [pt(0, 3), pt(0, 4), pt(1, 3)], True
        ),
        _polyline_path(
            "ratham_dome",
            "group_dome",
            [pt(1, 2), pt(0, 3), pt(1, 4), pt(2, 5), pt(2, 1)],
            True,
        ),
        _polyline_path(
            "ratham_body",
            "group_body",
            [pt(2, 1), pt(4, 1), pt(4, 5), pt(2, 5)],
            True,
        ),
        _polyline_path(
            "ratham_pillar", "group_body", [pt(2, 3), pt(4, 3)], False
        ),
        _polyline_path(
            "ratham_cross", "group_body", [pt(3, 2), pt(3, 4)], False
        ),
        _polyline_path(
            "ratham_base",
            "group_base",
            [pt(4, 0), pt(5, 0), pt(5, 6), pt(4, 6)],
            True,
        ),
        _polyline_path(
            "wheel_left",
            "group_wheels",
            [pt(5, 1), pt(5, 2), pt(6, 2), pt(6, 1)],
            True,
        ),
        _polyline_path(
            "spoke_left", "group_wheels", [pt(5, 1), pt(6, 2)], False
        ),
        _polyline_path(
            "wheel_right",
            "group_wheels",
            [pt(5, 4), pt(5, 5), pt(6, 5), pt(6, 4)],
            True,
        ),
        _polyline_path(
            "spoke_right", "group_wheels", [pt(5, 4), pt(6, 5)], False
        ),
        _polyline_path(
            "rope_left", "group_ropes", [pt(5, 0), pt(6, 0)], False
        ),
        _polyline_path(
            "rope_right", "group_ropes", [pt(5, 6), pt(6, 6)], False
        ),
    ]


def dot_grid_hridaya_kamalam(grid):
    cols = grid["columns"]
    dots = grid["dots"]

    def pt(r, c):
        return dots[r * cols + c]

    center = pt(2, 2)
    petals = [
        [center, pt(1, 2), pt(0, 2), pt(1, 1), center],
        [center, pt(1, 3), pt(0, 3), pt(1, 4), center],
        [center, pt(2, 3), pt(2, 4), pt(3, 3), center],
        [center, pt(3, 3), pt(4, 4), pt(4, 3), center],
        [center, pt(3, 2), pt(4, 2), pt(3, 1), center],
        [center, pt(3, 1), pt(4, 0), pt(3, 0), center],
        [center, pt(2, 1), pt(2, 0), pt(1, 1), center],
        [center, pt(1, 1), pt(0, 0), pt(0, 1), center],
    ]
    return [
        _polyline_path(
            f"kamalam_petal_{idx:02}", "group_petals", petal_pts, True
        )
        for idx, petal_pts in enumerate(petals, start=1)
    ]


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

