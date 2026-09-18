"""Render four clear views of the final enclosure for review."""

from pathlib import Path

import cadquery as cq
import matplotlib

matplotlib.use("Agg")
import matplotlib.pyplot as plt
from mpl_toolkits.mplot3d.art3d import Poly3DCollection
from PIL import Image


ROOT = Path(__file__).resolve().parent
BLUE = "#1976D2"
NAVY = "#0D47A1"
GOLD = "#F2A900"
EDGE = (0.02, 0.10, 0.22, 0.23)


def add_shape(ax, shape, color, alpha=1.0):
    vertices, triangles = shape.tessellate(0.42, 0.22)
    faces = [[vertices[i].toTuple() for i in tri] for tri in triangles]
    mesh = Poly3DCollection(
        faces,
        facecolor=color,
        edgecolor=EDGE,
        linewidth=0.06,
        alpha=alpha,
    )
    ax.add_collection3d(mesh)


def prepare(ax, title, zmax, elev, azim):
    ax.set_xlim(-43, 43)
    ax.set_ylim(-56, 56)
    ax.set_zlim(0, zmax)
    ax.set_box_aspect((86, 112, zmax))
    ax.view_init(elev=elev, azim=azim)
    ax.set_axis_off()
    ax.set_title(title, color="#2D3142", fontsize=13, pad=2)


base = cq.importers.importStep(str(ROOT / "smart_loop_base.step")).val()
lid = cq.importers.importStep(str(ROOT / "smart_loop_lid.step")).val()
screw = cq.importers.importStep(str(ROOT / "smart_loop_screw_single.step")).val()

lid_closed = lid.rotate((0, 0, 0), (1, 0, 0), 180).translate((0, 0, 29.9))
lid_exploded = lid.rotate((0, 0, 0), (1, 0, 0), 180).translate((0, 0, 50))
positions = [(-31.605, -43.45), (31.605, -43.45), (-31.605, 43.45), (31.605, 43.45)]

fig = plt.figure(figsize=(12, 10), dpi=150, facecolor="#F4F7FB")
axes = [fig.add_subplot(2, 2, i + 1, projection="3d", facecolor="#F4F7FB") for i in range(4)]

# Closed enclosure.
add_shape(axes[0], base, BLUE)
add_shape(axes[0], lid_closed, NAVY)
for x, y in positions:
    installed = screw.rotate((0, 0, 0), (1, 0, 0), 180).translate((x, y, 32.9))
    add_shape(axes[0], installed, GOLD)
prepare(axes[0], "Closed enclosure", 38, 28, -42)

# Exploded view from the rear, showing the separate lid and fasteners.
add_shape(axes[1], base, BLUE)
add_shape(axes[1], lid_exploded, NAVY, 0.94)
for x, y in positions:
    exploded = screw.rotate((0, 0, 0), (1, 0, 0), 180).translate((x, y, 79))
    add_shape(axes[1], exploded, GOLD)
prepare(axes[1], "Exploded assembly", 82, 25, 138)

# Open base from above: bosses, locating rails, and cable ports are visible.
add_shape(axes[2], base, BLUE)
prepare(axes[2], "Base interior", 30, 72, -42)

# Lid underside shows the recessed locating skirt and aligned screw holes.
add_shape(axes[3], lid, NAVY)
for index, (x, y) in enumerate(((-15, -18), (15, -18), (-15, 18), (15, 18))):
    upright = screw.translate((x, y, 7))
    add_shape(axes[3], upright, GOLD)
prepare(axes[3], "Lid underside + 4 thumb screws", 38, 54, -42)

fig.suptitle(
    "Smart Loop — final enclosure preview",
    fontsize=19,
    color="#1E293B",
    y=0.985,
)
fig.text(
    0.5,
    0.018,
    "Electronics 77.90 × 54.21 × 21.00 mm  •  Sensor port Ø8.50 mm  •  2 rear USB-C ports 13.50 × 7.00 mm",
    ha="center",
    color="#526070",
    fontsize=10,
)
fig.subplots_adjust(left=0.01, right=0.99, bottom=0.05, top=0.94, wspace=0.01, hspace=0.05)

png_path = ROOT / "smart_loop_showcase.png"
webp_path = ROOT / "smart_loop_showcase.webp"
fig.savefig(png_path, bbox_inches="tight", pad_inches=0.08)
plt.close(fig)
Image.open(png_path).convert("RGB").save(webp_path, "WEBP", quality=82, method=6)
