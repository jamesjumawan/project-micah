"""
BLT150 Parts Catalog — Blender Arrangement Script
==================================================
HOW TO USE:
  1. Open Blender 4.x → Scripting workspace
  2. Open this file → Run Script
  3. In the 3D Viewport press N → BLT150 tab

PANEL FEATURES:
  - Load a specific group or all groups
  - Parts are placed at their diagram reference positions on load
  - Export a group as GLB for the Flutter ThreeDViewer
  - Toggle sub-assembly expand/collapse

Animation (assemble ↔ disassemble) is handled by the Flutter app
via the ThreeDViewer disassemblyDistance slider.

NAMING CONVENTION:
  assets/Objects/<item_code>.obj  (e.g. SPD-06114X-B.obj)
  Sub-assembly proxy: <sa_code>.obj  (e.g. SA-F05-01.obj)
"""

import bpy
import bmesh
import json
import os
from math import radians
from mathutils import Vector, Matrix

# ─────────────────────────────────────────────────────────────────────────────
# CONFIG
# ─────────────────────────────────────────────────────────────────────────────
# __file__ may be unset (Blender text editor) or point to a copy outside the
# project tree.  Always anchor to the canonical project location when the
# derived directory doesn't contain the expected assets folder.
_PROJECT_ROOT = "/Users/tandocaileen/Documents/Project_Micah"
try:
    _SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
    # Validate: the parent must have an assets/ folder; otherwise it's a copy.
    if not os.path.isdir(os.path.join(_SCRIPT_DIR, "..", "assets")):
        raise ValueError
except (NameError, ValueError):
    _SCRIPT_DIR = os.path.join(_PROJECT_ROOT, "blender")

OBJECTS_DIR  = os.path.join(_SCRIPT_DIR, "..", "assets", "Objects")
CATALOG_PATH = os.path.join(_SCRIPT_DIR, "..", "assets", "data", "blt150_parts_catalog.json")
EXPORT_DIR   = os.path.join(_SCRIPT_DIR, "..", "assets", "models")
OVERRIDES_PATH = os.path.join(_SCRIPT_DIR, "blt150_overrides.json")

# ─────────────────────────────────────────────────────────────────────────────
# REFERENCE EXPLODE POSITIONS
# Derived from the official parts diagram images (one per group).
# Format: { "GROUP": { "item_code_or_internal_code": (x, y, z) } }
# Units are Blender meters. Y = depth, Z = up.
# If a part's code is NOT listed here, the generic radial explode is used.
# ─────────────────────────────────────────────────────────────────────────────
REFERENCE_POSITIONS = {
    # F-01 仪表总成 METER ASSY
    # Depth 3: Meter Stay → far left  (deepest = furthest from center)
    # Depth 1: Case Meter → center origin
    # Depth 2: Meter Assy → upper-right
    "F01": {
        "CKI-01004X-B": (-0.25, 0.0,  0.0),   # depth 3 — Meter Stay (left)
        "SPD-06114X-B": ( 0.0,  0.0,  0.0),   # depth 1 — Case, Meter (center)
        "SPD-37000X-B": ( 0.20, 0.0,  0.08),  # depth 2 — Meter Assy (upper-right)
    },

    # F-02 车体护罩总成I FRAME MANTLE I
    # Reference image layout (left cluster → right cluster):
    #   depth 1-2  : windshields / outer plates  → left, slight spread
    #   depth 3    : Guard Front Cover            → lower-center
    #   depth 4-5  : Headlight + Hood (SA-F02-01) → center-top
    #   depth 6    : Steering Lock Cover          → center-right
    #   depth 7    : Trunk Front                  → right
    #   depth 8-9  : Trunk inner plates / covers  → far right
    #   depth 10-11: Inner covers / lugs           → far right, staggered up
    #   depth 12-13: Springs / handles            → far right, higher
    #   depth 14   : Charger Comp                 → far right, top
    "F02": {
        "SPD-73703X-B": (-0.55, 0.0,  0.05),  # F02-01 depth 1  Windshield Plate RH
        "SPD-73702X-B": (-0.50, 0.0, -0.05),  # F02-02 depth 1  Windshield Plate LH
        "SPD-43211X-B": (-0.30, 0.0,  0.10),  # F02-03 depth 2  Windshield
        "SPD-45467X-B": ( 0.0,  0.0, -0.08),  # F02-06 depth 3  Guard Front Cover
        "SPD-33100X-B": ( 0.05, 0.0,  0.20),  # F02-04 depth 4  Headlight Assy
        "SPD-46965X-B": ( 0.10, 0.0,  0.28),  # F02-05 depth 5  Hood Headlight
        "SPD-90405X-B": ( 0.20, 0.0,  0.0),   # F02-15 depth 6  Steering Lock Cover
        "SPD-06500X-B": ( 0.35, 0.0,  0.0),   # F02-14 depth 7  Trunk Front
        "SPD-89301X-B": ( 0.45, 0.0,  0.05),  # F02-07 depth 8  Plate Trunk Inner RH
        "SPD-89201X-B": ( 0.45, 0.0, -0.05),  # F02-08 depth 8  Plate Trunk Inner LH
        "SPD-06546X-B": ( 0.52, 0.0,  0.08),  # F02-17 depth 9  Front Trunk Cover RH
        "SPD-06545X-B": ( 0.52, 0.0, -0.08),  # F02-12 depth 9  Front Trunk Cover LH
        "SPD-06548X-B": ( 0.58, 0.0,  0.10),  # F02-16 depth 10 Inner Cover RH
        "SPD-06547X-B": ( 0.58, 0.0, -0.10),  # F02-11 depth 10 Inner Cover LH
        "SPD-88401X-B": ( 0.62, 0.0,  0.0),   # F02-09 depth 11 Lugs
        "SPD-88601X-B": ( 0.65, 0.0,  0.12),  # F02-19 depth 12 Torsional Spring RH
        "SPD-88501X-B": ( 0.65, 0.0, -0.12),  # F02-10 depth 12 Torsional Spring LH
        "SPD-89101X-B": ( 0.70, 0.0,  0.14),  # F02-18 depth 13 Handle RH
        "SPD-89001X-B": ( 0.70, 0.0, -0.14),  # F02-13 depth 13 Handle LH
        "SPD-36150X-B": ( 0.75, 0.0,  0.18),  # F02-20 depth 14 Charger Comp
    },

    # F-03 车体护罩总成II FRAME MANTLE II
    # Image layout (left → right, low → high):
    #   01 far-left  large blue         → Ornament Front Cowl       depth 1
    #   02 upper-left inner dark panel  → Ornament Headlight RH     depth null→1
    #   03 top-center small dark        → Front Cowl Guard RH       depth 3
    #   04 lower-center large blue      → Winker Front RH           depth 4
    #   05 center-right medium          → Ornament Headlight LH     depth 5
    #   06 lower-right small bracket    → Winker Front LH           depth 7
    #   07 upper-right dark panel       → Front Cowl Guard LH       depth 6
    #   08 far upper-right two circles  → Marked Price (×2)         depth "4,6"→4
    "F03": {
        "SPD-43268X-B":  (-0.45, 0.0,  0.0),   # F03-01 depth 1  Ornament Front Cowl (far left)
        "SPD-43264X-B":  (-0.25, 0.05,  0.15),  # F03-02 depth 1  Ornament Headlight RH Black
        "SPD-43261X-B":  (-0.05, 0.0,   0.20),  # F03-03 depth 3  Front Cowl Guard RH
        "SPD-33510X-B":  ( 0.05, -0.05, -0.08), # F03-04 depth 4  Winker Front RH
        "SPD-43265X-B":  ( 0.15, 0.0,   0.05),  # F03-05 depth 5  Ornament Headlight LH Black
        "SPD-33550X-B":  ( 0.40, 0.0,  -0.12),  # F03-06 depth 7  Winker Front LH (lower-right)
        "SPD-43262X-B":  ( 0.35, 0.0,   0.15),  # F03-07 depth 6  Front Cowl Guard LH (upper-right)
        "CKI-03001X-B":  ( 0.55, 0.0,   0.18),  # F03-08 depth 4  Marked Price ×2 (far upper-right)
    },
    "F04": {
        # SA-F04-01 parts (right/center cluster)
        "SPD-38945X-B":  ( 0.05,  0.05,  0.15),  # F04-11 d1   Guard, Mid
        "SPD-74302X-B":  ( 0.15,  0.10,  0.10),  # F04-10 d2   Cover, Fuel Tank Lock Outer
        "SPD-74402X-B":  ( 0.55,  0.10,  0.00),  # F04-08 d3   Cover, Fuel Tank Lock Inner
        "SPD-88201X-B1": ( 0.55,  0.05,  0.00),  # F04-09 d4   Spring, Fuel Tank Lock Return II
        "SPD-05183X-B":  ( 0.00,  0.05,  0.20),  # F04-20 d5   Bracket, Fuel Tank Cable
        "SPD-88101X-B":  ( 0.55,  0.20,  0.00),  # F04-06 d6   Seat Lock Bracket
        "SPD-88201X-B":  ( 0.55,  0.15,  0.00),  # F04-07 d7   Spring, Fuel Tank Lock Return
        # SA-F04-02 parts (left/center cluster)
        "SPD-38440X-B":  (-0.10,  0.00,  0.20),  # F04-12 d9   Plate, Guard LH
        "SPD-90507X-B1": ( 0.50,  0.05,  0.10),  # F04-18 d8   Guard, Outer Plate LH Black
        # standalone parts
        "SPD-38566X-B":  (-0.55,  0.00,  0.00),  # F04-01       Plate, Guard RH (far left)
        "SPD-43433X-B":  (-0.25,  0.10,  0.10),  # F04-02       Guard, Lower RH
        "SPD-10260X-B":  (-0.20,  0.00,  0.05),  # F04-03       Rubber, Treadle RH
        "SPD-10264X-B":  (-0.05,  0.15,  0.00),  # F04-04       Rubber, Treadle II RH
        "SPD-90607X-B":  ( 0.35,  0.10,  0.05),  # F04-05 Brown Guard, Outer Plate RH
        "SPD-26674X-B":  (-0.45, -0.15,  0.00),  # F04-13       Guard, Front (lower far left)
        "SPD-38946X-B":  (-0.10, -0.15,  0.00),  # F04-14       Bottom Guard
        "SPD-10259X-B":  ( 0.05, -0.10, -0.05),  # F04-15       Rubber, Treadle LH
        "SPD-10263X-B":  ( 0.15, -0.10, -0.05),  # F04-16       Rubber, Treadle II LH
        "SPD-43333X-B":  ( 0.30,  0.00,  0.05),  # F04-17       Guard, Lower LH
        "SPD-90507X-B":  ( 0.50, -0.10,  0.00),  # F04-18 Brown Guard, Outer Plate LH
        "SPD-43561X-B":  ( 0.60,  0.20, -0.10),  # F04-19       Ornament, Engine (far upper right)
        "SPD-89801X-B":  (-0.15,  0.15,  0.05),  # F04-21       Guard, Trim Cover RH
    },
    "F05": {
        # SA-F05-01 proxy (whole handlebar assembly combined mesh)
        "SA-F05-01":     ( 0.00,  0.00,  0.10),  # handlebar proxy — center near origin
        # SA-F05-01 parts (handlebar assembly — center/right)
        "SPD-46513X-B":  (-0.05,  0.00,  0.10),  # F05-02       Guard, Steering Bar (center)
        "SPD-90105X-B":  (-0.35, -0.15,  0.00),  # F05-03       Steering Guard Mounting Plate (lower left)
        "SPD-47300X-B":  (-0.20,  0.15,  0.00),  # F05-04       Throttle Grip Comp. (upper left)
        "SPD-47420X-B":  ( 0.55,  0.15,  0.00),  # F05-05       Balance Weight (upper far right)
        "SPD-35100X-B":  (-0.10,  0.15,  0.05),  # F05-06       Switch, Handlebar RH (upper center-left)
        "SPD-46514X-B":  ( 0.00, -0.05,  0.15),  # F05-07       Grip Guard, Lower (center)
        "SPD-57100X-B":  ( 0.35,  0.20,  0.00),  # F05-08       Mirror, Rear View RH (upper right)
        "SPD-57200X-B":  ( 0.55,  0.20,  0.00),  # F05-09       Mirror, Rear View LH (far upper right)
        "SPD-35200X-B":  ( 0.20,  0.10,  0.05),  # F05-15       Switch, Handlebar LH (center-right)
        "SPD-47411X-B":  ( 0.30, -0.10,  0.00),  # F05-16       Grip, LH (lower right)
        "SPD-47110X-B":  ( 0.15,  0.00,  0.10),  # F05-17       Pipe, Steering Bar (center-right)
        # SA-F05-02 parts (cables)
        "SPD-46300X-B":  (-0.55,  0.00,  0.00),  # F05-01       Throttle Cable (far left loop)
        "SPD-46300X-B1": (-0.50,  0.00,  0.05),  # F05-01       Throttle Cable II (offset)
        "SPD-46530X-B":  (-0.30,  0.00,  0.00),  # F05-10       Cable, Seat Lock (left circle)
        "SPD-46520X-B":  ( 0.05,  0.00,  0.00),  # F05-11       Cable, Fuel Tank Lock (center circle)
    },
    "F06": {
        # F06 — Front Shock Absorber (6 labeled parts)
        # Layout: two fork tubes side by side, fender between them, stem lower-right, bearing set far right
        "SPD-52427X-B":  (-0.55,  0.10,  0.00),  # F06-01/08    Oil Seal / CKI (far left)
        "SPD-52400X-B":  (-0.25,  0.00,  0.00),  # F06-02       Shock Absorber Front RH (left fork)
        "SPD-53111X-B":  ( 0.00,  0.05,  0.05),  # F06-03 Black Fender, Front (center)
        "SPD-52500X-B":  ( 0.25,  0.00,  0.00),  # F06-04       Shock Absorber Front LH (right fork)
        "SPD-51210X-B":  ( 0.45, -0.10,  0.00),  # F06-05       Stem Set, Steering (lower right)
        "SPD-51950X-B":  ( 0.65,  0.00,  0.00),  # F06-06       Steering Stem Bearing Set (far right)
    },
    "F07": {
        # F07 — Front Wheel (8 labeled parts)
        # Layout: tire (large, left), bushes/hub center, brake disc right, brake cable top-right, axle bottom
        "SPD-54700X-B":  (-0.45,  0.00,  0.00),  # F07-02       Tire, Front 110/70-13 (large left)
        "SPD-54912X-B":  ( 0.00, -0.05,  0.00),  # F07-03       Bush, Front Wheel (center)
        "SPD-54100X-B":  ( 0.15,  0.00,  0.00),  # F07-04       Hub Comp., Front Wheel (center-right)
        "SPD-56311X-B":  ( 0.35,  0.00,  0.00),  # F07-06       Disc, Front Brake (right)
        "SPD-54911X-B":  ( 0.05, -0.25,  0.00),  # F07-08       Axle, Front (bottom center)
    },
    "F08": {
        # F08 — Rear Wheel (12 labeled parts)
        # Layout: rear fork (left-center), wheel+tire (right), shock absorber (top right), disc center
        "SPD-29004X-B":  (-0.55,  0.20,  0.00),  # F08-03       Nut, Rear Wheel (top far left)
        "SPD-61912X-B":  (-0.40,  0.00,  0.00),  # F08-04       Sleeve, Rear Fork Outer (left)
        "SPD-37726X-B":  (-0.20,  0.00,  0.00),  # F08-05       Rear Rocker Comp. (center-left)
        "SPD-61913X-B":  (-0.35, -0.10,  0.00),  # F08-06       Sleeve, Rear Fork Inner (lower left)
        "SPD-66311X-B":  ( 0.05,  0.00,  0.00),  # F08-08       Disc, Rear Brake (center)
        "SPD-62100X-B":  ( 0.45,  0.20,  0.00),  # F08-10       Shock Absorber Assy, Rear (top right)
        "SPD-64700X-B":  ( 0.30,  0.00,  0.00),  # F08-11       Tire, Rear 130/70-13 (right)
        "SPD-64100X-B":  ( 0.45, -0.10,  0.00),  # F08-12       Hub Set, Rear Wheel (lower right)
    },
    "F09": {
        # F09 — Fuel Tank (13 items)
        # Layout: hose cable left, reservoir top-left, fuel tank body center, cap top, pump right, filter bottom
        "SPD-19121X-B":  (-0.35,  0.15,  0.00),  # F09-02       Body, Reservoir Tank (upper left)
        "SPD-37810X-B":  (-0.10, -0.10,  0.00),  # F09-04       Sensor, Fuel (lower center-left)
        "SPD-16620X-B":  ( 0.05,  0.00,  0.00),  # F09-07       Weldment Comp., Fuel Tank (center)
        "SPD-16530X-B":  ( 0.05,  0.30,  0.00),  # F09-08       Cap, Fuel Filler (top center)
        "SPD-39520X-B":  ( 0.40,  0.05,  0.00),  # F09-11       Pump, Fuel (right)
        "SPD-16700X-B":  ( 0.55, -0.10,  0.00),  # F09-12       Hose Comp. (lower right)
        "SPD-39513X-B":  (-0.55,  0.00,  0.00),  # F09-13       Filter, Fuel Pump (far left)
    },
    "F10": {
        # F10 — Seat & Rear Luggage (7 items)
        # Layout: seat (large, top-left), seat lock bracket (lower left), trunk pieces (center/right)
        "SPD-44100X-B":  (-0.30,  0.15,  0.00),  # F10-01       Seat Assy (large upper left)
        "SPD-03468X-B":  (-0.30, -0.15,  0.00),  # F10-03       Seat Cushion Opening Bracket (lower left)
        "SPD-43661X-B1": ( 0.30,  0.05,  0.00),  # F10-06       Rear Trunk II (right)
        "SPD-43662X-B":  ( 0.55,  0.05,  0.00),  # F10-07       Cover, Rear Trunk (far right)
    },
    "F11": {
        # F11 — Exhaust Muffler & Air Cleaner (5 parts)
        # Layout: air cleaner body left, filter element center-left, gasket small center, mantle center-right, muffler large right (dashed box)
        "SPD-17100X-B":  (-0.40,  0.05,  0.00),  # F11-01       Air Cleaner Assy. (left body)
        "SPD-17120X-B":  (-0.10,  0.05,  0.00),  # F11-02       Filter Comp., Air Cleaner (center-left element)
        "SPD-18211X-B":  ( 0.55,  0.20,  0.00),  # F11-03       Gasket, Exhaust Muffler (small, top right)
        "SPD-18396X-B":  ( 0.20,  0.00,  0.00),  # F11-04       Mantle, Muffler (center-right)
        "SPD-18000X-B":  ( 0.45, -0.05,  0.00),  # F11-05       Exhaust Muffler Assy. (large right, dashed)
    },
    "F12": {
        # F12 — Rear Panel Comp (7 unique items, Black variants only)
        # Layout: RH panel (left), tail light covers flanking center, LH panel (center-right), connecting plate (top), taillights (far right)
        "SPD-43361X-B":  (-0.45,  0.05,  0.00),  # F12-01 Black Guard, Rear Panel RH (far left)
        "SPD-89701X-B":  (-0.15,  0.10,  0.00),  # F12-02       Tail Light Cover, RH (upper center-left)
        "SPD-43461X-B":  ( 0.05,  0.00,  0.00),  # F12-03 Black Guard, Rear Panel LH (center)
        "SPD-89601X-B":  ( 0.25,  0.00,  0.00),  # F12-04       Tail Light Cover, LH (center-right)
        "SPD-43751X-B":  (-0.10,  0.20,  0.00),  # F12-05/07    Rear-Mid Connecting Plate (top center)
        "SPD-33700X-B":  ( 0.50,  0.10,  0.00),  # F12-05       Taillight Assy., RH (far right upper)
        "SPD-30700X-B":  ( 0.55, -0.05,  0.00),  # F12-06       Taillight Assy., LH (far right lower)
    },
    "F13": {
        # F13 — Rear Fender Comp (5 coded parts, rest are CKI accessories with no OBJ)
        # Layout: tail guard upper-left, fender front body lower-left, bracket center,
        #         rear fender center-right, license plate light right
        "SPD-27909X-B":  (-0.35,  0.15,  0.00),  # F13-02       Tail Light Guard (upper left)
        "SPD-63131X-B":  (-0.45, -0.10,  0.00),  # F13-03       Fender Rear, Front Body (lower left)
        "SPD-63910X-B":  (-0.10,  0.00,  0.00),  # F13-04       Bracket Set, Rear Fender (center)
        "SPD-63111X-B":  ( 0.15,  0.00,  0.00),  # F13-05       Fender, Rear (center-right)
        "SPD-33760X-B":  ( 0.45,  0.05,  0.00),  # F13-06       Light Comp., License Plate (right)
    },
    "F14": {
        # F14 — Frame Weldment Assy (23 labeled positions)
        # Layout: frame body center, footrests/stands left, brackets right cluster, handrails top-right, engine mounts right
        "SPD-42510X-B":  (-0.55,  0.10,  0.00),  # F14-07       Passenger Footrest Comp., RH (far left upper)
        "SPD-42300X-B":  (-0.40, -0.05,  0.00),  # F14-09       Bracket, Footrest Comp. Rider (left)
        "SPD-42200X-B":  (-0.30, -0.20,  0.00),  # F14-10       Stand, Side (lower left)
        "SPD-42922X-B":  (-0.15, -0.20,  0.00),  # F14-11       Spring, Side Stand (lower center-left)
        "SPD-42110X-B":  ( 0.00, -0.25,  0.00),  # F14-12       Stand Set, Center (bottom center)
        "SPD-16812X-B":  ( 0.10, -0.20,  0.00),  # F14-13       Rubber, Center Stand (lower center)
        "SPD-42913X-B":  ( 0.20, -0.20,  0.00),  # F14-14       Spring, Center Stand (lower center-right)
        "SPD-42260X-B":  ( 0.10, -0.30,  0.00),  # F14-15       Shaft, Center Stand (bottom)
        "SPD-42610X-B":  (-0.55, -0.05,  0.00),  # F14-16       Passenger Footrest Comp., LH (far left lower)
        "SPD-02465X-B":  ( 0.40,  0.05,  0.00),  # F14-17       Engine Suspension Mounting (right)
        "SPD-03733X-B":  ( 0.50,  0.00,  0.00),  # F14-18       Shaft II, Engine Mounting (right)
        "SPD-03732X-B":  ( 0.55,  0.05,  0.00),  # F14-19       Shaft I, Engine Mounting (far right)
        "SPD-48340X-B":  ( 0.30,  0.20,  0.00),  # F14-22       Seat Lock Comp. (upper right)
        "SPD-45511X-B":  ( 0.55,  0.25,  0.00),  # F14-24       Handrail, RH (far upper right)
        "SPD-45531X-B":  ( 0.55,  0.15,  0.00),  # F14-25       Handrail, LH (far right)
        "SPD-53303X-B":  ( 0.40, -0.10,  0.00),  # F14-26       Kill Switch, Side Stand (right lower)
    },
    "F15": {
        # F15 — Electrical Element (8 parts)
        # Layout: wiring harness left, ignition center, controller far right, accessories spread lower
        "SPD-32100X-B":  (-0.55,  0.00,  0.00),  # F15-01       Cable, Main (wiring harness, far left)
        "SPD-48000X-B":  (-0.10,  0.05,  0.00),  # F15-02       Switch, Ignition Keyless (center box)
        "SPD-34790X":    ( 0.45,  0.05,  0.00),  # F15-03       Controller, Auto Start/Stop (far right)
        "SPD-38100X":    (-0.35, -0.20,  0.00),  # F15-04       Horn (lower left)
        "SPD-38280X":    (-0.05, -0.20,  0.00),  # F15-05       Relay, EFI Main (lower center-left)
        "SPD-38270X-B":  ( 0.10, -0.20,  0.00),  # F15-06       Auxiliary Relay (lower center)
        "SPD-38210X":    ( 0.30, -0.15,  0.00),  # F15-07       Relay, Flasher (lower center-right)
        "SPD-31500U":    ( 0.55, -0.10,  0.00),  # F15-08       Battery DTX7A-BS (lower far right)
    },
    "F17": {
        # F17 — Front & Rear Hydraulic Brake Assy (10 parts)
        # Layout: front brake assy left cluster, rear brake assy right cluster, brake pads lower, levers center
        "SPD-56000X-B":  (-0.45,  0.05,  0.00),  # F17-01       Front Hydraulic Brake Assy (far left)
        "SPD-56520X":    (-0.30, -0.15,  0.00),  # F17-02       Front Disc Brake Pad (lower left)
        "SPD-35330F":    (-0.15,  0.15,  0.00),  # F17-04       Front Brake Switch (upper center-left)
        "SPD-47511X-B":  ( 0.00,  0.00,  0.00),  # F17-05       Front Brake Lever (center)
        "SPD-66000X-B":  ( 0.35,  0.05,  0.00),  # F17-06       Rear Hydraulic Brake Assy (right)
        "SPD-47651X-B":  ( 0.15, -0.05,  0.00),  # F17-08       Rear Brake Lever (center-right)
        "SPD-66520X-B":  ( 0.55, -0.15,  0.00),  # F17-09       Rear Brake Pad (lower far right)
    },
    "F18": {
        # F18 — Fuel Evaporating System (5 items, 3 have codes)
        # Layout: canister body center, hose loop left, anti-tilt valve right, pipe accessories right side
        "SPD-39580X-B":  ( 0.00,  0.00,  0.00),  # F18-01       Canister, Active Carbon (center body)
        "SPD-20380X-B":  ( 0.35,  0.00,  0.00),  # F18-03       Valve, Anti-tilt (right)
        # hoses/pipes are CKI items — no OBJ codes; accessories on side
    },
    "F19": {
        # F19 — EFI System (10 parts)
        # Layout: ECU box left, bracket lower-left, fuel rail/nozzle center, inlet pipe center, throttle valve right,
        #         sensors right side, oxygen sensor cable lower-right
        "SPD-39100X-B":  (-0.45,  0.05,  0.00),  # F19-01       ECU (large box, far left)
        "SPD-39630X-B":  (-0.10,  0.10,  0.00),  # F19-03       Rail Comp., Fuel (upper center-left)
        "SPD-39650X-B":  (-0.05,  0.00,  0.00),  # F19-04       Nozzle (center)
        "SPD-17331X-B":  ( 0.10, -0.05,  0.00),  # F19-05       Inlet Pipe Insulator (center)
        "SPD-39310X":    ( 0.10, -0.20,  0.00),  # F19-06       Sensor, Oxygen (cable lower center)
        "SPD-17310X-B":  ( 0.25,  0.00,  0.00),  # F19-07       Pipe Set, Inlet (center-right)
        "SPD-39330X-B":  (-0.25,  0.20,  0.00),  # F19-08       Sensor, Intake Air Pressure (upper left)
        "SPD-39601X-B":  ( 0.40,  0.05,  0.00),  # F19-09       Throttle Valve Assy. (right)
        "SPD-25983X-L":  ( 0.55, -0.05,  0.00),  # F19-10       Sensor, Water Temperature (far right)
    },
}
# ─────────────────────────────────────────────────────────────────────────────

# ─────────────────────────────────────────────────────────────────────────────
# ASSEMBLED POSITIONS — real 3D motorcycle coordinates
# Coordinate system: X = right (+right), Y = front (+toward front wheel), Z = up
# Origin: midpoint of wheelbase at ground level.
# BLT150 real dims: wheelbase 1.34m, seat 0.77m, handlebar 0.94m, total height 1.15m
# Front axle ≈ (0, +0.67, +0.25), Rear axle ≈ (0, -0.67, +0.25)
# Steering head ≈ (0, +0.38, +0.72), Handlebar ≈ (0, +0.22, +0.94)
# Meter/dash (faces rider, behind bars) ≈ (0, +0.14, +0.89)
# Headlight (front cowl nose, faces forward) ≈ (0, +0.52, +0.65)
# Windshield (above dash, tall) ≈ (0, +0.27, +1.02)
# ─────────────────────────────────────────────────────────────────────────────
ASSEMBLED_POSITIONS = {
    # F01 — Meter Assembly (dashboard, faces rider, at base of windshield)
    "F01": {
        "SPD-06114X-B": ( 0.00,  0.14,  0.89),  # Case, Meter — dashboard, facing rider
        "SPD-37000X-B": ( 0.00,  0.14,  0.90),  # Meter Assy — inside case
        "CKI-01004X-B": ( 0.00,  0.16,  0.86),  # Meter Stay — bracket below
    },
    # F02 — Frame Mantle I (front cowl panels: windshield, headlight, front trunk)
    # Windshield sits high above dash (Z≈1.02). Headlight is on the FRONT NOSE (Y≈0.52, Z≈0.65).
    # Front trunk (storage box) is in the apron below the dash (Y≈0.20, Z≈0.64).
    "F02": {
        "SPD-43211X-B": ( 0.00,  0.27,  1.02),  # Windshield — tall, above/behind handlebar
        "SPD-73703X-B": ( 0.08,  0.27,  0.93),  # Windshield Mount Plate RH
        "SPD-73702X-B": (-0.08,  0.27,  0.93),  # Windshield Mount Plate LH
        "SPD-33100X-B": ( 0.00,  0.52,  0.65),  # Headlight — front nose of cowl
        "SPD-46965X-B": ( 0.00,  0.51,  0.70),  # Hood, Headlight — above light
        "SPD-45467X-B": ( 0.00,  0.52,  0.50),  # Guard, Front Cover — below headlight
        "SPD-90405X-B": ( 0.00,  0.16,  0.82),  # Steering Lock Cover — near column
        "SPD-06500X-B": ( 0.00,  0.20,  0.64),  # Front Trunk — apron storage box
        "SPD-89301X-B": ( 0.10,  0.19,  0.62),  # Front Trunk Inner Plate RH
        "SPD-89201X-B": (-0.10,  0.19,  0.62),  # Front Trunk Inner Plate LH
        "SPD-06546X-B": ( 0.12,  0.22,  0.60),  # Front Trunk Cover RH
        "SPD-06545X-B": (-0.12,  0.22,  0.60),  # Front Trunk Cover LH
        "SPD-06548X-B": ( 0.14,  0.20,  0.58),  # Inner Cover RH
        "SPD-06547X-B": (-0.14,  0.20,  0.58),  # Inner Cover LH
        "SPD-88401X-B": ( 0.00,  0.19,  0.60),  # Mounting Lugs
        "SPD-88601X-B": ( 0.06,  0.18,  0.60),  # Torsional Spring RH
        "SPD-88501X-B": (-0.06,  0.18,  0.60),  # Torsional Spring LH
        "SPD-89101X-B": ( 0.10,  0.17,  0.62),  # Handle, Front Trunk Opening RH
        "SPD-89001X-B": (-0.10,  0.17,  0.62),  # Handle, Front Trunk Opening LH
        "SPD-36150X-B": ( 0.10,  0.16,  0.58),  # Charger Comp
    },
    # F03 — Frame Mantle II (headlight housing ornaments, front cowl guards, winkers)
    # These flank the headlight area on the sides of the front cowl.
    "F03": {
        "SPD-43268X-B": ( 0.00,  0.49,  0.55),  # Ornament, Front Cowl — lower center front
        "SPD-43264X-B": ( 0.14,  0.48,  0.65),  # Ornament, Headlight Housing RH
        "SPD-43261X-B": ( 0.20,  0.44,  0.60),  # Front Cowl Guard RH
        "SPD-33510X-B": ( 0.22,  0.49,  0.57),  # Winker Front RH — corner of cowl
        "SPD-43265X-B": (-0.14,  0.48,  0.65),  # Ornament, Headlight Housing LH
        "SPD-33550X-B": (-0.22,  0.49,  0.57),  # Winker Front LH — corner of cowl
        "SPD-43262X-B": (-0.20,  0.44,  0.60),  # Front Cowl Guard LH
        "CKI-03001X-B": ( 0.00,  0.46,  0.54),  # Marked Price
    },
    # F04 — Frame Mantle III (body side panels, lower guards, treadles, footboard)
    # Guard Mid is the large center body panel. Guard,Front (SPD-26674X-B) is the
    # LOWER FRONT LEGSHIELD — the front face of the lower cowl above the front wheel.
    "F04": {
        "SPD-38945X-B": ( 0.00,  0.04,  0.48),  # Guard Mid — large center body panel
        "SPD-74302X-B": ( 0.08,  0.12,  0.66),  # Cover, Fuel Tank Lock Outer
        "SPD-74402X-B": ( 0.08,  0.12,  0.64),  # Cover, Fuel Tank Lock Inner
        "SPD-88201X-B1":( 0.10,  0.12,  0.62),  # Spring, Fuel Tank Lock Return II
        "SPD-05183X-B": ( 0.06,  0.12,  0.60),  # Bracket, Fuel Tank Cable
        "SPD-88101X-B": ( 0.05, -0.08,  0.69),  # Seat Lock Bracket — under seat
        "SPD-88201X-B": ( 0.08,  0.12,  0.63),  # Spring, Fuel Tank Lock Return
        "SPD-38440X-B": (-0.22,  0.04,  0.50),  # Plate Guard LH
        "SPD-90507X-B1":(-0.22, -0.04,  0.52),  # Guard Outer Plate LH Black
        "SPD-38566X-B": ( 0.22,  0.04,  0.50),  # Plate Guard RH
        "SPD-43433X-B": ( 0.22, -0.02,  0.38),  # Guard Lower RH
        "SPD-10260X-B": ( 0.24,  0.10,  0.14),  # Rubber Treadle RH — footboard
        "SPD-10264X-B": ( 0.26,  0.08,  0.12),  # Rubber Treadle II RH
        "SPD-90607X-B": ( 0.22, -0.04,  0.52),  # Guard Outer Plate RH Brown
        "SPD-26674X-B": ( 0.00,  0.46,  0.34),  # Guard, Front — lower front legshield
        "SPD-38946X-B": ( 0.00,  0.06,  0.10),  # Bottom Guard — under floorboard
        "SPD-10259X-B": (-0.24,  0.10,  0.14),  # Rubber Treadle LH — footboard
        "SPD-10263X-B": (-0.26,  0.08,  0.12),  # Rubber Treadle II LH
        "SPD-43333X-B": (-0.22, -0.02,  0.38),  # Guard Lower LH
        "SPD-90507X-B": (-0.22, -0.04,  0.52),  # Guard Outer Plate LH Brown
        "SPD-43561X-B": ( 0.16, -0.14,  0.30),  # Ornament Engine — right side
        "SPD-89801X-B": ( 0.22,  0.06,  0.46),  # Guard Trim Cover RH
    },
    # F05 — Handlebar Assembly (grips, switches, cables, mirrors)
    # Bar center at Y≈+0.22 (behind steering head at Y≈+0.38), Z≈+0.94
    "F05": {
        "SA-F05-01":    ( 0.00,  0.22,  0.95),  # Handlebar SA proxy — full bar assembly
        "SPD-47110X-B": ( 0.00,  0.22,  0.95),  # Pipe, Steering Bar — the bar itself
        "SPD-46513X-B": ( 0.00,  0.22,  0.93),  # Guard, Steering Bar — center clamp
        "SPD-90105X-B": ( 0.00,  0.26,  0.88),  # Steering Guard Mounting Plate
        "SPD-47300X-B": ( 0.30,  0.22,  0.95),  # Throttle Grip — right end
        "SPD-47420X-B": (-0.34,  0.22,  0.95),  # Balance Weight — left end
        "SPD-35100X-B": ( 0.24,  0.22,  0.95),  # Switch Handlebar RH
        "SPD-35200X-B": (-0.24,  0.22,  0.95),  # Switch Handlebar LH
        "SPD-46514X-B": ( 0.00,  0.22,  0.90),  # Grip Guard Lower
        "SPD-57100X-B": ( 0.32,  0.21,  1.02),  # Mirror RH — above right grip
        "SPD-57200X-B": (-0.32,  0.21,  1.02),  # Mirror LH — above left grip
        "SPD-47411X-B": (-0.30,  0.22,  0.95),  # Grip LH — left end
        "SPD-46300X-B": ( 0.04,  0.16,  0.74),  # Throttle Cable — routed down-rear
        "SPD-46300X-B1":( 0.02,  0.15,  0.72),  # Throttle Cable II
        "SPD-46530X-B": ( 0.05,  0.15,  0.70),  # Cable Seat Lock
        "SPD-46520X-B": ( 0.08,  0.15,  0.68),  # Cable Fuel Tank Lock
    },
    # F06 — Front Shock Absorber (telescopic forks, steering stem, front fender)
    # Forks run from steering head (Y≈+0.38, Z≈+0.72) down to front axle (Y≈+0.67, Z≈+0.25)
    "F06": {
        "SPD-51210X-B": ( 0.00,  0.38,  0.72),  # Stem Set, Steering — top of fork
        "SPD-51950X-B": ( 0.00,  0.38,  0.70),  # Steering Stem Bearing Set
        "SPD-52400X-B": ( 0.05,  0.60,  0.48),  # Shock Absorber Front RH — fork tube
        "SPD-52500X-B": (-0.05,  0.60,  0.48),  # Shock Absorber Front LH — fork tube
        "SPD-52427X-B": ( 0.00,  0.62,  0.28),  # Oil Seal — at fork lower
        "SPD-53111X-B": ( 0.00,  0.60,  0.42),  # Fender, Front — over front wheel
    },
    # F07 — Front Wheel (all parts at front axle position)
    "F07": {
        "SPD-54700X-B": ( 0.00,  0.67,  0.25),  # Tire Front (110/70-13)
        "SPD-54912X-B": ( 0.00,  0.67,  0.25),  # Bush Front Wheel
        "SPD-54100X-B": ( 0.00,  0.67,  0.25),  # Hub Comp Front Wheel
        "SPD-56311X-B": ( 0.06,  0.67,  0.25),  # Disc Front Brake — offset
        "SPD-54911X-B": ( 0.00,  0.67,  0.25),  # Axle Front
    },
    # F08 — Rear Wheel (all parts at rear axle; shock runs diagonally up-forward)
    "F08": {
        "SPD-64700X-B": ( 0.00, -0.67,  0.26),  # Tire Rear (130/70-13)
        "SPD-64100X-B": ( 0.00, -0.67,  0.26),  # Hub Rear Wheel
        "SPD-29004X-B": ( 0.00, -0.67,  0.26),  # Nut Rear Wheel
        "SPD-66311X-B": ( 0.06, -0.67,  0.26),  # Disc Rear Brake — offset
        "SPD-62100X-B": ( 0.06, -0.38,  0.50),  # Shock Absorber Rear — angled strut
        "SPD-61912X-B": ( 0.00, -0.52,  0.26),  # Sleeve Rear Fork Outer
        "SPD-61913X-B": ( 0.00, -0.52,  0.25),  # Sleeve Rear Fork Inner
        "SPD-37726X-B": ( 0.00, -0.44,  0.30),  # Rear Rocker Comp
    },
    # F09 — Fuel Tank (under-floor/apron area, filler cap on left side)
    "F09": {
        "SPD-16620X-B": ( 0.00,  0.06,  0.54),  # Weldment, Fuel Tank — main body
        "SPD-16530X-B": (-0.08,  0.06,  0.72),  # Cap, Fuel Filler — side access
        "SPD-19121X-B": ( 0.08,  0.06,  0.56),  # Body, Reservoir Tank
        "SPD-37810X-B": ( 0.00,  0.06,  0.52),  # Sensor Fuel
        "SPD-39520X-B": ( 0.05,  0.04,  0.50),  # Pump Fuel
        "SPD-16700X-B": ( 0.00,  0.04,  0.46),  # Hose Comp
        "SPD-39513X-B": ( 0.10,  0.04,  0.48),  # Filter Fuel Pump
    },
    # F10 — Seat & Rear Luggage
    "F10": {
        "SPD-44100X-B":  ( 0.00, -0.22,  0.78),  # Seat Assy — rider sits here
        "SPD-03468X-B":  ( 0.00, -0.20,  0.72),  # Seat Cushion Opening Bracket
        "SPD-43661X-B1": ( 0.00, -0.44,  0.73),  # Rear Trunk II — luggage box
        "SPD-43662X-B":  ( 0.00, -0.46,  0.71),  # Cover Rear Trunk
    },
    # F11 — Exhaust Muffler & Air Cleaner
    # Air cleaner: left side of engine. Muffler: right side, exits at rear-right.
    "F11": {
        "SPD-17100X-B": (-0.15, -0.12,  0.34),  # Air Cleaner Assy — left side
        "SPD-17120X-B": (-0.15, -0.12,  0.36),  # Filter, Air Cleaner — inside
        "SPD-18211X-B": ( 0.12, -0.20,  0.23),  # Gasket, Exhaust Muffler
        "SPD-18396X-B": ( 0.15, -0.22,  0.25),  # Mantle, Muffler — heat shield
        "SPD-18000X-B": ( 0.16, -0.46,  0.22),  # Exhaust Muffler Assy — right rear
    },
    # F12 — Rear Panel Comp (rear body panels, tail lights)
    "F12": {
        "SPD-43361X-B": ( 0.16, -0.44,  0.52),  # Guard Rear Panel RH
        "SPD-89701X-B": ( 0.14, -0.48,  0.50),  # Tail Light Cover RH
        "SPD-43461X-B": (-0.16, -0.44,  0.52),  # Guard Rear Panel LH
        "SPD-89601X-B": (-0.14, -0.48,  0.50),  # Tail Light Cover LH
        "SPD-43751X-B": ( 0.00, -0.40,  0.56),  # Rear-Mid Connecting Plate
        "SPD-33700X-B": ( 0.15, -0.54,  0.50),  # Taillight Assy RH
        "SPD-30700X-B": (-0.15, -0.54,  0.50),  # Taillight Assy LH
    },
    # F13 — Rear Fender & License Plate (5 coded parts in catalog)
    "F13": {
        "SPD-27909X-B": ( 0.00, -0.58,  0.50),  # Tail Light Guard
        "SPD-63131X-B": ( 0.00, -0.58,  0.36),  # Fender Rear Front Body
        "SPD-63910X-B": ( 0.00, -0.58,  0.40),  # Bracket Set Rear Fender
        "SPD-63111X-B": ( 0.00, -0.64,  0.46),  # Fender Rear — over rear wheel
        "SPD-33760X-B": ( 0.00, -0.69,  0.36),  # License Plate Light
    },
    # F14 — Stands, Footrests, Handrails, Engine Mounting
    "F14": {
        "SPD-42510X-B": ( 0.28, -0.35,  0.22),  # Passenger Footrest RH
        "SPD-42610X-B": (-0.28, -0.35,  0.22),  # Passenger Footrest LH
        "SPD-42300X-B": ( 0.00, -0.05,  0.20),  # Bracket, Footrest
        "SPD-42200X-B": (-0.12, -0.25,  0.06),  # Side Stand — left lower
        "SPD-42922X-B": (-0.12, -0.25,  0.08),  # Spring Side Stand
        "SPD-42110X-B": ( 0.00, -0.02,  0.06),  # Center Stand
        "SPD-16812X-B": ( 0.00, -0.02,  0.05),  # Rubber Center Stand
        "SPD-42913X-B": ( 0.02, -0.02,  0.06),  # Spring Center Stand
        "SPD-42260X-B": ( 0.00, -0.02,  0.06),  # Shaft Center Stand
        "SPD-02465X-B": ( 0.08, -0.12,  0.26),  # Engine Suspension Mounting
        "SPD-03733X-B": ( 0.06, -0.12,  0.24),  # Shaft II Engine Mounting
        "SPD-03732X-B": ( 0.04, -0.12,  0.22),  # Shaft I Engine Mounting
        "SPD-48340X-B": ( 0.04, -0.08,  0.68),  # Seat Lock Comp
        "SPD-45511X-B": ( 0.14, -0.32,  0.62),  # Handrail RH — rear grab rail
        "SPD-45531X-B": (-0.14, -0.32,  0.62),  # Handrail LH — rear grab rail
        "SPD-53303X-B": (-0.15, -0.22,  0.14),  # Kill Switch Side Stand
    },
    # F15 — Electrical (wiring, battery, switches, relays)
    "F15": {
        "SPD-32100X-B": ( 0.00,  0.00,  0.44),  # Main Cable Harness
        "SPD-48000X-B": ( 0.00,  0.17,  0.84),  # Ignition Switch — front dash
        "SPD-34790X":   ( 0.10, -0.10,  0.52),  # Controller
        "SPD-38100X":   (-0.14,  0.08,  0.40),  # Horn
        "SPD-38280X":   ( 0.10, -0.06,  0.50),  # Relay EFI Main
        "SPD-38270X-B": ( 0.12, -0.06,  0.48),  # Auxiliary Relay
        "SPD-38210X":   ( 0.14, -0.06,  0.46),  # Relay Flasher
        "SPD-31500U":   ( 0.00, -0.24,  0.42),  # Battery — under seat
    },
    # F17 — Hydraulic Brakes (calipers near wheels; levers on handlebar)
    "F17": {
        "SPD-56000X-B": ( 0.06,  0.64,  0.28),  # Front Brake Caliper — front wheel
        "SPD-56520X":   ( 0.06,  0.64,  0.26),  # Front Disc Brake Pad
        "SPD-35330F":   ( 0.22,  0.22,  0.95),  # Front Brake Switch — handlebar RH
        "SPD-47511X-B": ( 0.26,  0.22,  0.96),  # Front Brake Lever — handlebar RH
        "SPD-66000X-B": ( 0.06, -0.64,  0.30),  # Rear Brake Caliper — rear wheel
        "SPD-47651X-B": (-0.26,  0.22,  0.95),  # Rear Brake Lever — handlebar LH
        "SPD-66520X-B": ( 0.06, -0.64,  0.26),  # Rear Disc Brake Pad
    },
    # F18 — Fuel Evaporating System
    "F18": {
        "SPD-39580X-B": (-0.12,  0.04,  0.46),  # Canister, Active Carbon
        "SPD-20380X-B": (-0.10,  0.06,  0.48),  # Valve, Anti-tilt
    },
    # F19 — EFI System (ECU, fuel rail, throttle body, sensors — under seat/engine area)
    "F19": {
        "SPD-39100X-B": ( 0.12, -0.10,  0.38),  # ECU — controller box
        "SPD-39630X-B": ( 0.00, -0.12,  0.42),  # Rail Comp, Fuel
        "SPD-39650X-B": ( 0.00, -0.12,  0.40),  # Nozzle
        "SPD-17331X-B": ( 0.00, -0.14,  0.38),  # Inlet Pipe Insulator
        "SPD-39310X":   ( 0.14, -0.28,  0.26),  # Sensor Oxygen — near muffler
        "SPD-17310X-B": ( 0.00, -0.14,  0.42),  # Pipe Set, Inlet
        "SPD-39330X-B": ( 0.08, -0.10,  0.44),  # Sensor, Intake Air Pressure
        "SPD-39601X-B": ( 0.00, -0.12,  0.46),  # Throttle Valve Assy
        "SPD-25983X-L": ( 0.05, -0.16,  0.34),  # Sensor, Water Temperature
    },
}
# ─────────────────────────────────────────────────────────────────────────────


# ──────────────────────────── helpers ────────────────────────────────────────

def load_catalog():
    path = os.path.normpath(CATALOG_PATH)
    with open(path, "r", encoding="utf-8") as f:
        return json.load(f)


# ─────────────────────────────────────────────────────────────────────────────
# PART ROTATIONS  (Euler XYZ in degrees)
# Each scan was captured in an arbitrary orientation. Add corrections here
# once you visually confirm the wrong angle for each part.
# Workflow:
#   1. Load a single group, click the part in the viewport to select it
#   2. Rotate it manually (R → X/Y/Z → degrees) until it looks right
#   3. Click "Print Rotation" in the N-panel — it prints the values to Terminal
#   4. Copy those values into this dict under the part's item_code
# ─────────────────────────────────────────────────────────────────────────────
PART_ROTATIONS = {
    # "ITEM_CODE": (rx_deg, ry_deg, rz_deg),
    # F01
    "SPD-06114X-B": (-589.0,  -40.0,  570.0),  # Case, Meter — facing rider
    # F02
    "SPD-43211X-B": ( 283.0, -167.0, -160.0),  # Windshield
    "SPD-45467X-B": (-141.0,  -45.0,  536.0),  # Guard, Front Cover
    "SPD-33100X-B": ( 893.0,  -13.0,  440.0),  # Headlight
    "SPD-06545X-B": ( 102.0,   15.0, -138.0),  # Front Trunk Cover LH
    "SPD-89001X-B": ( 552.0,  700.0, -991.0),  # Handle, Front Trunk Opening LH
    "SPD-90405X-B": (-192.0,  246.0,   87.0),  # Steering Lock Cover
    "SPD-06546X-B": (  94.0,   11.0, -134.0),  # Front Trunk Cover RH
    "SPD-89101X-B": ( 191.0,  -31.0,  234.0),  # Handle, Front Trunk Opening RH
    # F04
    "SPD-26674X-B": ( -74.4,  -52.1,  235.8),  # Guard, Front (lower legshield)
    # F05
    "SA-F05-01":    (  -1.0,   44.0,  385.0),  # Handlebar SA proxy
}
# ─────────────────────────────────────────────────────────────────────────────


def fix_viewport_clipping(clip_start=0.001, clip_end=1000.0):
    """Set clip distances on every 3D viewport so objects don't vanish on zoom."""
    for window in bpy.context.window_manager.windows:
        for area in window.screen.areas:
            if area.type == "VIEW_3D":
                for space in area.spaces:
                    if space.type == "VIEW_3D":
                        space.clip_start = clip_start
                        space.clip_end   = clip_end


def get_or_make_collection(name, parent=None):
    if name in bpy.data.collections:
        col = bpy.data.collections[name]
    else:
        col = bpy.data.collections.new(name)
        target = parent if parent else bpy.context.scene.collection
        target.children.link(col)
    return col


def obj_file(code):
    """Return the .obj path for a given item_code or internal_code, or None."""
    if not code:
        return None
    path = os.path.join(OBJECTS_DIR, f"{code}.obj")
    return path if os.path.exists(path) else None


def import_obj(filepath, collection):
    """Import a single .obj file, scale mm→m, center origin, move into collection."""
    before = set(bpy.data.objects)
    bpy.ops.wm.obj_import(filepath=filepath)
    imported = list(set(bpy.data.objects) - before)

    for obj in imported:
        if obj.type != "MESH":
            continue
        mesh = obj.data
        if not mesh.vertices:
            continue

        # mesh.transform() is a direct C-level API — unlike BMesh or mesh.vertices
        # iteration it cannot be defeated by Blender's depsgraph caching.

        # Step 1: scale all vertex positions mm → m in-place
        mesh.transform(Matrix.Scale(0.001, 4))

        # Step 2: bounding-box centre from the now metre-scale vertices
        xs = [v.co.x for v in mesh.vertices]
        ys = [v.co.y for v in mesh.vertices]
        zs = [v.co.z for v in mesh.vertices]
        center = Vector((
            (min(xs) + max(xs)) / 2,
            (min(ys) + max(ys)) / 2,
            (min(zs) + max(zs)) / 2,
        ))

        # Step 3: translate so geometry centre sits at local origin
        mesh.transform(Matrix.Translation(-center))
        mesh.update()

        # Zero out object transform; apply_part_position will place it
        obj.location      = Vector((0.0, 0.0, 0.0))
        obj.scale         = Vector((1.0, 1.0, 1.0))
        obj.rotation_euler = (0.0, 0.0, 0.0)

    # move to the target collection
    for obj in imported:
        for col in list(obj.users_collection):
            col.objects.unlink(obj)
        collection.objects.link(obj)
    return imported


def apply_part_position(obj, group_code, mode, overrides=None):
    """Move obj to its position and apply rotation for the given mode.
    overrides: dict loaded from blt150_overrides.json, or None.
    Overrides take priority over ASSEMBLED_POSITIONS and PART_ROTATIONS.
    """
    code = obj.get("item_code") or obj.get("internal_code", "")

    if overrides:
        # Position override (works for both assembled and explosion modes)
        pos = overrides.get("positions", {}).get(group_code, {}).get(code)
        if pos:
            obj.location = Vector(pos)
        else:
            pos_dict = ASSEMBLED_POSITIONS if mode == "assembled" else REFERENCE_POSITIONS
            ref = pos_dict.get(group_code, {})
            if code and code in ref:
                obj.location = Vector(ref[code])
        # Rotation override
        rot_deg = overrides.get("rotations", {}).get(code)
        if rot_deg is None:
            rot_deg = PART_ROTATIONS.get(code, (0.0, 0.0, 0.0))
    else:
        pos_dict = ASSEMBLED_POSITIONS if mode == "assembled" else REFERENCE_POSITIONS
        ref = pos_dict.get(group_code, {})
        if code and code in ref:
            obj.location = Vector(ref[code])
        rot_deg = PART_ROTATIONS.get(code, (0.0, 0.0, 0.0))

    obj.rotation_euler = tuple(radians(a) for a in rot_deg)


# ──────────────────────────── core loader ────────────────────────────────────

def load_group(group_code, mode="assembled"):
    """
    Import all available OBJ files for a group.

    Collection hierarchy:
      Scene
      └── BLT150
          └── <group_code>  (e.g. F02)
              ├── <SA_CODE>  ← sub-assembly collection (hidden by default)
              │   └── <part objects>
              └── <standalone part objects>

    Sub-assemblies that have their own .obj (SA-F05-01.obj) are imported as a
    single combined mesh into the group collection. Clicking "Expand SA" in the
    panel hides the combined mesh and shows the individual children.
    """
    # Load overrides once per group load
    overrides = None
    print(f"[BLT150] OVERRIDES_PATH = {OVERRIDES_PATH}")
    print(f"[BLT150] overrides file exists = {os.path.exists(OVERRIDES_PATH)}")
    if os.path.exists(OVERRIDES_PATH):
        try:
            with open(OVERRIDES_PATH, "r", encoding="utf-8") as f:
                overrides = json.load(f)
            keys = list(overrides.get("positions", {}).keys())
            print(f"[BLT150] overrides loaded OK — position groups: {keys}")
        except Exception as e:
            print(f"[BLT150] Could not load overrides: {e}")
    catalog = load_catalog()
    group_data = next((g for g in catalog["groups"] if g["group"] == group_code), None)
    if group_data is None:
        print(f"[BLT150] Group {group_code} not found in catalog.")
        return

    root_col  = get_or_make_collection("BLT150")
    group_col = get_or_make_collection(group_code, root_col)

    # track which objects belong to which sub-assembly
    sa_collections = {}   # sa_code -> collection
    sa_proxy_objects = {} # sa_code -> combined proxy obj (if file exists)

    # ── 1. create sub-assembly collections ──────────────────────────────────
    for sa in group_data.get("sub_assemblies", []):
        sa_code = sa["code"]
        sa_col  = get_or_make_collection(f"{group_code}_{sa_code}", group_col)
        sa_collections[sa_code] = sa_col

        # if a combined SA obj file exists, import it into group_col (not sa_col)
        # and hide the individual-parts collection (user can expand via Toggle SA).
        # If NO proxy exists, leave the collection VISIBLE so parts show up assembled.
        sa_path = obj_file(sa_code)
        if sa_path:
            sa_col.hide_viewport = True   # proxy covers it — collapse individual parts
            proxy = import_obj(sa_path, group_col)
            for o in proxy:
                o.name = f"[SA] {sa_code}"
                o["item_code"] = sa_code
                o["group"]     = group_code
                apply_part_position(o, group_code, mode, overrides)
            sa_proxy_objects[sa_code] = proxy
        else:
            sa_col.hide_viewport = False  # no proxy — show individual parts directly

    # ── 2. import individual part OBJs ──────────────────────────────────────
    seen_codes = set()
    for item in group_data.get("items", []):
        code = item.get("item_code") or item.get("internal_code")
        if not code or code in seen_codes:
            continue
        seen_codes.add(code)

        path = obj_file(code)
        if not path:
            continue

        sa_code = item.get("sub_assembly")
        target_col = sa_collections.get(sa_code, group_col) if sa_code else group_col

        imported = import_obj(path, target_col)
        desc = item.get("description") or code
        # depth_level may be int, string like "3,5", or null
        raw_depth = item.get("depth_level")
        if isinstance(raw_depth, (int, float)):
            depth = int(raw_depth)
        elif isinstance(raw_depth, str):
            # e.g. "3,5" — use the first number
            depth = int(raw_depth.split(",")[0].strip())
        else:
            depth = 1  # default to outermost if unknown
        for o in imported:
            o.name = f"{code} — {desc}"
            o["item_code"]    = code
            o["description"]  = desc or ""
            o["group"]        = group_code
            o["sub_assembly"] = sa_code or ""
            o["depth_level"]  = depth
            apply_part_position(o, group_code, mode, overrides)

    fix_viewport_clipping()
    print(f"[BLT150] Group {group_code} loaded ({mode}).")


# ──────────────────────────── sub-assembly toggle ────────────────────────────

def toggle_sub_assembly(group_code, sa_code):
    """
    Toggle between:
      - SA proxy mesh visible + individual parts hidden  (collapsed)
      - SA proxy mesh hidden  + individual parts visible (expanded)
    Only meaningful when a proxy OBJ exists for the SA.
    """
    sa_col_name = f"{group_code}_{sa_code}"
    sa_col = bpy.data.collections.get(sa_col_name)

    # find proxy objects tagged [SA] sa_code inside the group collection
    group_col = bpy.data.collections.get(group_code)
    proxies = []
    if group_col:
        for obj in group_col.objects:
            if obj.name.startswith(f"[SA] {sa_code}"):
                proxies.append(obj)

    # No proxy means individual parts are always visible — nothing to toggle
    if sa_col is None or not proxies:
        return

    currently_expanded = not sa_col.hide_viewport

    if currently_expanded:
        # collapse: show proxy, hide individual parts
        sa_col.hide_viewport = True
        for p in proxies:
            p.hide_viewport = False
    else:
        # expand: hide proxy, show individual parts
        sa_col.hide_viewport = False
        for p in proxies:
            p.hide_viewport = True

    print(f"[BLT150] SA {sa_code} {'collapsed' if currently_expanded else 'expanded'}.")


# ──────────────────────────── Blender UI Panel ───────────────────────────────

class BLT150_Props(bpy.types.PropertyGroup):
    group_code: bpy.props.StringProperty(
        name="Group",
        description="e.g. F02",
        default="F02"
    )
    view_mode: bpy.props.EnumProperty(
        name="Mode",
        items=[
            ("assembled",    "Assembled",    "Parts at real motorcycle positions"),
            ("disassembled", "Disassembled", "Parts spread apart — diagram view"),
        ],
        default="assembled",
    )
    export_groups: bpy.props.StringProperty(
        name="Groups",
        description="Groups to export: comma-separated codes (e.g. F01,F02,F05) or ALL",
        default="ALL",
    )


class BLT150_OT_LoadGroup(bpy.types.Operator):
    bl_idname = "blt150.load_group"
    bl_label  = "Load Group"
    bl_description = "Import all available OBJ files for the selected group"

    def execute(self, context):
        props = context.scene.blt150_props
        load_group(props.group_code, props.view_mode)
        return {"FINISHED"}


def _all_objects_in(col):
    """Recursively collect all objects in a collection and its children."""
    objs = list(col.objects)
    for child in col.children:
        objs.extend(_all_objects_in(child))
    return objs


class BLT150_OT_ExportOBJ(bpy.types.Operator):
    bl_idname = "blt150.export_obj"
    bl_label  = "Export Current Group"
    bl_description = "Export the current group as OBJ + MTL (+ PNG textures if any)"

    def execute(self, context):
        props = context.scene.blt150_props
        group_code = props.group_code
        group_col = bpy.data.collections.get(group_code)
        if not group_col:
            self.report({"ERROR"}, f"Group {group_code} not loaded yet.")
            return {"CANCELLED"}

        out_dir = os.path.normpath(EXPORT_DIR)
        os.makedirs(out_dir, exist_ok=True)
        out_path = os.path.join(out_dir, f"{group_code}_{props.view_mode}.obj")

        bpy.ops.object.select_all(action="DESELECT")
        for obj in _all_objects_in(group_col):
            obj.select_set(True)

        bpy.ops.wm.obj_export(
            filepath=out_path,
            export_selected_objects=True,
            export_materials=True,
            path_mode="COPY",
        )
        self.report({"INFO"}, f"Exported → {out_path}")
        return {"FINISHED"}


class BLT150_OT_ExportAllOBJ(bpy.types.Operator):
    bl_idname = "blt150.export_all_obj"
    bl_label  = "Export Groups"
    bl_description = "Export specified groups (ALL or comma-separated) as OBJ + MTL + PNG"

    def execute(self, context):
        out_dir = os.path.normpath(EXPORT_DIR)
        os.makedirs(out_dir, exist_ok=True)

        root = bpy.data.collections.get("BLT150")
        if not root:
            self.report({"ERROR"}, "No groups loaded yet.")
            return {"CANCELLED"}

        props = context.scene.blt150_props
        raw = props.export_groups.strip().upper()
        if raw in ("ALL", ""):
            target_groups = {col.name for col in root.children}
        else:
            target_groups = {g.strip() for g in raw.split(",") if g.strip()}

        exported = 0
        for group_col in root.children:
            if group_col.name not in target_groups:
                continue
            group_code = group_col.name
            objs = _all_objects_in(group_col)
            if not objs:
                continue
            out_path = os.path.join(out_dir, f"{group_code}_{props.view_mode}.obj")
            bpy.ops.object.select_all(action="DESELECT")
            for obj in objs:
                obj.select_set(True)
            bpy.ops.wm.obj_export(
                filepath=out_path,
                export_selected_objects=True,
                export_materials=True,
                path_mode="COPY",
            )
            exported += 1

        self.report({"INFO"}, f"Exported {exported} group(s) → {out_dir}")
        return {"FINISHED"}


class BLT150_OT_LoadAll(bpy.types.Operator):
    bl_idname = "blt150.load_all"
    bl_label  = "Load All Groups"
    bl_description = "Import all available OBJ files for every group"

    def execute(self, context):
        props = context.scene.blt150_props
        catalog = load_catalog()
        for g in catalog["groups"]:
            load_group(g["group"], props.view_mode)
        self.report({"INFO"}, f"Loaded {len(catalog['groups'])} groups ({props.view_mode})")
        return {"FINISHED"}


class BLT150_OT_PrintRotation(bpy.types.Operator):
    bl_idname = "blt150.print_rotation"
    bl_label  = "Print Transform"
    bl_description = "Print the selected object's location + rotation — paste into ASSEMBLED_POSITIONS and PART_ROTATIONS"

    def execute(self, context):
        obj = context.active_object
        if not obj:
            self.report({"WARNING"}, "No object selected.")
            return {"CANCELLED"}
        from math import degrees
        rx = degrees(obj.rotation_euler.x)
        ry = degrees(obj.rotation_euler.y)
        rz = degrees(obj.rotation_euler.z)
        lx, ly, lz = obj.location
        code = obj.get("item_code", obj.name)
        pos_line = f'        "{code}": ({lx:.3f}, {ly:.3f}, {lz:.3f}),'
        rot_line = f'    "{code}": ({rx:.1f}, {ry:.1f}, {rz:.1f}),'
        text_content = (
            f"[BLT150] Print Transform — {code}\n"
            f"\nASSEMBLED_POSITIONS entry:\n{pos_line}"
            f"\n\nPART_ROTATIONS entry:\n{rot_line}\n"
        )
        # Write to a Blender text block so it's readable on Mac (no system console)
        block_name = "blt150_explosion"
        block = bpy.data.texts.get(block_name) or bpy.data.texts.new(block_name)
        block.clear()
        block.write(text_content)
        print(text_content)
        self.report({"INFO"}, f"loc=({lx:.3f},{ly:.3f},{lz:.3f})  rot=({rx:.1f},{ry:.1f},{rz:.1f})  → see '{block_name}' text block")
        return {"FINISHED"}


class BLT150_OT_BakeTransforms(bpy.types.Operator):
    bl_idname = "blt150.bake_transforms"
    bl_label  = "Bake Transforms"
    bl_description = "Save all loaded object positions/rotations to blt150_overrides.json — restored on every future Load"

    def execute(self, context):
        from math import degrees
        root = bpy.data.collections.get("BLT150")
        if not root:
            self.report({"ERROR"}, "No groups loaded.")
            return {"CANCELLED"}

        positions = {}  # group -> {code -> [x, y, z]}
        rotations = {}  # code -> [rx, ry, rz]

        def collect(col, group_code):
            for obj in col.objects:
                code = obj.get("item_code")
                if not code:
                    continue
                grp = obj.get("group") or group_code
                lx, ly, lz = obj.location
                rx = degrees(obj.rotation_euler.x)
                ry = degrees(obj.rotation_euler.y)
                rz = degrees(obj.rotation_euler.z)
                positions.setdefault(grp, {})[code] = [round(lx, 4), round(ly, 4), round(lz, 4)]
                if abs(rx) > 0.01 or abs(ry) > 0.01 or abs(rz) > 0.01:
                    rotations[code] = [round(rx, 2), round(ry, 2), round(rz, 2)]
            for child in col.children:
                collect(child, group_code)

        for group_col in root.children:
            collect(group_col, group_col.name)

        data = {"positions": positions, "rotations": rotations}
        with open(OVERRIDES_PATH, "w", encoding="utf-8") as f:
            json.dump(data, f, indent=2)

        total = sum(len(v) for v in positions.values())
        print(f"[BLT150] Baked {total} part transforms → {OVERRIDES_PATH}")
        self.report({"INFO"}, f"Baked {total} transforms → blt150_overrides.json")
        return {"FINISHED"}


class BLT150_OT_ClearOverrides(bpy.types.Operator):
    bl_idname = "blt150.clear_overrides"
    bl_label  = "Clear Overrides"
    bl_description = "Delete blt150_overrides.json so Load All reverts to script defaults"

    def execute(self, context):
        if os.path.exists(OVERRIDES_PATH):
            os.remove(OVERRIDES_PATH)
            self.report({"INFO"}, "Overrides cleared — defaults restored.")
        else:
            self.report({"INFO"}, "No overrides file found.")
        return {"FINISHED"}


class BLT150_OT_ClearScene(bpy.types.Operator):
    bl_idname = "blt150.clear_scene"
    bl_label  = "Clear Scene"
    bl_description = "Remove all BLT150 objects and purge orphaned mesh data"

    def execute(self, context):
        # Remove all objects inside the BLT150 collection tree
        root = bpy.data.collections.get("BLT150")
        if root:
            def remove_objects_in(col):
                for obj in list(col.objects):
                    bpy.data.objects.remove(obj, do_unlink=True)
                for child in list(col.children):
                    remove_objects_in(child)
                    bpy.data.collections.remove(child)
            remove_objects_in(root)
            bpy.data.collections.remove(root)

        # Explicitly remove ALL mesh data blocks — orphans_purge alone can miss
        # blocks that have lingering fake-users from a previous Blender session,
        # causing wm.obj_import to silently reuse stale mm-scale data.
        for mesh_data in list(bpy.data.meshes):
            try:
                bpy.data.meshes.remove(mesh_data, do_unlink=True)
            except Exception:
                pass
        for mat in list(bpy.data.materials):
            try:
                bpy.data.materials.remove(mat, do_unlink=True)
            except Exception:
                pass
        bpy.ops.outliner.orphans_purge(do_recursive=True)
        self.report({"INFO"}, "Scene cleared — all mesh/material data purged.")
        return {"FINISHED"}


class BLT150_OT_RotateAllObjects(bpy.types.Operator):
    bl_idname     = "blt150.rotate_all_objects"
    bl_label      = "Rotate All Objects +90° Z"
    bl_description = (
        "Rotate every mesh object +90° around Z so the bike front faces +X "
        "(was +Y). Bakes the transform into vertex positions — do this once "
        "before exporting so exported OBJs have the correct orientation."
    )

    def execute(self, context):
        from math import radians

        # Select all mesh objects and rotate as one unit around world origin —
        # same as pressing A → R → Z → -90 → Enter in the viewport.
        bpy.ops.object.select_all(action='SELECT')
        context.scene.tool_settings.transform_pivot_point = 'MEDIAN_POINT'
        bpy.ops.transform.rotate(
            value=radians(90.0),
            orient_axis='Z',
            orient_type='GLOBAL',
        )
        bpy.ops.object.transform_apply(location=False, rotation=True, scale=False)
        bpy.ops.object.select_all(action='DESELECT')

        self.report({'INFO'}, "Rotated all objects +90° Z as a group — transform applied")
        return {'FINISHED'}


class BLT150_OT_SetReferenceView(bpy.types.Operator):
    bl_idname     = "blt150.set_reference_view"
    bl_label      = "Set Reference View"
    bl_description = (
        "Set viewport to match the product-image angle: front of bike (+X) "
        "faces the viewer, right side (-Y) faces screen-right, ~15° elevation. "
        "Adjust AZIMUTH_DEG / ELEVATION_DEG at the top of this operator to tune."
    )

    # ── Tune these two values to match the reference image exactly ──────────
    AZIMUTH_DEG   = 45.0   # horizontal orbit: 0 = looking straight at front (+X)
                           #   positive = orbit toward -Y (right side visible more)
    ELEVATION_DEG = 15.0   # degrees above horizontal (0 = dead-level, 90 = top-down)
    # ────────────────────────────────────────────────────────────────────────

    def execute(self, context):
        from math import radians
        from mathutils import Euler

        # Build viewport rotation: X controls elevation, Z controls azimuth.
        # X=90° = horizontal view; subtract elevation to tilt upward.
        # Z negative = orbit clockwise (toward -Y / right side of bike).
        e = Euler((
            radians(90.0 - self.ELEVATION_DEG),
            0.0,
            radians(-self.AZIMUTH_DEG),
        ), 'XYZ')
        q = e.to_quaternion()

        applied = False
        for window in bpy.context.window_manager.windows:
            for area in window.screen.areas:
                if area.type != 'VIEW_3D':
                    continue
                region = next((r for r in area.regions if r.type == 'WINDOW'), None)
                if region is None:
                    continue
                with bpy.context.temp_override(window=window, area=area, region=region):
                    rv3d = area.spaces.active.region_3d
                    rv3d.view_rotation = q
                    # Fit all objects in view after rotating
                    bpy.ops.view3d.view_all(center=False)
                applied = True
                break
            if applied:
                break

        if not applied:
            self.report({'WARNING'}, 'No 3D Viewport found')
        return {'FINISHED'}


class BLT150_OT_FitView(bpy.types.Operator):
    bl_idname = "blt150.fit_view"
    bl_label  = "Fit View"
    bl_description = "Frame all objects in the viewport and fix clip distances"

    def execute(self, context):
        fix_viewport_clipping()
        for window in bpy.context.window_manager.windows:
            for area in window.screen.areas:
                if area.type == "VIEW_3D":
                    region = next((r for r in area.regions if r.type == "WINDOW"), None)
                    if region:
                        with bpy.context.temp_override(window=window, area=area, region=region):
                            bpy.ops.view3d.view_all(center=False)
        return {"FINISHED"}


class BLT150_OT_ToggleSA(bpy.types.Operator):
    bl_idname = "blt150.toggle_sa"
    bl_label  = "Toggle Sub-Assembly"
    bl_description = "Expand/collapse a sub-assembly"

    sa_code: bpy.props.StringProperty()

    def execute(self, context):
        props = context.scene.blt150_props
        toggle_sub_assembly(props.group_code, self.sa_code)
        return {"FINISHED"}


class BLT150_PT_Panel(bpy.types.Panel):
    bl_label      = "BLT150 Parts"
    bl_idname     = "VIEW3D_PT_blt150"
    bl_space_type = "VIEW_3D"
    bl_region_type = "UI"
    bl_category   = "BLT150"

    def draw(self, context):
        layout = self.layout
        props  = context.scene.blt150_props

        # ── Group selector ──────────────────────────────────────────────────
        box = layout.box()
        box.label(text="Group", icon="OUTLINER_COLLECTION")
        box.prop(props, "group_code")
        box.prop(props, "view_mode", expand=True)
        box.operator("blt150.load_group",   icon="IMPORT")
        box.operator("blt150.load_all",     icon="WORLD")
        box.operator("blt150.fit_view",            icon="ZOOM_ALL")
        box.operator("blt150.set_reference_view",   icon="CAMERA_DATA")
        box.operator("blt150.rotate_all_objects",   icon="ORIENTATION_GIMBAL")
        box.operator("blt150.clear_scene",          icon="TRASH")
        box = layout.box()
        box.label(text="Transforms", icon="DRIVER_ROTATIONAL_DIFFERENCE")
        overrides_exist = os.path.exists(OVERRIDES_PATH)
        row = box.row()
        row.operator("blt150.print_rotation",  icon="DRIVER_ROTATIONAL_DIFFERENCE")
        row = box.row()
        row.operator("blt150.bake_transforms", icon="PINNED")
        sub = row.row()
        sub.enabled = overrides_exist
        sub.operator("blt150.clear_overrides", icon="TRASH", text="")
        if overrides_exist:
            box.label(text="Overrides active", icon="INFO")

        # ── Export ──────────────────────────────────────────────────────────
        box = layout.box()
        box.label(text="Export OBJ / MTL / PNG", icon="EXPORT")
        box.prop(props, "export_groups")
        box.operator("blt150.export_obj",     icon="MESH_DATA")
        box.operator("blt150.export_all_obj", icon="PACKAGE")

        # ── Sub-assembly toggles ─────────────────────────────────────────────
        try:
            catalog = load_catalog()
            group_data = next(
                (g for g in catalog["groups"] if g["group"] == props.group_code),
                None
            )
        except Exception:
            group_data = None

        if group_data and group_data.get("sub_assemblies"):
            box = layout.box()
            box.label(text="Sub-Assemblies", icon="LINKED")
            for sa in group_data["sub_assemblies"]:
                sa_code   = sa["code"]
                col_name  = f"{props.group_code}_{sa_code}"
                col       = bpy.data.collections.get(col_name)
                expanded  = col is not None and not col.hide_viewport
                icon      = "TRIA_DOWN" if expanded else "TRIA_RIGHT"
                op = box.operator("blt150.toggle_sa", text=sa_code, icon=icon)
                op.sa_code = sa_code


# ──────────────────────────── register / unregister ──────────────────────────

CLASSES = [
    BLT150_Props,
    BLT150_OT_LoadGroup,
    BLT150_OT_LoadAll,
    BLT150_OT_ExportOBJ,
    BLT150_OT_ExportAllOBJ,
    BLT150_OT_PrintRotation,
    BLT150_OT_BakeTransforms,
    BLT150_OT_ClearOverrides,
    BLT150_OT_ClearScene,
    BLT150_OT_FitView,
    BLT150_OT_SetReferenceView,
    BLT150_OT_RotateAllObjects,
    BLT150_OT_ToggleSA,
    BLT150_PT_Panel,
]


def register():
    for cls in CLASSES:
        bpy.utils.register_class(cls)
    bpy.types.Scene.blt150_props = bpy.props.PointerProperty(type=BLT150_Props)


def unregister():
    for cls in reversed(CLASSES):
        bpy.utils.unregister_class(cls)
    del bpy.types.Scene.blt150_props


if __name__ == "__main__":
    # When run directly from the Scripting workspace
    try:
        unregister()
    except Exception:
        pass
    register()
    print("[BLT150] Script registered. Open the N-panel → BLT150 tab.")
