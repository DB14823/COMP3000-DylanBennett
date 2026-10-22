# LiDAR capture and volume experiment

Can iPhone depth captures support useful food-scale volume estimates,
and what capture format should replay use? Time limit: 2.5 working days.
branch: `spike/lidar-capture`; experiment location: `spikes/CaptureSpike/`.
## Inputs and criteria
- Use the iPhone 15 Pro for capture only. The experiment must contain no
  Bluetooth, CGM, or pump communication code.
- Capture a measured cuboid, a bowl of rice with independently measured volume,
  and a meal; three captures each, top-down from roughly 30 to 40 cm.
- Pass: cuboid absolute volume error is at most 15% on at least two of three
  captures. Report every capture, including failures and confidence exclusions.
- Validate intrinsics scaling, ARKit camera axes, world transform, and table
  plane alignment before interpreting volume errors.
- Examine bowl rim and floor effects and depth resolution at small food scales.
- Confirm capture format v0: RGB, Float32 depth, UInt8 confidence, dimensions,
  intrinsics, camera and plane transforms, timestamp, device, and units. Record
  matrix order and binary byte order so replay can reconstruct captures.
## Reproduction and observations
- Measured box: 9.5 × 8.1 × 4.4 cm, volume: 338.58 mL.
- iPhone 15 Pro captures RGB, depth, confidence, and metadata from the same AR frame.
- Python reconstructs points using scaled intrinsics, transforms them into table coordinates, and calculates signed heights.
- Box outline selected manually from the matching RGB image.
- Retain only high-confidence, finite, positive depth readings.
- Volume calculated from projected triangles and their mean corner heights. Cells require four usable box corners; missing areas are not filled.

| Capture | Retained area (cm²) | Volume (mL) | Absolute error |  Folder name  | Manual coordinates (top-L, top-R, bottom-L, bottom-R) | Usable pixel count + % |
|---|---:|---:|---:| --- | --- | --- |
| 1 | 70.39 | 324.99 | 4.01% |  Box\_test\_01|  (91.9, 66.0) (160.6, 72.0) (155.0, 131.2) (87.2, 124.3)|  3749/4044 - 92.7% |
| 2 | 69.74 | 320.99 | 5.20% |  Box\_test\_02| (91.1, 70.3) (143.5, 68.0) (145.1, 131.5) (92.7, 131.4) |  3065/3262 - 93.9% |
| 3 | 71.02 | 322.34 | 4.80% | Box\_test\_03 | (88.0, 71.4) (149.4, 70.1) (148.6, 125.8) (87.2, 123.6) |  3095/3313- 93.4% |
#### Validation and limitations
- Angled debugging capture: interior patch median 44.97 mm vs 44 mm measured height.
- First top down capture: interior patch median 46.99 mm, desk patch median 0.57 mm.
- Exclusions occur around box boundaries.
- Missing area and overestimated height may partly cancel.
- These are controlled cuboid results using manual outlines; food volume performance remains untested.
## Decision
- Cuboid criterion met 3/3, assuming independent captures and individually selected outlines.
- Overall suitability decision pending bowl-of-rice and meal tests.
- Remaining work: three captures each, independent rice-volume reference, bowl rim/floor effects, confidence exclusions, and reproducibility checks.
