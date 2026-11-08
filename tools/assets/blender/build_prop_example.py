"""Example of a model built by script in Blender: a low poly barrel, coloured by vertex colours,
exported as glTF for Godot. Copy it for simple props. Method: docs/recettes/modeles-3d.md.

Run (Blender from apt, without its interface; the downloaded binary is refused in the cloud
session):
    blender -b --factory-startup -P tools/assets/blender/build_prop_example.py -- out.glb
then, for a mesh the game uses by the thousand:
    godot --headless --path . --script res://tools/assets/import_glb_mesh.gd -- out.glb \\
        res://assets/models/example/barrel.res

Measures are written in Godot's frame (y up, the front towards +z) and converted with
`blender_point`: Blender has z up and its front towards -y.
"""

import math
import sys

import bmesh
import bpy

SIDES = 16
RADIUS = 0.3
BELLY = 0.34
HEIGHT = 0.9
# Colours in sRGB, given as they are: a bmesh colour layer is a byte colour attribute, stored
# in sRGB, and the glTF exporter converts it to linear. Converting here as well darkens the
# model (checked on a screenshot, 08/11/2026).
WOOD = (0.62, 0.42, 0.24)
HOOP = (0.25, 0.25, 0.27)
HOOPS = (0.12, 0.88)


def blender_point(x, y, z):
    """A point given in Godot's frame, in Blender's."""
    return (x, -z, y)


def rgba(color):
    """An sRGB colour (0 to 1), with alpha."""
    return tuple(color) + (1.0,)


def radius_at(height):
    """The barrel bulges in its middle."""
    t = height / HEIGHT
    return RADIUS + (BELLY - RADIUS) * math.sin(math.pi * t)


def build():
    bm = bmesh.new()
    color_layer = bm.loops.layers.color.new("Color")
    rings = 12
    grid = []
    for ring in range(rings + 1):
        height = HEIGHT * ring / rings
        row = []
        for side in range(SIDES):
            angle = math.tau * side / SIDES
            r = radius_at(height)
            row.append(bm.verts.new(blender_point(r * math.cos(angle), height, r * math.sin(angle))))
        grid.append(row)
    for ring in range(rings):
        height = HEIGHT * (ring + 0.5) / rings
        hoop = any(abs(height / HEIGHT - h) < 0.5 / rings for h in HOOPS)
        for side in range(SIDES):
            a, b = grid[ring][side], grid[ring][(side + 1) % SIDES]
            c, d = grid[ring + 1][(side + 1) % SIDES], grid[ring + 1][side]
            face = bm.faces.new((a, b, c, d))
            for loop in face.loops:
                loop[color_layer] = rgba(HOOP if hoop else WOOD)
    for row in (grid[0], grid[-1]):
        face = bm.faces.new(row)
        for loop in face.loops:
            loop[color_layer] = rgba(WOOD)
    # Outward normals whatever the order the faces were made in.
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces)

    mesh = bpy.data.meshes.new("barrel")
    bm.to_mesh(mesh)
    bm.free()
    # The exporter only takes the colour attribute marked for rendering: without this, the
    # model is white in Godot.
    mesh.color_attributes.active_color_index = 0
    mesh.color_attributes.render_color_index = 0
    material = bpy.data.materials.new("barrel")
    mesh.materials.append(material)
    obj = bpy.data.objects.new("barrel", mesh)
    bpy.context.collection.objects.link(obj)
    return obj


def main():
    out = sys.argv[sys.argv.index("--") + 1] if "--" in sys.argv else "barrel.glb"
    for obj in list(bpy.data.objects):
        bpy.data.objects.remove(obj)
    build()
    bpy.ops.export_scene.gltf(
        filepath=out, export_format="GLB", export_colors=True, export_materials="PLACEHOLDER"
    )
    print("blender: wrote", out)


main()
