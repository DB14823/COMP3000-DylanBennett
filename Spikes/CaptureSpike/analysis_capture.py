import json
from pathlib import Path
import numpy as np
import matplotlib.pyplot as plt
from matplotlib.path import Path as PolygonPath

capture_folder = Path(
    "/Users/dylan/Uni/COMP3000/Data/Captures/Box_tests/Box_test_03"
)
#print(capture_folder.exists())

metadata_path = capture_folder / "meta.json"
metadata = json.loads(metadata_path.read_text())

#print(metadata["depthWidth"], metadata["depthHeight"])

depth_path = capture_folder / "depth.f32"
depth = np.fromfile(depth_path, dtype="<f4")

#print(depth.size)

depth = depth.reshape(metadata["depthHeight"], metadata["depthWidth"])
#print(depth.shape)

confidence_path = capture_folder / "confidence.u8"
confidence = np.fromfile(confidence_path, dtype=np.uint8)

#print(confidence.size)

confidence = confidence.reshape(metadata["confidenceHeight"], metadata["confidenceWidth"])
#print(confidence.shape)

values, counts = np.unique(confidence, return_counts=True)

#print(values)
#print(counts)

valid = (confidence == 2) & np.isfinite(depth) & (depth > 0)
#print(valid.sum())
#print(np.median(depth[valid]))
#print(depth[valid].min())
#print(depth[valid].max())



intrinsics = np.array(metadata["cameraIntrinsics"])
intrinsics = intrinsics.reshape(3, 3)

#print(intrinsics)
scale_x = metadata["depthWidth"] / metadata["imageWidth"]
scale_y = metadata["depthHeight"] / metadata["imageHeight"]

#print(scale_x, scale_y)

fx = intrinsics[0, 0] * scale_x
fy = intrinsics[1, 1] * scale_y
cx = intrinsics[0, 2] * scale_x
cy = intrinsics[1, 2] * scale_y

#print(fx, fy, cx, cy)

sample_x = 100
sample_y = 30
#centre_x = metadata["depthWidth"] // 2
#centre_y = metadata["depthHeight"] // 2
centre_depth = depth[sample_y, sample_x]

#print(centre_depth)
#print(confidence[centre_x, centre_y])

camera_x = (sample_x - cx) * centre_depth / fx
camera_y = -(sample_y - cy) * centre_depth / fy
camera_z = -centre_depth

#print(camera_x, camera_y, camera_z)

camera_transform = np.array(metadata["cameraTransform"])
camera_transform = camera_transform.reshape(4, 4)
#print(camera_transform)

camera_point = np.array([camera_x, camera_y, camera_z, 1.0])
world_point = camera_transform @ camera_point
#print(world_point)

plane_transform = np.array(metadata["planeTransform"])
plane_transform = plane_transform.reshape(4, 4)

table_point = np.linalg.inv(plane_transform) @ world_point
#print(table_point * 1000)



#print(depth[sample_y, sample_x])
#print(confidence[sample_y, sample_x])

pixel_x, pixel_y = np.meshgrid(
    np.arange(metadata["depthWidth"]),
    np.arange(metadata["depthHeight"])
)

#print(pixel_y.shape)
#print(pixel_x.shape)

camera_x_grid = np.array((pixel_x - cx) * depth / fx)
camera_y_grid = np.array(-(pixel_y - cy) * depth / fy)
camera_z_grid = np.array(-depth)

#print(camera_x_grid.shape)
#print(camera_y_grid.shape)
#print(camera_z_grid.shape)

camera_points = np.stack((camera_x_grid, camera_y_grid, camera_z_grid, np.ones_like(depth)), axis=-1)
#print(camera_points.shape)

world_points = camera_points @ camera_transform.T
#print(world_points.shape)

table_points = world_points @ np.linalg.inv(plane_transform).T
heights = table_points[:, :, 1]
#print(heights.shape)
#print(heights[sample_y, sample_x] * 1000)

patch_heights = heights[90:100, 120:130]
patch_valid = valid[90:100, 120:130]

desk_heights = heights[40:50, 115:125]
desk_valid = valid[40:50, 115:125]

#print(desk_heights.shape)
#print(desk_valid.sum())
#print(np.median(desk_heights[desk_valid]) * 1000)
#print(np.percentile(desk_heights[desk_valid] * 1000, [10, 90]))

#print(patch_heights.shape)
#print(patch_valid.sum())
#print(np.median(patch_heights[patch_valid]) * 1000)
#print(np.percentile(patch_heights[patch_valid] * 1000, [10, 90]))

rgb = plt.imread(capture_folder / "rgb-preview.png")
#print(rgb.shape)

box_corners = np.array([(88.0, 71.4), (149.4, 70.1), (148.6, 125.8), (87.2, 123.6)])
#print(box_corners.shape)

box_polygon = PolygonPath(box_corners)

pixel_coordinates = np.column_stack(
    (pixel_x.ravel(), pixel_y.ravel())
)
#print(pixel_coordinates.shape)

box_mask = box_polygon.contains_points(pixel_coordinates)
box_mask = box_mask.reshape(depth.shape)

print(box_mask.sum())

usable_box = box_mask & valid

print(usable_box.sum())
print(100 * usable_box.sum() / box_mask.sum())

box_heights_mm = heights[usable_box] * 1000

#print(np.median(box_heights_mm))
#print(np.percentile(box_heights_mm, [10, 90]))

table_x = table_points[:, :, 0]
table_z = table_points[:, :, 2]

#print(table_x.shape)
#print(table_z.shape)

table_coordinates = np.stack((table_x, table_z), axis=-1)
#print(table_coordinates.shape)

top_left = table_coordinates[:-1, :-1]
top_right = table_coordinates[:-1, 1:]
bottom_right = table_coordinates[1:, 1:]
bottom_left = table_coordinates[1:, :-1]

#print(top_left.shape)
#print(top_right.shape)
#print(bottom_right.shape)
#print(bottom_left.shape)

edge_a = top_right - top_left
edge_b = bottom_right - top_left
edge_c = bottom_right - top_left
edge_d = bottom_left - top_left


#print(edge_a.shape)
#print(edge_b.shape)

triangle_one_area = 0.5 * np.abs(
    edge_a[:, :, 0] * edge_b[:, :, 1]
    - edge_a[:, :, 1] * edge_b[:, :, 0]
)

#print(triangle_one_area.shape)

triangle_two_area = 0.5 * np.abs(
    edge_c[:, :, 0] * edge_d[:, :, 1]
    - edge_c[:, :, 1] * edge_d[:, :, 0]
)

cell_area = triangle_one_area + triangle_two_area
#print(cell_area.shape)

usable_cells = (
    usable_box[:-1, :-1]
    & usable_box[:-1, 1:]
    & usable_box[1:, 1:]
    & usable_box[1:, :-1]
)
#print(usable_cells.shape)
#print(usable_cells.sum())

usable_area_cm2 = cell_area[usable_cells].sum() * 10000
print(usable_area_cm2)

height_tl = heights[:-1, :-1]
height_tr = heights[:-1, 1:]
height_br = heights[1:, 1:]
height_bl = heights[1:, :-1]

triangle_one_height = (height_tl + height_tr + height_br) / 3
triangle_two_height = (height_tl + height_br + height_bl) / 3

cell_volume = (
    triangle_one_area * triangle_one_height
    + triangle_two_area * triangle_two_height
)

usable_volume_ml = cell_volume[usable_cells].sum() * 1_000_000
print(usable_volume_ml)
#plt.plot(sample_x, sample_y, marker="+", color="black", markersize=14)
#plt.imshow(np.where(valid, depth, np.nan), cmap="gray")
#plt.colorbar(label="Depth (metres)")
#plt.xlabel("Depth pixel column")
#plt.ylabel("Depth pixel row")
#plt.title("High-confidence depth")
#plt.show()
#plt.figure()
#plt.imshow(np.where(valid, heights * 1000, np.nan),
#           cmap="gray", vmin=-10, vmax=60)
#plt.colorbar(label="Height above table (mm)")
#plt.xlabel("Depth pixel column")
#plt.ylabel("Depth pixel row")
#plt.title("High-confidence height above table")
#plt.show()

plt.figure()
plt.imshow(rgb, extent=(-0.5, 255.5, 191.5, -0.5))
plt.xlabel("Depth pixel column")
plt.ylabel("Depth pixel row")
plt.title("RGB image in depth-pixel coordinates")
plt.show()