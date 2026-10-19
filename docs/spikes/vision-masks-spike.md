# Food segmentation experiment

Are Apple's Vision foreground instance masks sufficient for individual food
items? 

branch: `spike/vision-masks`;
experiment location: `spikes/MaskSpike/`.
Time limit: 1.5 days 
Time elapsed:

## Inputs and criteria

- Planned set: 6.
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
Vision's masks were shown not to be capable, as they all included the plate in the "foreground" for the test images used. Alternative pre-trained model (google/mobile-food-segmenter-v1) was tested, providing better results; with stronger segmentation between foods and separating the plate, although limitations were discovered:
- Some food merging still remained
- Broad food categorisation e.g. different fruits were just classed as "fruit"
- Some foods were still missed 

Consistent manual cropping did produce improved results, although these were development observations; not a measured pass rate. 

## Decision
After testing a set of 40 images from the dataset, as well as a separate set of the same images after cropping them, I will be going ahead with using this segmentation model. The results of this experiment can be found in '/Users/dylan/Uni/COMP3000/Docs/Food segmenter obs.xlsx' and evidence that cropping is  beneficial in this sample, however correctly masking each individual food is still rather unreliable, and users may have to manually correct food labels/merged regions. 
Running the model on iOS, and using it for volume estimation remains untested.

