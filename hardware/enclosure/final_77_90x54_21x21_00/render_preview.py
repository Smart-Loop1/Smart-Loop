"""Render an exploded preview of the generated STEP parts."""

from pathlib import Path

import cadquery as cq
import matplotlib

matplotlib.use("Agg")
import matplotlib.pyplot as plt
from mpl_toolkits.mplot3d.art3d import Poly3DCollection


ROOT = Path(__file__).resolve().parent


def add_shape(ax, shape, color, alpha=1.0):
    vertices, triangles = shape.tessellate(0.25, 0.15)
    faces = [
        [vertices[index].toTuple() for index in triangle]
        for triangle in triangles
    ]
    mesh = Poly3DCollection(
        faces,
        facecolor=color,
        edgecolor=(0.03, 0.12, 0.24, 0.18),
        linewidth=0.08,
        alpha=alpha,
    )
    ax.add_collection3d(mesh)


base = cq.importers.importStep(str(ROOT / "smart_loop_base.step")).val()
lid = cq.importers.importStep(str(ROOT / "smart_loop_lid.step")).val()
screw = cq.importers.importStep(str(ROOT / "smart_loop_screw_single.step")).val()

lid_exploded = lid.rotate((0, 0, 0), (1, 0, 0), 180).moved(
    cq.Location(cq.Vector(0, 0, 46))
)

fig = plt.figure(figsize=(9, 9), dpi=180, facecolor="#F5F8FC")
ax = fig.add_subplot(111, projection="3d", facecolor="#F5F8FC")
add_shape(ax, base, "#1976D2")
add_shape(ax, lid_exploded, "#0D47A1", 0.92)

for x in (-31.605, 31.605):
    for y in (-43.45, 43.45):
        placed = screw.rotate((0, 0, 0), (1, 0, 0), 180).moved(
            cq.Location(cq.Vector(x, y, 55))
        )
        add_shape(ax, placed, "#F2A900")

ax.set_xlim(-48, 48)
ax.set_ylim(-58, 58)
ax.set_zlim(0, 58)
ax.set_box_aspect((96, 116, 58))
ax.view_init(elev=27, azim=-42)
ax.set_axis_off()
ax.set_title(
    "Smart Loop Enclosure — 77.90 × 54.21 × 21.00 mm electronics",
    fontsize=13,
    color="#2D3142",
    pad=10,
)
fig.tight_layout()
fig.savefig(ROOT / "smart_loop_preview.png", bbox_inches="tight", pad_inches=0.08)
