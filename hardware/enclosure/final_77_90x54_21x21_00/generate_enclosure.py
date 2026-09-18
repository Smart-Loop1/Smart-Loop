"""Generate the final Smart Loop enclosure from the measured electronics size.

The model intentionally keeps the rounded shell, recessed lid, corner fasteners,
and engraved water-drop design language of the original enclosure.
"""

from __future__ import annotations

from pathlib import Path

import cadquery as cq
from cadquery import exporters


OUTPUT_DIR = Path(__file__).resolve().parent

# Measured electronics envelope (mm).
ELECTRONICS_LENGTH = 77.90
ELECTRONICS_WIDTH = 54.21
ELECTRONICS_HEIGHT = 21.00

# Print and assembly allowances (mm).
XY_CLEARANCE = 7.50
TOP_CLEARANCE = 4.00
WALL = 2.50
FLOOR = 2.40
LID_THICKNESS = 2.50
LID_RIM_DEPTH = 3.00
LID_FIT_CLEARANCE = 0.35
CORNER_RADIUS = 8.00
LOGO_RELIEF_HEIGHT = 1.25

# The long electronics axis runs front-to-back (Y), matching the USB opening.
INNER_X = ELECTRONICS_WIDTH + 2 * XY_CLEARANCE
INNER_Y = ELECTRONICS_LENGTH + 2 * XY_CLEARANCE
INNER_HEIGHT = ELECTRONICS_HEIGHT + TOP_CLEARANCE
OUTER_X = INNER_X + 2 * WALL
OUTER_Y = INNER_Y + 2 * WALL
BASE_HEIGHT = FLOOR + INNER_HEIGHT

# Four lid fasteners.
SCREW_EDGE_OFFSET = 5.50
BOSS_DIAMETER = 8.00
PILOT_DIAMETER = 2.80
LID_CLEARANCE_DIAMETER = 3.50
SCREW_HEAD_DIAMETER = 8.00
SCREW_HEAD_HEIGHT = 3.00
SCREW_SHANK_LENGTH = 23.00

# Cable openings. These include practical FDM clearance.
SENSOR_CABLE_DIAMETER = 8.50
SENSOR_CABLE_Z = BASE_HEIGHT / 2
USB_C_OPENING_WIDTH = 13.50
USB_C_OPENING_HEIGHT = 7.00
USB_C_OPENING_RADIUS = 2.00
USB_C_OPENING_Z_LEVELS = (FLOOR + 4.20, FLOOR + 13.00)


def rounded_box_xy(x: float, y: float, z: float, radius: float, z0: float = 0) -> cq.Workplane:
    """Create a box with rounded vertical corners and a flat print surface."""
    return (
        cq.Workplane("XY", origin=(0, 0, z0))
        .box(x, y, z, centered=(True, True, False))
        .edges("|Z")
        .fillet(radius)
    )


def shape_workplane(shape: cq.Shape) -> cq.Workplane:
    return cq.Workplane("XY").newObject([shape])


def screw_positions() -> list[tuple[float, float]]:
    x = OUTER_X / 2 - SCREW_EDGE_OFFSET
    y = OUTER_Y / 2 - SCREW_EDGE_OFFSET
    return [(-x, -y), (x, -y), (-x, y), (x, y)]


def cylinder_at(x: float, y: float, z: float, diameter: float, height: float) -> cq.Workplane:
    return (
        cq.Workplane("XY", origin=(x, y, z))
        .circle(diameter / 2)
        .extrude(height)
    )


def make_base() -> cq.Workplane:
    outer = rounded_box_xy(OUTER_X, OUTER_Y, BASE_HEIGHT, CORNER_RADIUS)
    cavity = rounded_box_xy(
        INNER_X,
        INNER_Y,
        INNER_HEIGHT + 1,
        CORNER_RADIUS - WALL,
        FLOOR,
    )
    base = outer.cut(cavity)

    # Corner bosses remain outside the measured PCB envelope.
    for x, y in screw_positions():
        boss = cylinder_at(
            x,
            y,
            FLOOR,
            BOSS_DIAMETER,
            INNER_HEIGHT - 0.60,
        )
        base = base.union(boss)

    # Low locating rails prevent the PCB assembly sliding inside the box.
    locator_height = 2.20
    locator_thickness = 1.40
    locator_gap = 1.00
    for x in (-ELECTRONICS_WIDTH / 2 - locator_gap, ELECTRONICS_WIDTH / 2 + locator_gap):
        rail = (
            cq.Workplane("XY", origin=(x, 0, FLOOR))
            .box(locator_thickness, ELECTRONICS_LENGTH - 12, locator_height, centered=(True, True, False))
        )
        base = base.union(rail)
    for y in (-ELECTRONICS_LENGTH / 2 - locator_gap, ELECTRONICS_LENGTH / 2 + locator_gap):
        rail = (
            cq.Workplane("XY", origin=(0, y, FLOOR))
            .box(ELECTRONICS_WIDTH - 12, locator_thickness, locator_height, centered=(True, True, False))
        )
        base = base.union(rail)

    # Blind pilot holes for the printable screws or standard M3 screws.
    for x, y in screw_positions():
        pilot = cylinder_at(
            x,
            y,
            FLOOR,
            PILOT_DIAMETER,
            INNER_HEIGHT + 1,
        )
        base = base.cut(pilot)

    # Round sensor-cable exit centered on the right side wall.
    sensor_cut = cq.Solid.makeCylinder(
        SENSOR_CABLE_DIAMETER / 2,
        WALL * 4,
        cq.Vector(OUTER_X / 2 - WALL * 2, 0, SENSOR_CABLE_Z),
        cq.Vector(1, 0, 0),
    )
    base = base.cut(shape_workplane(sensor_cut))

    # Two vertically stacked rear USB-C openings matching the two-board stack.
    for usb_z in USB_C_OPENING_Z_LEVELS:
        usb_cut = (
            cq.Workplane("XY")
            .box(
                USB_C_OPENING_WIDTH,
                WALL * 4,
                USB_C_OPENING_HEIGHT,
                centered=(True, True, True),
            )
            .edges("|Y")
            .fillet(USB_C_OPENING_RADIUS)
            .translate((0, -OUTER_Y / 2, usb_z))
        )
        base = base.cut(usb_cut)
    return base.clean()


def sample_cubic(
    start: tuple[float, float],
    control_1: tuple[float, float],
    control_2: tuple[float, float],
    end: tuple[float, float],
    steps: int = 18,
) -> list[tuple[float, float]]:
    points = []
    for index in range(1, steps + 1):
        t = index / steps
        inverse = 1 - t
        x = (
            inverse**3 * start[0]
            + 3 * inverse**2 * t * control_1[0]
            + 3 * inverse * t**2 * control_2[0]
            + t**3 * end[0]
        )
        y = (
            inverse**3 * start[1]
            + 3 * inverse**2 * t * control_1[1]
            + 3 * inverse * t**2 * control_2[1]
            + t**3 * end[1]
        )
        points.append((x, y))
    return points


def official_water_drop_points() -> tuple[list[tuple[float, float]], list[tuple[float, float]]]:
    outer = [(32.0, 2.0)]
    outer_segments = [
        ((32, 2), (26, 13), (10, 30), (10, 45)),
        ((10, 45), (10, 58), (20, 69), (32, 69)),
        ((32, 69), (44, 69), (54, 58), (54, 45)),
        ((54, 45), (54, 30), (38, 13), (32, 2)),
    ]
    for segment in outer_segments:
        outer.extend(sample_cubic(*segment))

    inner = [(24.0, 47.0)]
    inner_segments = [
        ((24, 47), (26, 54), (31, 58), (38, 59)),
        ((38, 59), (35, 62), (31, 64), (26, 63)),
        ((26, 63), (19, 61), (15, 54), (16, 47)),
        ((16, 47), (17, 43), (19, 39), (22, 35)),
        ((22, 35), (21, 40), (22, 44), (24, 47)),
    ]
    for segment in inner_segments:
        inner.extend(sample_cubic(*segment))

    # Match the official app mark and size it to 28 mm tall on the lid.
    scale = 28.0 / 67.0

    def transform(points: list[tuple[float, float]]) -> list[tuple[float, float]]:
        return [((x - 32.0) * scale, (35.5 - y) * scale) for x, y in points]

    return transform(outer), transform(inner)


def water_drop_relief() -> cq.Workplane:
    outer_points, inner_points = official_water_drop_points()
    outer = (
        cq.Workplane("XY", origin=(0, 0, -0.85))
        .polyline(outer_points)
        .close()
        .extrude(0.85)
    )
    inner = (
        cq.Workplane("XY", origin=(0, 0, -LOGO_RELIEF_HEIGHT))
        .polyline(inner_points)
        .close()
        .extrude(LOGO_RELIEF_HEIGHT - 0.80)
    )
    # Recess the outer drop while leaving the inner accent flush with the lid.
    return outer.cut(inner)

def make_lid() -> cq.Workplane:
    plate = rounded_box_xy(OUTER_X, OUTER_Y, LID_THICKNESS, CORNER_RADIUS)

    skirt_outer_x = INNER_X - 2 * LID_FIT_CLEARANCE
    skirt_outer_y = INNER_Y - 2 * LID_FIT_CLEARANCE
    skirt_wall = 1.60
    skirt_outer = rounded_box_xy(
        skirt_outer_x,
        skirt_outer_y,
        LID_RIM_DEPTH,
        CORNER_RADIUS - WALL - LID_FIT_CLEARANCE,
        LID_THICKNESS,
    )
    skirt_inner = rounded_box_xy(
        skirt_outer_x - 2 * skirt_wall,
        skirt_outer_y - 2 * skirt_wall,
        LID_RIM_DEPTH + 0.2,
        CORNER_RADIUS - WALL - LID_FIT_CLEARANCE - skirt_wall,
        LID_THICKNESS - 0.1,
    )
    skirt = skirt_outer.cut(skirt_inner)

    # Keep the recessed skirt clear of all four base bosses.
    for x, y in screw_positions():
        skirt_clearance = cylinder_at(
            x,
            y,
            LID_THICKNESS - 0.1,
            BOSS_DIAMETER + 0.8,
            LID_RIM_DEPTH + 0.3,
        )
        skirt = skirt.cut(skirt_clearance)

    lid = plate.union(skirt)

    for x, y in screw_positions():
        through = cylinder_at(
            x,
            y,
            -0.20,
            LID_CLEARANCE_DIAMETER,
            LID_THICKNESS + LID_RIM_DEPTH + 0.5,
        )
        head_recess = cylinder_at(
            x,
            y,
            -0.05,
            SCREW_HEAD_DIAMETER + 0.50,
            0.65,
        )
        lid = lid.cut(through).cut(head_recess)

    # Raised official Smart Loop mark on the exterior face.
    lid = lid.union(water_drop_relief())
    return lid.clean()


def make_screw() -> cq.Workplane:
    # A printable self-tapping-style screw. Standarddef make_screw() -> cq.Workplane:
    # Hand-turnable printed screw: the two low-profile wings remove the need
    # for a screwdriver while preserving the four-fastener lid layout.
    head_disc = cylinder_at(0, 0, 0, SCREW_HEAD_DIAMETER, SCREW_HEAD_HEIGHT)
    head_wing = (
        cq.Workplane("XY")
        .box(10.0, 3.2, SCREW_HEAD_HEIGHT, centered=(True, True, False))
        .edges("|Z")
        .fillet(1.45)
    )
    head = head_disc.union(head_wing)
    shank = cylinder_at(
        0,
        0,
        SCREW_HEAD_HEIGHT,
        2.80,
        SCREW_SHANK_LENGTH - 1.20,
    )
    tip = shape_workplane(
        cq.Solid.makeCone(
            1.40,
            0.35,
            1.20,
            cq.Vector(0, 0, SCREW_HEAD_HEIGHT + SCREW_SHANK_LENGTH - 1.20),
            cq.Vector(0, 0, 1),
        )
    )
    screw = head.union(shank).union(tip)

    # Shallow rings make the printed part grip the 2.8 mm pilot hole.
    pitch = 0.80
    z = SCREW_HEAD_HEIGHT + 0.55
    while z < SCREW_HEAD_HEIGHT + SCREW_SHANK_LENGTH - 1.20:
        ridge = cylinder_at(0, 0, z, 3.10, 0.24)
        screw = screw.union(ridge)
        z += pitch

    return screw.clean()

def make_four_screws() -> cq.Compound:
    screw = make_screw().val()
    spacing = 12.0
    copies = [
        screw.moved(cq.Location(cq.Vector(-spacing / 2, -spacing / 2, 0))),
        screw.moved(cq.Location(cq.Vector(spacing / 2, -spacing / 2, 0))),
        screw.moved(cq.Location(cq.Vector(-spacing / 2, spacing / 2, 0))),
        screw.moved(cq.Location(cq.Vector(spacing / 2, spacing / 2, 0))),
    ]
    return cq.Compound.makeCompound(copies)


def make_assembly(base: cq.Workplane, lid: cq.Workplane) -> cq.Compound:
    assembled_lid = (
        lid.rotate((0, 0, 0), (1, 0, 0), 180)
        .translate((0, 0, BASE_HEIGHT + LID_THICKNESS))
        .val()
    )
    return cq.Compound.makeCompound([base.val(), assembled_lid])


def write_profile_svg() -> None:
    screw_circles = "\n".join(
        f'  <circle cx="{x:.3f}" cy="{-y:.3f}" r="{LID_CLEARANCE_DIAMETER / 2:.3f}" class="cut"/>'
        for x, y in screw_positions()
    )
    svg = f'''<svg xmlns="http://www.w3.org/2000/svg" width="{OUTER_X}mm" height="{OUTER_Y}mm"
  viewBox="{-OUTER_X / 2} {-OUTER_Y / 2} {OUTER_X} {OUTER_Y}">
  <style>
    .outline {{ fill: none; stroke: #0D47A1; stroke-width: 0.35; }}
    .cut {{ fill: none; stroke: #D94B4B; stroke-width: 0.25; }}
    .mark {{ fill: none; stroke: #1976D2; stroke-width: 0.30; }}
  </style>
  <rect x="{-OUTER_X / 2}" y="{-OUTER_Y / 2}" width="{OUTER_X}" height="{OUTER_Y}"
    rx="{CORNER_RADIUS}" class="outline"/>
{screw_circles}
  <path d="M 0,-11 C -2,-7 -6,-3 -6,1 C -6,6 -3,8.5 0,8.5 C 3,8.5 6,6 6,1 C 6,-3 2,-7 0,-11 Z" class="mark"/>
</svg>'''
    (OUTPUT_DIR / "smart_loop_lid_profile.svg").write_text(svg, encoding="utf-8")


def export_model(model: cq.Shape | cq.Workplane, stem: str) -> None:
    exporters.export(model, str(OUTPUT_DIR / f"{stem}.stl"), tolerance=0.05, angularTolerance=0.15)
    exporters.export(model, str(OUTPUT_DIR / f"{stem}.step"))


def main() -> None:
    base = make_base()
    lid = make_lid()
    screw = make_screw()
    screws = make_four_screws()
    assembly = make_assembly(base, lid)

    export_model(base, "smart_loop_base")
    export_model(lid, "smart_loop_lid")
    export_model(screw, "smart_loop_screw_single")
    export_model(screws, "smart_loop_screws_4x")
    exporters.export(assembly, str(OUTPUT_DIR / "smart_loop_enclosure_assembly.step"))
    exporters.export(assembly, str(OUTPUT_DIR / "smart_loop_assembly_preview.svg"))
    write_profile_svg()

    print(f"Electronics: {ELECTRONICS_LENGTH:.2f} x {ELECTRONICS_WIDTH:.2f} x {ELECTRONICS_HEIGHT:.2f} mm")
    print(f"Internal:    {INNER_Y:.2f} x {INNER_X:.2f} x {INNER_HEIGHT:.2f} mm")
    print(
        f"External:    {OUTER_Y:.2f} x {OUTER_X:.2f} x "
        f"{BASE_HEIGHT + LID_THICKNESS + LOGO_RELIEF_HEIGHT:.2f} mm"
    )
    print(f"Sensor opening: {SENSOR_CABLE_DIAMETER:.2f} mm")
    print(
        f"USB-C openings: 2 x ({USB_C_OPENING_WIDTH:.2f} x "
        f"{USB_C_OPENING_HEIGHT:.2f} mm)"
    )


if __name__ == "__main__":
    main()
