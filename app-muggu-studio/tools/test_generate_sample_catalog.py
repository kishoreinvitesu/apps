import json
import math
import tempfile
import unittest
from pathlib import Path

from PIL import Image

from tools import generate_sample_catalog as generator


class GenerateSampleCatalogTests(unittest.TestCase):
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

        self.assertEqual(len(catalog), 12)
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
        self.assertTrue(
            all(
                design[review]["status"] == "pending"
                for design in catalog
                for review in (
                    "rightsReview",
                    "culturalReview",
                    "localizationReview",
                    "lessonReview",
                )
            )
        )
        for design in catalog:
            for path in design["paths"]:
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

        grid = catalog[-1]["grid"]
        self.assertEqual(grid["layout"], "staggered")
        self.assertEqual(len(grid["dots"]), 49)
        for x, y in grid["dots"]:
            self.assertTrue(0 <= x <= 1)
            self.assertTrue(0 <= y <= 1)

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
            self.assertEqual(len(decoded["designs"]), len(catalog))
            self.assertEqual(len(list(thumbnail_directory.glob("*.webp"))), 12)


if __name__ == "__main__":
    unittest.main()

