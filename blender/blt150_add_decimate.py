"""
blt150_add_decimate.py
──────────────────────
Adds a Decimate modifier (ratio 0.05) to every mesh object currently in
the scene. Does NOT apply the modifier — you can still tweak each part's
ratio manually before exporting.

Usage:
  1. Run blt150_explosion.py → Load All Groups (F01, F02, F05)
  2. Run this script — each part gets a "Decimate" modifier at 0.05
  3. Adjust individual ratios in the Properties panel → Modifier tab
  4. When happy, export (the modifier is applied on export automatically)
"""

import bpy

DECIMATE_RATIO = 0.05   # default starting ratio — change per-part as needed

added = 0
skipped = 0

for obj in bpy.context.scene.objects:
    if obj.type != 'MESH':
        continue
    # Skip if a Decimate modifier already exists on this object
    if any(m.type == 'DECIMATE' for m in obj.modifiers):
        skipped += 1
        continue
    mod = obj.modifiers.new(name="Decimate", type='DECIMATE')
    mod.ratio = DECIMATE_RATIO
    added += 1

print(f"[ADD_DECIMATE] Added modifier to {added} objects (skipped {skipped} already had one)")
