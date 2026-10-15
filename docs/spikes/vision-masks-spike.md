# Food segmentation experiment

AI-assisted planning scaffold for Task 5. Status: not started.

Are Apple's Vision foreground instance masks sufficient for individual food
items? Time limit: 1.5 working days. Dylan-managed branch: `spike/vision-masks`;
experiment location: `spikes/MaskSpike/`.

## Inputs and criteria

- Planned set: 20 own meal photos, split between top-down and roughly 45-degree
  views, plus 20 Nutrition5k overhead images. If unavailable, use 40 own photos.
  Include single items, multiple items, and a bowl; record the selected set first.
- Run `VNGenerateForegroundInstanceMaskRequest` and retain instance overlays.
- Record truth food count, returned instance count, correctly separated foods,
  merged foods, missed foods, and masks containing plate or bowl for each image.
- Pass: correctly individually segmented food items / total truth food items
  is at least 70%, and masks containing plate or bowl / total returned masks is
  below 30%. For zero returned masks, the plate rate is undefined, not zero;
  segmentation fails for a nonempty food set.
- Define annotation rules before scoring, including what counts as one food
  item and an individually separated item. Record typical failure modes.
- Optional: hand-annotate 10 images and record IoU to support risk assessment.
  This does not replace the pass criteria above.

## Reproduction and observations

Record image provenance and paths, macOS and tool versions, commands, scoring
table, overlays, counts, calculated rates, actual dates, hours, and limitations.

## Decision

Dylan records Apple Vision or trained segmentation, supporting evidence,
remaining limitations, revised estimate, and design, R3, and backlog changes.
