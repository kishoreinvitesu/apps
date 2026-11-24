import json
import math
import tempfile
import unittest
from pathlib import Path

from PIL import Image

from tools import generate_sample_catalog as generator


class GenerateSampleCatalogTests(unittest.TestCase):
    def test_every_design_has_a_lesson_and_explicit_provenance(self):
        catalog = generator.build_catalog()
        referenced_ids = {
            "dot_grid_sample_001",
            "dot_grid_sample_002",
            "dot_grid_sample_003",
            "dot_grid_sample_004",
            "dot_grid_sample_005",
        }
        for design in catalog:
            for removed_field in (
                "region",
                "tradition",
                "localizedRegion",
                "localizedTradition",
                "aiPractice",
                "rightsReview",
                "culturalReview",
                "localizationReview",
                "lessonReview",
            ):
                self.assertNotIn(removed_field, design)
            self.assertGreater(len(design["lessonSteps"]), 0)
            self.assertEqual(
                design["provenance"]["origin"],
                "system_generated",
            )
            if design["id"] in referenced_ids:
                self.assertEqual(len(design["provenance"]["sources"]), 2)
                self.assertIn(
                    "sahapedia.org",
                    design["provenance"]["sources"][0],
                )
                self.assertIn(
                    "tamilnadutourism.tn.gov.in",
                    design["provenance"]["sources"][1],
                )
                self.assertIn("General Kolam background", design["provenance"]["note"])
            else:
                self.assertEqual(design["provenance"]["sources"], [])

            group_ids = {path["groupId"] for path in design["paths"]}
            taught_groups = set()
            for step in design["lessonSteps"]:
                self.assertTrue(step["groupIds"])
                self.assertTrue(set(step["groupIds"]).issubset(group_ids))
                taught_groups.update(step["groupIds"])
                self.assertEqual(set(step["instruction"]), {"en", "te", "ta"})
                self.assertTrue(
                    all(text.strip() for text in step["instruction"].values())
                )
            self.assertEqual(taught_groups, group_ids)

    def test_catalog_comparison_tolerates_only_cross_platform_float_noise(self):
        generated = {"point": [0.3, {"radius": 0.125}]}
        platform_variant = {
            "point": [math.nextafter(0.3, math.inf), {"radius": 0.125}]
        }

        self.assertTrue(
            generator._json_values_match(platform_variant, generated)
        )
        self.assertFalse(
            generator._json_values_match(
                {"point": [0.30000001, {"radius": 0.125}]}, generated
            )
        )
        self.assertFalse(
            generator._json_values_match(
                {"point": [0.3, {"radius": 0.125}], "extra": True},
                generated,
            )
        )

    def test_build_catalog_is_deterministic_and_normalized(self):
        catalog = generator.build_catalog(
            radial_petals=12,
            grid_size=7,
            grid_layout="staggered",
        )

        self.assertEqual(len(catalog), 67)
        ids = [design["id"] for design in catalog]
        names = [
            design["localizedName"]["en"]
            for design in catalog
        ]
        self.assertEqual(len(ids), len(set(ids)))
        self.assertEqual(len(names), len(set(names)))
        original_designs = [
            design
            for design in catalog
            if design["id"].startswith("original_")
        ]
        self.assertEqual(len(original_designs), 40)
        for design in original_designs:
            self.assertEqual(design["provenance"]["origin"], "system_generated")
            self.assertEqual(design["construction"], "illustrated")
            self.assertIsNone(design["grid"])
        self.assertEqual(
            generator._catalog_json(catalog),
            generator._catalog_json(
                generator.build_catalog(
                    radial_petals=12,
                    grid_size=7,
                    grid_layout="staggered",
                )
            ),
        )
        for design in catalog:
            if design["construction"] == "illustrated":
                self.assertIsNone(design["grid"])
            else:
                self.assertEqual(design["construction"], "dot_guided")
                self.assertIsNotNone(design["grid"])
                grid_dots = {
                    tuple(point)
                    for point in design["grid"]["dots"]
                }
                for path in design["paths"]:
                    for command in path["commands"]:
                        if command["type"] == "close":
                            continue
                        self.assertIn(
                            command["type"],
                            ("moveTo", "lineTo", "cubicTo"),
                        )
                        self.assertIn((command["x"], command["y"]), grid_dots)
            for path in design["paths"]:
                self.assertIn("strokeColor", path)
                if any(command["type"] == "close" for command in path["commands"]):
                    self.assertIn("fillColor", path)
                    self.assertIn("shadowColor", path)
                for command in path["commands"]:
                    for key in (
                        "x",
                        "y",
                        "controlX",
                        "controlY",
                        "control1X",
                        "control1Y",
                        "control2X",
                        "control2Y",
                    ):
                        if key in command:
                            self.assertGreaterEqual(command[key], 0)
                            self.assertLessEqual(command[key], 1)

        generated_dot_grid = next(
            d for d in catalog if d["id"] == "generated_dot_grid_001"
        )
        grid = generated_dot_grid["grid"]
        self.assertEqual(grid["layout"], "staggered")
        self.assertEqual(len(grid["dots"]), 49)
        for x, y in grid["dots"]:
            self.assertTrue(0 <= x <= 1)
            self.assertTrue(0 <= y <= 1)

    def test_featured_studies_use_mixed_construction_and_layered_color(self):
        catalog = generator.build_catalog()
        featured = {
            design["id"]: design
            for design in catalog
            if design["id"].startswith("art_")
        }

        self.assertEqual(
            set(featured),
            {
                "art_pookalam_lotus_dawn",
                "art_mandala_malli_light",
                "art_border_jasmine_vine",
                "art_corner_lotus_flourish",
                "art_optical_floating_cubes",
                "art_warli_rhythm_panel",
                "art_kolam_sikku_study",
            },
        )
        for design_id, design in featured.items():
            self.assertEqual(design["provenance"]["origin"], "system_generated")
            if design_id == "art_kolam_sikku_study":
                self.assertEqual(design["construction"], "dot_guided")
                self.assertIsNotNone(design["grid"])
            else:
                self.assertEqual(design["construction"], "illustrated")
                self.assertIsNone(design["grid"])
                self.assertTrue(
                    any("fillColor" in path for path in design["paths"])
                )
        self.assertTrue(
            any(
                "shadowColor" in path
                for design in featured.values()
                for path in design["paths"]
            )
        )
        radial = next(
            design for design in catalog
            if design["id"] == "generated_radial_001"
        )
        self.assertTrue(
            all(
                {"fillColor", "strokeColor", "shadowColor"} <= path.keys()
                for path in radial["paths"]
            )
        )
        diamonds = next(
            design for design in catalog
            if design["id"] == "generated_dot_grid_001"
        )
        self.assertTrue(
            all(
                {"fillColor", "strokeColor", "shadowColor"} <= path.keys()
                for path in diamonds["paths"]
                if any(
                    command["type"] == "close"
                    for command in path["commands"]
                )
            )
        )

    def test_generator_rejects_out_of_range_parameters(self):
        with self.assertRaises(ValueError):
            generator.radial_flower(2)
        with self.assertRaises(ValueError):
            generator.dot_grid(5, 5, "unknown")

    def test_thumbnail_path_flattening_supports_arcs(self):
        commands = [
            {"type": "moveTo", "x": 0.75, "y": 0.5},
            {
                "type": "arcTo",
                "x": 0.5,
                "y": 0.5,
                "radiusX": 0.25,
                "radiusY": 0.25,
                "startAngle": 0,
                "sweepAngle": math.pi / 2,
            },
        ]

        points = generator._flatten_path(commands, curve_steps=4)

        self.assertEqual(len(points), 5)
        self.assertAlmostEqual(points[-1][0], 0.5)
        self.assertAlmostEqual(points[-1][1], 0.75)

    def test_thumbnail_check_compares_decoded_pixels_not_file_encoding(self):
        with tempfile.TemporaryDirectory() as temporary_directory:
            temporary_path = Path(temporary_directory)
            image = Image.new("RGB", (4, 4), "#862B37")
            webp_path = temporary_path / "pattern.webp"
            png_path = temporary_path / "pattern.png"
            image.save(webp_path, format="WEBP", lossless=True)
            image.save(png_path, format="PNG")

            self.assertNotEqual(webp_path.read_bytes(), png_path.read_bytes())
            self.assertEqual(
                generator._decoded_thumbnail(webp_path),
                generator._decoded_thumbnail(png_path),
            )

    def test_thumbnail_keeps_strokes_and_guide_dots_visible_over_fills(self):
        with tempfile.TemporaryDirectory() as temporary_directory:
            thumbnail_path = Path(temporary_directory) / "layered-design.webp"
            path = generator._styled_path(
                "square",
                "square",
                [[0.25, 0.25], [0.75, 0.25], [0.75, 0.75], [0.25, 0.75]],
                fill_color="#A9D7D1",
                stroke_color="#862B37",
                stroke_width=0.02,
            )
            grid = {"dots": [[0.5, 0.5]]}

            generator.draw_thumbnail([path], thumbnail_path, grid=grid)
            image = Image.open(thumbnail_path).convert("RGB")

            self.assertEqual(image.getpixel((94, 150)), (134, 43, 55))
            self.assertEqual(image.getpixel((160, 160)), (85, 123, 104))

    def test_catalog_writer_emits_json_and_all_thumbnails(self):
        with tempfile.TemporaryDirectory() as temporary_directory:
            temporary_path = Path(temporary_directory)
            catalog_path = temporary_path / "catalog.json"
            thumbnail_directory = temporary_path / "thumbnails"

            catalog = generator.write_catalog(
                catalog_path=catalog_path,
                thumbnail_dir=thumbnail_directory,
            )

            decoded = json.loads(catalog_path.read_text(encoding="utf-8"))
            self.assertEqual(decoded["schemaVersion"], generator.SCHEMA_VERSION)
            self.assertEqual(len(decoded["designs"]), 67)
            self.assertEqual(len(list(thumbnail_directory.glob("*.webp"))), len(catalog))
            original_artwork = {
                generator._decoded_thumbnail(
                    thumbnail_directory / f"{design['id']}.webp"
                )
                for design in catalog
                if design["id"].startswith("original_")
            }
            self.assertEqual(len(original_artwork), 40)


if __name__ == "__main__":
    unittest.main()

