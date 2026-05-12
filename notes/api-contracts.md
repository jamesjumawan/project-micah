# API Contracts — Project Micah

These are the expected request/response shapes the Flutter app will consume once the real backend is live. The app currently reads from local JSON assets (`assets/data/`). Swap the `_fetchLocal()` calls in `lib/services/motorcycle_service.dart` with Retrofit client calls when the endpoints are ready.

---

## Base URL

```
https://<your-api-domain>/api
```

---

## 1. GET `/motorcycles`

Returns the full motorcycle catalogue list shown in the left sidebar.

### Response

```json
{
  "motorcycles": [
    {
      "name": "BLT150",
      "imageUrl": "https://<cdn>/images/blt150.png",
      "has3DModel": true,
      "engineSpecs": ["Exhaust Pipe"],
      "accessoriesSpecs": [
        "Right Side Mirror",
        "Left Side Mirror",
        "Handle Bar",
        "Front Frame",
        "Back Frame",
        "Front Wheel",
        "Rear Fender",
        "Rear Wheel",
        "Rear Shock Absorber"
      ],
      "parts": {
        "Right Side Mirror": {
          "label": "RIGHT SIDE MIRROR",
          "displayName": "Right Side Mirror",
          "imageUrl": "https://<cdn>/images/parts/SPD-MIRA-R.jpg",
          "name": "SIDE MIRROR ASSEMBLY",
          "sku": "RSM2341982155",
          "category": "ACCESSORY",
          "groupNo": "A-02",
          "partNo": "1102R",
          "quantity": 1,
          "part_type": "ACCESSORY",
          "depth_level": 2,
          "item_code": "SPD-MIRA-R",
          "internal_code": null,
          "sub_assembly": "SA-A-01",
          "description": "High-visibility convex mirror...",
          "obj": "https://<cdn>/models/parts/SPD-MIRA-R.obj",
          "mtl": "https://<cdn>/models/parts/SPD-MIRA-R.mtl"
        }
        // ... more parts keyed by displayName
      }
    },
    {
      "name": "Blink 124",
      "imageUrl": "https://<cdn>/images/blink124.png",
      "has3DModel": true,
      "engineSpecs": [ "Cylinder Block & Cylinder Head", "..." ],
      "accessoriesSpecs": [ "Headlight", "..." ],
      "parts": {}
    }
    // ... more motorcycles
  ]
}
```

### Field notes

| Field | Type | Notes |
|---|---|---|
| `name` | `string` | Must be unique — used as the key throughout the app |
| `has3DModel` | `bool` | Toggles 3D viewer rendering |
| `parts` | `object` | Keyed by **displayName** (e.g. `"Right Side Mirror"`) |
| `item_code` | `string?` | SPD- code — must match OBJ mesh name prefix |
| `sub_assembly` | `string?` | SA- code if the part belongs to a sub-assembly |
| `obj` / `mtl` | `string` | Full URL to the individual part 3D file |

---

## 2. GET `/motorcycles/:model/parts-catalog`

Returns the full exploded parts catalog for a given model (currently only BLT150).  
Local asset: `assets/data/blt150_parts_catalog.json`

### Request

```
GET /motorcycles/BLT150/parts-catalog
```

### Response

```json
{
  "brand": "skygo",
  "model": "BLT150",
  "generated_at": "2026-04-20T15:00:08",
  "groups": [
    {
      "group": "F01",
      "group_header": "LF150T-8G F-01 仪表总成 METER ASSY",
      "part_type": "meter_assy",
      "sub_assemblies": [],
      "items": [
        {
          "id": "F01-01",
          "description": "Meter Stay",
          "part_type": "meter_stay",
          "quantity": null,
          "depth_level": 3,
          "sub_assembly": null,
          "item_code": null,
          "internal_code": "CKI-01004X-B"
        },
        {
          "id": "F01-02",
          "description": "Case, Meter",
          "part_type": "case",
          "quantity": null,
          "depth_level": 1,
          "sub_assembly": null,
          "item_code": "SPD-06114X-B",
          "internal_code": null
        }
        // ... more items
      ]
    },
    {
      "group": "F02",
      "group_header": "LF150T-8G F-02 车体护罩总成I FRAME MANTLE I",
      "part_type": "frame_mantle_i",
      "sub_assemblies": [
        { "code": "SA-F02-01", "name": "SA-F02-01" },
        { "code": "SA-F02-02", "name": "SA-F02-02" }
      ],
      "items": [
        {
          "id": "F02-04",
          "description": "Headlight Assy - LED Type",
          "part_type": "headlight_assy_led_type",
          "quantity": null,
          "depth_level": 4,
          "sub_assembly": "SA-F02-01",
          "item_code": "SPD-33100X-B",
          "internal_code": null
        }
        // ...
      ]
    }
    // groups F01–F19 (no F16)
  ]
}
```

### Item field notes

| Field | Type | Notes |
|---|---|---|
| `id` | `string?` | Format: `F{group}-{seq}` (e.g. `F01-02`). Null for hardware/screws |
| `item_code` | `string?` | SPD- code. Null when only `internal_code` exists |
| `internal_code` | `string?` | CKI- code. Null when `item_code` exists |
| `sub_assembly` | `string?` | SA- code the item belongs to (e.g. `SA-F02-01`) |
| `depth_level` | `int` | Hierarchy depth (1 = top-level, higher = deeper) |

---

## 3. GET `/motorcycles/:model/assembly-model`

Returns S3 URLs for the single assembled 3D model (the full motorcycle).

### Response

```json
{
  "model": "BLT150",
  "obj": "https://micah-assets.s3.us-east-1.amazonaws.com/assets/sample_3d_object/blt150_01.obj",
  "mtl": "https://micah-assets.s3.us-east-1.amazonaws.com/assets/sample_3d_object/blt150_01.mtl"
}
```

---

## 4. GET `/motorcycles/:model/explosion-models`

Returns the list of Blender-exported group-level explosion OBJs (the disassembled view).  
Currently auto-discovered from `assets/models/` via `AssetManifest`.

### Response

```json
{
  "model": "BLT150",
  "groups": [
    {
      "group": "F01",
      "obj": "https://<cdn>/models/BLT150/F01_assembled.obj",
      "mtl": "https://<cdn>/models/BLT150/F01_assembled.mtl"
    },
    {
      "group": "F02",
      "obj": "https://<cdn>/models/BLT150/F02_assembled.obj",
      "mtl": "https://<cdn>/models/BLT150/F02_assembled.mtl"
    },
    {
      "group": "F05",
      "obj": "https://<cdn>/models/BLT150/F05_assembled.obj",
      "mtl": "https://<cdn>/models/BLT150/F05_assembled.mtl"
    }
    // one entry per exported group
  ]
}
```

> **OBJ mesh naming convention (critical):**  
> - Regular parts: `SPD-06114X-B_—_Case,_Meter` (item_code + `_—_` + human name)  
> - Sub-assembly groups: `[SA]_SA-F05-01` (`[SA]_` prefix + SA code)  
> The Flutter 3D viewer parses the mesh name to determine what was clicked.

---

## 5. GET `/motorcycles/:model/sub-assembly/:saCode`

Returns the isolated 3D model for a single sub-assembly.

### Request

```
GET /motorcycles/BLT150/sub-assembly/SA-F05-01
```

### Response

```json
{
  "saCode": "SA-F05-01",
  "obj": "https://<cdn>/models/BLT150/sub-assemblies/SA-F05-01.obj",
  "mtl": "https://<cdn>/models/BLT150/sub-assemblies/SA-F05-01.mtl",
  "items": [
    {
      "item_code": "SPD-26674X-B",
      "description": "Grip, R",
      "quantity": 1
    }
    // ... parts belonging to this SA
  ]
}
```
