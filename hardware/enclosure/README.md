# Smart Loop 3D-printable enclosure

This is a preliminary parametric model based on the supplied top-view measurements.

## Current assumptions

- Combined electronics footprint: `99.45 x 83.84 mm`
- Assumed maximum electronics height: `27 mm`
- Internal XY clearance: `4 mm` per side
- Internal top clearance: `5 mm`
- Wall: `2.5 mm`
- Floor: `2.4 mm`
- Lid screws: four M3 screws
- Flow-sensor body: assumed `45 mm` for the optional clip

Confirm the height, USB position, switch position, LED position, cable-gland size,
and sensor-body diameter before the final print.

## Exporting parts

Open `smart_loop_enclosure.scad`, change the `part` value at the top to one of:

- `"base"`
- `"lid"`
- `"sensor_clip"`
- `"assembly"`
- `"layout"`

Render with F6, then choose **File > Export > Export as STL**.

## Suggested print settings

- PETG
- 0.20 mm layer height
- 3 or 4 perimeters
- 20% to 30% infill
- No supports for the base or sensor clip
- Check lid bridging in the slicer

Do a low-quality draft print first. The openings and component height are still
based on preliminary assumptions.
