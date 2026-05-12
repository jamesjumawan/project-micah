"""
BLT150 Diagnostic — run this AFTER loading groups in blt150_explosion.py.
"""
import bpy

def all_objects_in(col):
    objs = list(col.objects)
    for child in col.children:
        objs.extend(all_objects_in(child))
    return objs

# Force depsgraph update so matrix_world reflects programmatic location changes
bpy.context.view_layer.update()

root = bpy.data.collections.get("BLT150")
if not root:
    print("⚠  No BLT150 collection found — load groups first.")
else:
    print("\n" + "="*100)
    print(f"{'GROUP':<6} {'ITEM_CODE':<20} {'BB_CENTER':<36} {'DIMS (x,y,z)':<30} {'ROT (rx,ry,rz deg)'}")
    print("="*100)
    from math import degrees
    for group_col in root.children:
        for obj in all_objects_in(group_col):
            if obj.type != "MESH" or not obj.data.vertices:
                continue
            code  = obj.get("item_code", obj.name)
            group = obj.get("group", group_col.name)

            # Use obj.location + local vertex (no rotation applied yet) for BB
            verts = [obj.matrix_world @ v.co for v in obj.data.vertices]
            xs = [v.x for v in verts]; ys = [v.y for v in verts]; zs = [v.z for v in verts]
            cx = (min(xs)+max(xs))/2; cy = (min(ys)+max(ys))/2; cz = (min(zs)+max(zs))/2
            dx = max(xs)-min(xs);     dy = max(ys)-min(ys);     dz = max(zs)-min(zs)
            rx = degrees(obj.rotation_euler.x)
            ry = degrees(obj.rotation_euler.y)
            rz = degrees(obj.rotation_euler.z)
            print(
                f"{group:<6} {code:<20} "
                f"({cx:+.3f}, {cy:+.3f}, {cz:+.3f})   "
                f"({dx:.3f}, {dy:.3f}, {dz:.3f})   "
                f"({rx:.0f}, {ry:.0f}, {rz:.0f})"
            )
    print("="*100 + "\n")
