# 3D Asset Naming Conventions — Project Micah

All 3D assets follow strict naming rules. The Flutter app and the Three.js viewer both depend on these names to wire up clicks, tooltips, and sidebar data.

---

## Uniform Facing Direction (non-negotiable)

**Every exported part must face +X (positive X-axis) as its front.**

```
Blender world axes used in this project:
  +X  →  front of the motorcycle / front of the part
  -X  →  rear
  +Y  →  left side of the motorcycle (rider's left)
  -Y  →  right side of the motorcycle (rider's right)
  +Z  →  up
```

### Why this matters
The Three.js viewer initialises its camera looking at the front (+X direction).
Parts exported with a different orientation will load sideways or backwards in the sidebar 3D preview.

### How to apply before exporting (do this ONCE per Blender session)
In the Blender N-panel → **BLT150 tab**, press **"Rotate All Objects +90° Z"**.

What it does internally:
1. Selects all mesh objects.
2. Rotates the entire scene **+90° around the world Z-axis** (same as A → R → Z → 90 → Enter).
3. Applies the transform to vertex positions so the OBJ exports bake it in.

This converts the original Blender default (+Y forward) to +X forward, which matches the viewer.

> ⚠️ Only run "Rotate All Objects +90° Z" **once**. Running it again will over-rotate the mesh.

### Reference viewport angle (for thumbnail / preview renders)
Use **"Set Reference View"** in the same N-panel tab.

| Setting | Value | Meaning |
|---|---|---|
| Azimuth | 45° | Orbits toward -Y so the bike's right side is partially visible |
| Elevation | 15° | Slight top-down angle, not dead-level |

The camera ends up: front-right quarter view, slightly above, front of motorcycle (+X) facing toward viewer.

---

## File Naming Rules (non-negotiable)

**File names must be exactly the `item_code` or `internal_code` — nothing else.**

```
SPD-06114X-B.obj   ✅
SPD-06114X-B.mtl   ✅
SPD-06114X-B.jpg   ✅

CKI-01004X-B.obj   ✅  (internal_code parts)

SPD-06114X-B_—_Case,_Meter.obj   ❌  (do NOT include name in filename)
```

Renaming is painful — stick to code-only filenames.

---

## Main Assembled (full motorcycle)

The single OBJ shown at the start of assembly mode must be named:
```
main_assembled.obj
main_assembled.mtl
```
One per motorcycle, lives at the root of that model's folder.

---

## OBJ Mesh Naming Rules (inside the file)

These are the mesh object names inside the `.obj` file, set during Blender export. **File name is still just the code** — the human label only lives inside the mesh.

### Regular parts
```
{item_code}_—_{Human Name With Spaces Replaced By Underscores}
```
Examples:
```
SPD-06114X-B_—_Case,_Meter
SPD-33100X-B_—_Headlight_Assy_-_LED_Type
SPD-06545X-B_—_Front_Trunk_Cover_LH
SPD-43211X-B_—_Windshield
SPD-45467X-B_—_Guard,_Front_Cover
```

### Sub-assembly group meshes (inside `F##_assembled.obj`)
```
[SA]_{saCode}
```
Examples:
```
[SA]_SA-F05-01
[SA]_SA-F02-01
```

> The `[SA]_` prefix is how the viewer distinguishes a clickable sub-assembly zone from a regular part. **Do not change this prefix** — the JavaScript `getItemCode()` function strips it to produce the `SA-F05-01` code sent to Flutter.

---

## File Types Per Part

Every part with an `item_code` (SPD- code) should have three files:

| Suffix | Purpose |
|---|---|
| `.obj` | 3D geometry (Wavefront OBJ) |
| `.mtl` | Material definitions |
| `.jpg` | Preview thumbnail shown in sidebar |

---

## BLT150 — All Expected SPD- Part Codes

These are all `item_code` values present in `blt150_parts_catalog.json`.  
Each one that has a 3D model needs `{code}.obj`, `{code}.mtl`, `{code}.jpg`.

```
SPD-02465X-B    SPD-03468X-B    SPD-03732X-B    SPD-03733X-B
SPD-05183X-B    SPD-06114X-B    SPD-06500X-B    SPD-06545X-B
SPD-06546X-B    SPD-06547X-B    SPD-06548X-B    SPD-10259X-B
SPD-10260X-B    SPD-10263X-B    SPD-10264X-B    SPD-16530X-B
SPD-16620X-B    SPD-16700X-B    SPD-16812X-B    SPD-17100X-B
SPD-17120X-B    SPD-17310X-B    SPD-17331X-B    SPD-18000X-B
SPD-18211X-B    SPD-18396X-B    SPD-19121X-B    SPD-20380X-B
SPD-25983X-L    SPD-26674X-B    SPD-27909X-B    SPD-29004X-B
SPD-30700X-B    SPD-31500U      SPD-32100X-B    SPD-33100X-B
SPD-33510X-B    SPD-33550X-B    SPD-33700X-B    SPD-33760X-B
SPD-34790X      SPD-35100X-B    SPD-35200X-B    SPD-35330F
SPD-36150X-B    SPD-37000X-B    SPD-37726X-B    SPD-37810X-B
SPD-37810X-B1   SPD-38100X      SPD-38210X      SPD-38270X-B
SPD-38280X      SPD-38440X-B    SPD-38566X-B    SPD-38945X-B
SPD-38946X-B    SPD-39100X-B    SPD-39310X      SPD-39330X-B
SPD-39513X-B    SPD-39520X-B    SPD-39580X-B    SPD-39601X-B
SPD-39630X-B    SPD-39650X-B    SPD-42110X-B    SPD-42200X-B
SPD-42260X-B    SPD-42300X-B    SPD-42510X-B    SPD-42610X-B
SPD-42913X-B    SPD-42922X-B    SPD-43211X-B    SPD-43211X-B1
SPD-43261X-B    SPD-43262X-B    SPD-43264X-B    SPD-43264X-B1
SPD-43265X-B    SPD-43265X-B1   SPD-43268X-B    SPD-43333X-B
SPD-43361X-B    SPD-43361X-B1   SPD-43433X-B    SPD-43461X-B
SPD-43461X-B1   SPD-43561X-B    SPD-43661X-B1   SPD-43662X-B
SPD-43751X-B    SPD-43751X-B1   SPD-44100X-B    SPD-45467X-B
SPD-45511X-B    SPD-45531X-B    SPD-46300X-B    SPD-46300X-B1
SPD-46513X-B    SPD-46514X-B    SPD-46520X-B    SPD-46530X-B
SPD-46965X-B    SPD-47110X-B    SPD-47300X-B    SPD-47411X-B
SPD-47420X-B    SPD-47511X-B    SPD-47651X-B    SPD-48000X-B
SPD-48340X-B    SPD-51210X-B    SPD-51950X-B    SPD-52400X-B
SPD-52427X-B    SPD-52500X-B    SPD-53111X-B    SPD-53111X-B1
SPD-53303X-B    SPD-54100X-B    SPD-54700X-B    SPD-54911X-B
SPD-54912X-B    SPD-56000X-B    SPD-56311X-B    SPD-56520X
SPD-57100X-B    SPD-57200X-B    SPD-61912X-B    SPD-61913X-B
SPD-62100X-B    SPD-63111X-B    SPD-63131X-B    SPD-63910X-B
SPD-64100X-B    SPD-64700X-B    SPD-66000X-B    SPD-66311X-B
SPD-66520X-B    SPD-73702X-B    SPD-73703X-B    SPD-74302X-B
SPD-74402X-B    SPD-88101X-B    SPD-88201X-B    SPD-88201X-B1
SPD-88401X-B    SPD-88501X-B    SPD-88601X-B    SPD-89001X-B
SPD-89101X-B    SPD-89201X-B    SPD-89301X-B    SPD-89601X-B
SPD-89701X-B    SPD-89801X-B    SPD-90105X-B    SPD-90405X-B
SPD-90507X-B    SPD-90507X-B1   SPD-90607X-B    SPD-90607X-B1
```

**Total: 160 unique item codes** (some share a base code with a variant suffix like `-B1`).

---

## BLT150 — Group Explosion OBJs (`F##_assembled.obj`)

One `.obj` + `.mtl` pair per group exported from Blender.

| File | Group description |
|---|---|
| `F01_assembled.obj/.mtl` | Meter Assy |
| `F02_assembled.obj/.mtl` | Frame Mantle I |
| `F03_assembled.obj/.mtl` | Frame Mantle II |
| `F04_assembled.obj/.mtl` | Frame Mantle III |
| `F05_assembled.obj/.mtl` | Grip & Switch & Cables |
| `F06_assembled.obj/.mtl` | Front Shock Absorber |
| `F07_assembled.obj/.mtl` | Front Wheel |
| `F08_assembled.obj/.mtl` | Rear Wheel |
| `F09_assembled.obj/.mtl` | Fuel Tank |
| `F10_assembled.obj/.mtl` | Seat & Rear Luggage |
| `F11_assembled.obj/.mtl` | Exhaust Muffler & Air Cleaner |
| `F12_assembled.obj/.mtl` | Rear Panel Comp |
| `F13_assembled.obj/.mtl` | Rear Fender Comp |
| `F14_assembled.obj/.mtl` | Frame Weldment Assy |
| `F15_assembled.obj/.mtl` | Electrical Element |
| `F17_assembled.obj/.mtl` | Front & Rear Hydraulic Brake Assy |
| `F18_assembled.obj/.mtl` | Fuel Evaporating System |
| `F19_assembled.obj/.mtl` | EFI System |

> ⚠️ There is no F16 group in the catalog.

Currently exported (in `assets/models/`): F01, F02, F05.  
Remaining 15 groups still need Blender exports.

---

## BLT150 — Sub-Assembly OBJs (`SA-F##-##.obj`)

One `.obj` + `.mtl` + `.jpg` per sub-assembly code. These are shown in the sub-assembly focus overlay when a `[SA]_` mesh is clicked.

| SA Code | Parent Group |
|---|---|
| `SA-F02-01` | F02 — Frame Mantle I |
| `SA-F02-02` | F02 — Frame Mantle I |
| `SA-F03-01` | F03 — Frame Mantle II |
| `SA-F03-02` | F03 — Frame Mantle II |
| `SA-F04-01` | F04 — Frame Mantle III |
| `SA-F04-02` | F04 — Frame Mantle III |
| `SA-F05-01` | F05 — Grip & Switch & Cables ✅ (OBJ exists) |
| `SA-F05-02` | F05 — Grip & Switch & Cables |
| `SA-F06-01` | F06 — Front Shock Absorber |
| `SA-F07-01` | F07 — Front Wheel |
| `SA-F08-01` | F08 — Rear Wheel |
| `SA-F09-01` | F09 — Fuel Tank |
| `SA-F10-01` | F10 — Seat & Rear Luggage |
| `SA-F11-01` | F11 — Exhaust Muffler & Air Cleaner |
| `SA-F12-01` | F12 — Rear Panel Comp |
| `SA-F13-01` | F13 — Rear Fender Comp |
| `SA-F14-01` | F14 — Frame Weldment Assy |
| `SA-F17-01` | F17 — Hydraulic Brake Assy |
| `SA-F17-02` | F17 — Hydraulic Brake Assy |
| `SA-F19-01` | F19 — EFI System |

**Total: 20 sub-assemblies.** Only `SA-F05-01` has a 3D model so far. The rest show "Coming Soon" in the app.
