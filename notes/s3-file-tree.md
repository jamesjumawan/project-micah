# S3 File Tree — Project Micah

**Bucket:** `micah-assets`  
**Region:** `us-east-1`  
**Base URL:** `https://micah-assets.s3.us-east-1.amazonaws.com/assets`

---

## Current Structure (what exists today)

> **File naming rule:** Part files are named exactly by `item_code` (SPD-xxx) or `internal_code` (CKI-xxx) only. No human-readable suffix in the filename.

```
micah-assets/
└── assets/
    ├── sample_3d_object/
    │   ├── blt150_01.obj                ← BLT150 main assembled (rename → main_assembled.obj)
    │   ├── blt150_01.mtl
    │   ├── blink124.obj
    │   ├── blink124.mtl
    │   ├── wizard125.obj
    │   ├── wizard125.mtl
    │   ├── king150.obj
    │   ├── king150.mtl
    │   └── manual_breaking_01/          ← Legacy placeholder parts (to be replaced)
    │       ├── blt150_02.obj
    │       ├── blt150_02.mtl
    │       ├── blt150_03.obj
    │       ├── blt150_03.mtl
    │       └── ... (blt150_04 → blt150_11)
    └── parts/                           ← (planned, not yet in S3)
```

> The `manual_breaking_01/` files are placeholder parts referenced by `motorcycles_data.json`. They will be replaced by real SPD- named files.

---

## Target Structure (what it should look like)

```
micah-assets/
└── assets/
    │
    ├── sample_3d_object/
    │   ├── blink124.obj
    │   ├── blink124.mtl
    │   ├── wizard125.obj
    │   ├── wizard125.mtl
    │   └── king150.obj
    │   └── king150.mtl
    │
    ├── models/
    │   └── BLT150/
    │       ├── main_assembled.obj           ← Full motorcycle, loaded first in disassembly mode
    │       ├── main_assembled.mtl
    │       ├── explosion/               ← Group-level Blender exports (disassembly view)
    │       │   ├── F01_assembled.obj
    │       │   ├── F01_assembled.mtl
    │       │   ├── F02_assembled.obj
    │       │   ├── F02_assembled.mtl
    │       │   ├── F03_assembled.obj    ← not yet exported
    │       │   ├── F03_assembled.mtl
    │       │   ├── F04_assembled.obj    ← not yet exported
    │       │   ├── F04_assembled.mtl
    │       │   ├── F05_assembled.obj
    │       │   ├── F05_assembled.mtl
    │       │   ├── F06_assembled.obj    ← not yet exported
    │       │   ├── F06_assembled.mtl
    │       │   ├── F07_assembled.obj    ← not yet exported
    │       │   ├── F07_assembled.mtl
    │       │   ├── F08_assembled.obj    ← not yet exported
    │       │   ├── F08_assembled.mtl
    │       │   ├── F09_assembled.obj    ← not yet exported
    │       │   ├── F09_assembled.mtl
    │       │   ├── F10_assembled.obj    ← not yet exported
    │       │   ├── F10_assembled.mtl
    │       │   ├── F11_assembled.obj    ← not yet exported
    │       │   ├── F11_assembled.mtl
    │       │   ├── F12_assembled.obj    ← not yet exported
    │       │   ├── F12_assembled.mtl
    │       │   ├── F13_assembled.obj    ← not yet exported
    │       │   ├── F13_assembled.mtl
    │       │   ├── F14_assembled.obj    ← not yet exported
    │       │   ├── F14_assembled.mtl
    │       │   ├── F15_assembled.obj    ← not yet exported
    │       │   ├── F15_assembled.mtl
    │       │   ├── F17_assembled.obj    ← not yet exported
    │       │   ├── F17_assembled.mtl
    │       │   ├── F18_assembled.obj    ← not yet exported
    │       │   ├── F18_assembled.mtl
    │       │   ├── F19_assembled.obj    ← not yet exported
    │       │   └── F19_assembled.mtl
    │       │
    │       ├── sub-assemblies/          ← Isolated sub-assembly OBJs
    │       │   ├── SA-F02-01.obj        ← not yet exported
    │       │   ├── SA-F02-01.mtl
    │       │   ├── SA-F02-02.obj        ← not yet exported
    │       │   ├── SA-F02-02.mtl
    │       │   ├── SA-F03-01.obj        ← not yet exported
    │       │   ├── SA-F03-01.mtl
    │       │   ├── SA-F03-02.obj        ← not yet exported
    │       │   ├── SA-F03-02.mtl
    │       │   ├── SA-F04-01.obj        ← not yet exported
    │       │   ├── SA-F04-01.mtl
    │       │   ├── SA-F04-02.obj        ← not yet exported
    │       │   ├── SA-F04-02.mtl
    │       │   ├── SA-F05-01.obj        ✅ exists (in assets/Objects/ locally)
    │       │   ├── SA-F05-01.mtl        ✅ exists
    │       │   ├── SA-F05-02.obj        ← not yet exported
    │       │   ├── SA-F05-02.mtl
    │       │   ├── SA-F06-01.obj        ← not yet exported
    │       │   ├── SA-F06-01.mtl
    │       │   ├── SA-F07-01.obj        ← not yet exported
    │       │   ├── SA-F07-01.mtl
    │       │   ├── SA-F08-01.obj        ← not yet exported
    │       │   ├── SA-F08-01.mtl
    │       │   ├── SA-F09-01.obj        ← not yet exported
    │       │   ├── SA-F09-01.mtl
    │       │   ├── SA-F10-01.obj        ← not yet exported
    │       │   ├── SA-F10-01.mtl
    │       │   ├── SA-F11-01.obj        ← not yet exported
    │       │   ├── SA-F11-01.mtl
    │       │   ├── SA-F12-01.obj        ← not yet exported
    │       │   ├── SA-F12-01.mtl
    │       │   ├── SA-F13-01.obj        ← not yet exported
    │       │   ├── SA-F13-01.mtl
    │       │   ├── SA-F14-01.obj        ← not yet exported
    │       │   ├── SA-F14-01.mtl
    │       │   ├── SA-F17-01.obj        ← not yet exported
    │       │   ├── SA-F17-01.mtl
    │       │   ├── SA-F17-02.obj        ← not yet exported
    │       │   ├── SA-F17-02.mtl
    │       │   ├── SA-F19-01.obj        ← not yet exported
    │       │   └── SA-F19-01.mtl
    │       │
    │       └── parts/                   ← Individual isolated part OBJs
    │           ├── SPD-02465X-B.obj
    │           ├── SPD-02465X-B.mtl
    │           ├── SPD-02465X-B.jpg
    │           ├── SPD-03468X-B.obj
    │           ├── SPD-03468X-B.mtl
    │           ├── SPD-03468X-B.jpg
    │           ├── SPD-06114X-B.obj     ✅ exists locally (assets/Objects/)
    │           ├── SPD-06114X-B.mtl     ✅ exists locally
    │           ├── SPD-06114X-B.jpg     ✅ exists locally
    │           ├── SPD-06545X-B.obj     ✅ exists locally
    │           ├── SPD-06545X-B.mtl     ✅ exists locally
    │           ├── SPD-06545X-B.jpg     ✅ exists locally
    │           ├── SPD-06546X-B.obj     ✅ exists locally
    │           ├── SPD-06546X-B.mtl     ✅ exists locally
    │           ├── SPD-06546X-B.jpg     ✅ exists locally
    │           ├── SPD-10259X-B.obj     ✅ exists locally
    │           ├── SPD-10259X-B.mtl     ✅ exists locally
    │           ├── SPD-10259X-B.jpg     ✅ exists locally
    │           ├── SPD-10260X-B.obj     ✅ exists locally
    │           ├── SPD-10260X-B.mtl     ✅ exists locally
    │           ├── SPD-10260X-B.jpg     ✅ exists locally
    │           ├── SPD-10263X-B.obj     ✅ exists locally
    │           ├── SPD-10263X-B.mtl     ✅ exists locally
    │           ├── SPD-10263X-B.jpg     ✅ exists locally
    │           ├── SPD-26674X-B.obj     ✅ exists locally
    │           ├── SPD-26674X-B.mtl     ✅ exists locally
    │           ├── SPD-26674X-B.jpg     ✅ exists locally
    │           ├── SPD-33100X-B.obj     ✅ exists locally
    │           ├── SPD-33100X-B.mtl     ✅ exists locally
    │           ├── SPD-33100X-B.jpg     ✅ exists locally
    │           ├── SPD-33550X-B.obj     ✅ exists locally
    │           ├── SPD-33550X-B.mtl     ✅ exists locally
    │           ├── SPD-33550X-B.jpg     ✅ exists locally
    │           ├── SPD-35100X-B.obj     ✅ exists locally
    │           ├── SPD-35100X-B.mtl     ✅ exists locally
    │           ├── SPD-35100X-B.jpg     ✅ exists locally
    │           ├── SPD-35200X-B.obj     ✅ exists locally
    │           ├── SPD-35200X-B.mtl     ✅ exists locally
    │           ├── SPD-35200X-B.jpg     ✅ exists locally
    │           ├── SPD-38566X-B.obj     ✅ exists locally
    │           ├── SPD-38566X-B.mtl     ✅ exists locally
    │           ├── SPD-38566X-B.jpg     ✅ exists locally
    │           ├── SPD-43211X-B.obj     ✅ exists locally
    │           ├── SPD-43211X-B.mtl     ✅ exists locally
    │           ├── SPD-43211X-B.jpg     ✅ exists locally
    │           ├── SPD-43261X-B.obj     ✅ exists locally
    │           ├── SPD-43261X-B.mtl     ✅ exists locally
    │           ├── SPD-43261X-B.jpg     ✅ exists locally
    │           ├── SPD-43264X-B.obj     ✅ exists locally
    │           ├── SPD-43264X-B.mtl     ✅ exists locally
    │           ├── SPD-43264X-B.jpg     ✅ exists locally
    │           ├── SPD-43265X-B.obj     ✅ exists locally
    │           ├── SPD-43265X-B.mtl     ✅ exists locally
    │           ├── SPD-43265X-B.jpg     ✅ exists locally
    │           ├── SPD-43333X-B.obj     ✅ exists locally
    │           ├── SPD-43333X-B.mtl     ✅ exists locally
    │           ├── SPD-43333X-B.jpg     ✅ exists locally
    │           ├── SPD-43433X-B.obj     ✅ exists locally
    │           ├── SPD-43433X-B.mtl     ✅ exists locally
    │           ├── SPD-43433X-B.jpg     ✅ exists locally
    │           ├── SPD-45467X-B.obj     ✅ exists locally
    │           ├── SPD-45467X-B.mtl     ✅ exists locally
    │           ├── SPD-45467X-B.jpg     ✅ exists locally
    │           ├── SPD-46513X-B.obj     ✅ exists locally
    │           ├── SPD-46513X-B.mtl     ✅ exists locally
    │           ├── SPD-46513X-B.jpg     ✅ exists locally
    │           ├── SPD-47110X-B.obj     ✅ exists locally
    │           ├── SPD-47110X-B.mtl     ✅ exists locally
    │           ├── SPD-47110X-B.jpg     ✅ exists locally
    │           ├── SPD-89001X-B.obj     ✅ exists locally
    │           ├── SPD-89001X-B.mtl     ✅ exists locally
    │           ├── SPD-89001X-B.jpg     ✅ exists locally
    │           ├── SPD-89101X-B.obj     ✅ exists locally
    │           ├── SPD-89101X-B.mtl     ✅ exists locally
    │           ├── SPD-89101X-B.jpg     ✅ exists locally
    │           ├── SPD-90105X-B.obj     ✅ exists locally
    │           ├── SPD-90105X-B.mtl     ✅ exists locally
    │           ├── SPD-90105X-B.jpg     ✅ exists locally
    │           ├── SPD-90405X-B.obj     ✅ exists locally
    │           ├── SPD-90405X-B.mtl     ✅ exists locally
    │           ├── SPD-90405X-B.jpg     ✅ exists locally
    │           ├── SPD-90507X-B.obj     ✅ exists locally
    │           ├── SPD-90507X-B.mtl     ✅ exists locally
    │           ├── SPD-90507X-B.jpg     ✅ exists locally
    │           ├── SPD-90607X-B.obj     ✅ exists locally
    │           ├── SPD-90607X-B.mtl     ✅ exists locally
    │           ├── SPD-90607X-B.jpg     ✅ exists locally
    │           └── ... (remaining 136 SPD- codes from catalog)
    │
    └── images/
        └── motorcycles/
            ├── blt150.png
            ├── blink124.png
            ├── wizard125.png
            └── king150.png
```

---

## Local Assets (currently bundled in the Flutter app)

These live in `assets/` inside the repo and are served directly. When the backend is ready, move them to S3 and update the URL references in the viewmodel.

```
assets/
├── models/                     ← Group explosion OBJs (Flutter loads via AssetManifest)
│   ├── F01_assembled.obj/.mtl
│   ├── F02_assembled.obj/.mtl
│   └── F05_assembled.obj/.mtl
│
├── Objects/                    ← Individual part OBJs + sub-assembly OBJs
│   ├── SA-F05-01.obj/.mtl/.jpg
│   ├── SPD-06114X-B.obj/.mtl/.jpg
│   ├── SPD-06545X-B.obj/.mtl/.jpg
│   └── ... (27 SPD- parts currently)
│
└── data/
    ├── motorcycles_data.json   ← Motorcycle list + placeholder part metadata
    └── blt150_parts_catalog.json ← Real BLT150 parts catalog (219 items, 18 groups)
```

---

## Migration Checklist

When moving to S3 + BE:

- [ ] Upload all `assets/Objects/SPD-*.obj/.mtl/.jpg` to `models/BLT150/parts/`
- [ ] Upload `assets/Objects/SA-F05-01.obj/.mtl` to `models/BLT150/sub-assemblies/`
- [ ] Upload `assets/models/F01/F02/F05_assembled.*` to `models/BLT150/explosion/`
- [ ] Update `motorcycles_data.json` parts `obj`/`mtl` fields to point to new S3 URLs
- [ ] Replace `_fetchLocal()` in `motorcycle_service.dart` with Retrofit call to `GET /motorcycles`
- [ ] Replace local catalog load in `details_viewmodel.dart` with `GET /motorcycles/BLT150/parts-catalog`
- [ ] Replace `getLocalExplosionModels()` with `GET /motorcycles/BLT150/explosion-models`
