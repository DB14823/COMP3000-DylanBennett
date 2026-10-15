# LiDAR capture and volume experiment

AI-assisted planning scaffold for Task 6. Status: not started.

Can iPhone depth captures support useful food-scale volume estimates, and what
capture format should replay use? Time limit: 2.5 working days. Dylan-managed
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

Record hardware, iOS and tool versions, measured reference dimensions and volumes,
capture paths, format details, commands, per-capture estimates and errors, actual
dates, hours, and failure modes. Keep captures outside Git.

## Decision

Dylan records whether the volume approach is feasible, confirmed format,
limitations, revised estimate, and proposed design, hardware-risk, and backlog
changes. Do not infer clinical suitability from this experiment.
