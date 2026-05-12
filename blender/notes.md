# BLT150 Blender Explosion View — Notes

## Overview

We're building a group-by-group exploded parts view in Blender.
Each group (F01–F19) maps to a collection of OBJ models.
Sub-assemblies collapse/expand on click.

---

## Files Created

| File | Purpose |
|---|---|
| `assets/data/blt150_parts_catalog.json` | Cleaned source catalog (all groups, items, sub-assemblies) |
| `blender/blt150_explosion.py` | Blender Python script — run this inside Blender |

---

## Folder Convention

All 3D assets go in `assets/Objects/`. Each part needs **three files** with the same base name:

```
assets/Objects/
  SPD-06114X-B.obj   ← geometry
  SPD-06114X-B.mtl   ← material
  SPD-06114X-B.jpg   ← texture
```

The base name must match `item_code` from the catalog (e.g. `SPD-06114X-B`).
For sub-assembly proxy meshes (the "collapsed" view of an SA), name them after the SA code:
```
SA-F05-01.obj / .mtl / .jpg
```

### Currently available parts (already in assets/Objects/)

| Code | Description | Group |
|---|---|---|
| SPD-06114X-B | Case, Meter | F01 |
| SPD-06545X-B | Front Trunk Cover LH | F02 |
| SPD-06546X-B | Front Trunk Cover RH | F02 |
| SPD-33100X-B | Headlight Assy - LED Type | F02 |
| SPD-45467X-B | Guard, Front Cover | F02 |
| SPD-89001X-B | Handle, Front Trunk Opening LH | F02 |
| SPD-89101X-B | Handle, Front Trunk Opening RH | F02 |
| SPD-90405X-B | Steering Lock Cover | F02 |
| SPD-43211X-B | Windshield | F02 |
| SPD-43264X-B | Ornament, Headlight Housing RH | F03 |
| SPD-43265X-B | Ornament, Headlight Housing LH | F03 |
| SPD-43261X-B | Front Cowl Guard RH | F03 |
| SPD-33550X-B | Winker, Front LH - LED Type | F03 |
| SPD-38566X-B | Plate, Guard RH | F04 |
| SPD-43433X-B | Guard, Lower RH | F04 |
| SPD-10260X-B | Rubber, Treadle II RH | F04 |
| SPD-10259X-B | Rubber, Treadle LH | F04 |
| SPD-10263X-B | Rubber, Treadle II LH | F04 |
| SPD-26674X-B | Guard, Front | F04 |
| SPD-43333X-B | Guard, Lower LH | F04 |
| SPD-90507X-B | Guard, Outer Plate LH | F04 |
| SPD-90607X-B | Guard, Outer Plate RH | F04 |
| SPD-46513X-B | Guard, Steering Bar | F05 |
| SPD-90105X-B | Steering, Guard Mounting Plate | F05 |
| SPD-35100X-B | Switch, Handlebar RH | F05 |
| SPD-35200X-B | Switch, Handlebar LH | F05 |
| SPD-47110X-B | Pipe, Steering Bar | F05 |
| SA-F05-01 | Sub-assembly proxy (F05) | F05 |

---

## Step-by-Step: Setting Up Blender

### Step 1 — Open Blender
- Use Blender **4.x** (tested on 4.1+)
- Switch to the **Scripting** workspace (top tab bar)

### Step 2 — Load the script
- Click **Open** in the text editor → navigate to `blender/blt150_explosion.py`
- Or paste the contents directly

### Step 3 — Set the OBJECTS_DIR path (if needed)
The script auto-resolves the path relative to itself.
If it fails, edit this line near the top of the script:
```python
OBJECTS_DIR = "/absolute/path/to/Project_Micah/assets/Objects"
CATALOG_PATH = "/absolute/path/to/Project_Micah/assets/data/blt150_parts_catalog.json"
```

### Step 4 — Run the script
- Press **Run Script** (▶) in the Scripting workspace
- You'll see `[BLT150] Script registered.` in the console

### Step 5 — Use the N-panel
- Switch to the **3D Viewport**
- Press **N** to open the side panel
- Find the **BLT150** tab

---

## Step-by-Step: Loading a Group

1. In the BLT150 panel, type the group code (e.g. `F02`) into the **Group** field
2. Click **Load Group**
3. The script will import every OBJ it finds for that group
4. Parts with sub-assemblies are imported into sub-collections (hidden by default)
5. If a `SA-F02-01.obj` proxy file exists, it is shown as the collapsed state

---

## Step-by-Step: Explosion Animation

1. Load the group first
2. Click **Explode** — keyframes are set at frame 1 (assembled) and frame 60 (exploded)
3. Press **Space** to play the animation in the viewport
4. Click **Assemble** to animate back to assembled position
5. Adjust `EXPLODE_SCALE` at the top of the script to control how far parts fly

---

## Step-by-Step: Sub-Assembly Expand/Collapse

Sub-assemblies are groups of parts that belong together (e.g. `SA-F02-02` is the front trunk assembly).

- In the BLT150 panel, under **Sub-Assemblies**, you'll see buttons for each SA in the loaded group
- Click an SA button to **expand** it → proxy mesh hides, individual parts show
- Click again to **collapse** → individual parts hide, proxy mesh shows

> If no proxy `.obj` file exists for an SA, the button still works to show/hide the child parts.

---

## Per-Group Checklist

Send one reference image per group. I'll use it to confirm part placement and adjust positions.

| Group | Description | Parts Available | Image Received | Done |
|---|---|---|---|---|
| F01 | Meter Assy | SPD-06114X-B (1 of 3) — missing SPD-37000X-B (Meter Assy), CKI-01004X-B has no OBJ | ✓ | ☐ |
| F02 | Frame Mantle I | SPD-06545/46X-B, SPD-33100X-B, SPD-45467X-B, SPD-89001/101X-B, SPD-90405X-B, SPD-43211X-B | ☐ | ☐ |
| F03 | Frame Mantle II | SPD-43264/265/261X-B, SPD-33550X-B | ☐ | ☐ |
| F04 | Frame Mantle III | SPD-38566X-B, SPD-43433/333X-B, SPD-10259/260/263X-B, SPD-26674X-B, SPD-90507/607X-B | ☐ | ☐ |
| F05 | Grip & Switch & Cables | SPD-46513/90105/35100/35200/47110X-B + SA-F05-01 | ☐ | ☐ |
| F06–F19 | (pending parts) | — | ☐ | ☐ |

---

## Notes & Known Quirks

- Parts without an `.obj` file are **silently skipped** — they still exist in the catalog
- `depth_level` in the catalog is informational (assembly order from the manual) — not yet used for explosion direction, but could be used later for layered explosions
- Duplicate `id` values in the catalog (e.g. two `F02-03` items) represent color variants — both are imported if both `.obj` files exist
- `internal_code` (CKI-xxx) items are fasteners/screws — rarely have 3D models

---

## Todo / Next Steps

- [ ] Receive reference images for each group and align part positions
- [ ] Add per-part labels (text objects anchored to each mesh)
- [ ] Export groups as individual `.glb` files for use in the Flutter app
- [ ] Add depth_level-based layered explosion (parts further from center move more)
- [ ] Build a Flutter widget to embed the Blender output (three.js viewer or model_viewer)
