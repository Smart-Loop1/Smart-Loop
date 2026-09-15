// Smart Loop enclosure - preliminary parametric prototype
// Units: millimeters
// Export one part at a time by changing `part` below.

$fn = 64;
part = "layout"; // "base", "lid", "sensor_clip", "layout", "assembly"

// Measurements supplied from the prototype photos.
electronics_x = 99.45;
electronics_y = 83.84;

// Recheck these after measuring the prototype from the side.
electronics_height = 27;
clearance_xy = 4;
clearance_z = 5;

wall = 2.5;
floor_thickness = 2.4;
lid_thickness = 2.5;
lid_rim_depth = 3;
fit_clearance = 0.35;
corner_radius = 8;

inner_x = electronics_x + 2 * clearance_xy;
inner_y = electronics_y + 2 * clearance_xy;
inner_height = electronics_height + clearance_z;
outer_x = inner_x + 2 * wall;
outer_y = inner_y + 2 * wall;
base_height = floor_thickness + inner_height;

// Adjustable openings. Positions use the enclosure center as [0, 0].
usb_width = 13;
usb_height = 8;
usb_x = 24;
usb_z = 8;

cable_hole_diameter = 8;
cable_y = 0;
cable_z = 15;

switch_width = 12;
switch_height = 6;
switch_x = 24;
switch_y = -28;

led_diameter = 5.4;
led_x = 42;
led_y = -28;

screw_clearance_diameter = 3.3;
screw_pilot_diameter = 2.6;
boss_diameter = 8;
boss_edge_offset = 7;

// Sensor clip defaults; confirm the round sensor-body diameter later.
sensor_body_diameter = 45;
sensor_clip_wall = 3.2;
sensor_clip_depth = 12;
sensor_clip_opening = 22;
sensor_mount_hole = 4.2;

module rounded_box(size, radius) {
  linear_extrude(height = size[2])
    offset(r = radius)
      square([size[0] - 2 * radius, size[1] - 2 * radius], center = true);
}

module rounded_rect_2d(size, radius) {
  offset(r = radius)
    square([size[0] - 2 * radius, size[1] - 2 * radius], center = true);
}

module screw_positions() {
  for (x = [-1, 1], y = [-1, 1])
    translate([
      x * (outer_x / 2 - boss_edge_offset),
      y * (outer_y / 2 - boss_edge_offset),
      0
    ]) children();
}

module base_shell() {
  difference() {
    rounded_box([outer_x, outer_y, base_height], corner_radius);

    translate([0, 0, floor_thickness])
      rounded_box(
        [inner_x, inner_y, inner_height + 1],
        max(1, corner_radius - wall)
      );

    // USB opening in the front wall.
    translate([usb_x, -outer_y / 2, floor_thickness + usb_z])
      cube([usb_width, wall * 3, usb_height], center = true);

    // Cable-gland opening in the right wall.
    translate([outer_x / 2, cable_y, floor_thickness + cable_z])
      rotate([0, 90, 0])
        cylinder(d = cable_hole_diameter, h = wall * 3, center = true);
  }
}

module base_bosses() {
  difference() {
    screw_positions()
      cylinder(d = boss_diameter, h = base_height - 0.6);

    screw_positions()
      translate([0, 0, floor_thickness])
        cylinder(d = screw_pilot_diameter, h = inner_height + 1);
  }
}

module equipment_locators() {
  locator_h = 2.2;
  locator_t = 1.4;

  // Low guides only: easy to trim if the real boards differ slightly.
  translate([0, 0, floor_thickness]) {
    translate([-electronics_x / 2, 0, 0])
      cube([locator_t, electronics_y - 8, locator_h], center = true);
    translate([electronics_x / 2, 0, 0])
      cube([locator_t, electronics_y - 8, locator_h], center = true);
    translate([0, -electronics_y / 2, 0])
      cube([electronics_x - 8, locator_t, locator_h], center = true);
    translate([0, electronics_y / 2, 0])
      cube([electronics_x - 8, locator_t, locator_h], center = true);
  }
}

module base() {
  union() {
    base_shell();
    base_bosses();
    equipment_locators();
  }
}

module lid_skirt() {
  skirt_outer_x = inner_x - 2 * fit_clearance;
  skirt_outer_y = inner_y - 2 * fit_clearance;
  skirt_wall = 1.6;

  translate([0, 0, lid_thickness])
    linear_extrude(height = lid_rim_depth)
      difference() {
        rounded_rect_2d(
          [skirt_outer_x, skirt_outer_y],
          max(1, corner_radius - wall - fit_clearance)
        );
        rounded_rect_2d(
          [skirt_outer_x - 2 * skirt_wall, skirt_outer_y - 2 * skirt_wall],
          max(1, corner_radius - wall - skirt_wall - fit_clearance)
        );
      }
}

module water_drop_2d() {
  polygon(points = [
    [0, 14], [-4.5, 7], [-7, 1], [-6.6, -4], [-4, -8],
    [0, -10], [4, -8], [6.6, -4], [7, 1], [4.5, 7]
  ]);
}

module lid_print_orientation() {
  difference() {
    union() {
      rounded_box([outer_x, outer_y, lid_thickness], corner_radius);
      lid_skirt();
    }

    // Through-holes for four M3 lid screws.
    screw_positions()
      translate([0, 0, -0.5])
        cylinder(
          d = screw_clearance_diameter,
          h = lid_thickness + lid_rim_depth + 1
        );

    // Shallow countersinks on the exterior face.
    screw_positions()
      translate([0, 0, -0.01])
        cylinder(d1 = 6.2, d2 = screw_clearance_diameter, h = 1.5);

    // Controls are placed on the lid because they are on top of the PCB.
    translate([switch_x, switch_y, -0.5])
      cube(
        [switch_width, switch_height, lid_thickness + lid_rim_depth + 1],
        center = false
      );

    translate([led_x, led_y, -0.5])
      cylinder(d = led_diameter, h = lid_thickness + lid_rim_depth + 1);

    // Engraved Smart Loop drop mark; exterior face is z = 0.
    translate([-15, 3, -0.01])
      linear_extrude(height = 0.8)
        water_drop_2d();
  }
}

module sensor_clip() {
  inner_r = sensor_body_diameter / 2;
  outer_r = inner_r + sensor_clip_wall;
  foot_width = outer_r * 2 + 24;
  foot_height = 12;

  linear_extrude(height = sensor_clip_depth)
    difference() {
      union() {
        difference() {
          circle(r = outer_r);
          circle(r = inner_r);
          translate([-sensor_clip_opening / 2, 0])
            square([sensor_clip_opening, outer_r + 2]);
        }

        translate([0, -outer_r - foot_height / 2 + 2])
          rounded_rect_2d([foot_width, foot_height], 3);
      }

      for (x = [-foot_width / 2 + 7, foot_width / 2 - 7])
        translate([x, -outer_r - foot_height / 2 + 2])
          circle(d = sensor_mount_hole);
    }
}

module assembly() {
  color("#173F73") base();
  color("#245A96")
    translate([0, 0, base_height + lid_thickness])
      rotate([180, 0, 0])
        lid_print_orientation();
}

module print_layout() {
  base();
  translate([outer_x + 15, 0, 0]) lid_print_orientation();
  translate([0, outer_y + 45, 0]) sensor_clip();
}

if (part == "base") base();
else if (part == "lid") lid_print_orientation();
else if (part == "sensor_clip") sensor_clip();
else if (part == "assembly") assembly();
else print_layout();
