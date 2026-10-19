from ai_edge_litert.interpreter import Interpreter
from PIL import Image
import numpy as np
import sys
from pathlib import Path

if len(sys.argv) < 3:
    print("Usage: inspect_model.py IMAGE_PATH OUTPUT_DIRECTORY")
    sys.exit(1)

interpreter = Interpreter(
                          model_path="/Users/dylan/Uni/COMP3000/Data/vision-masks/models/1.tflite"
                          )

interpreter.allocate_tensors()

input_path = Path(sys.argv[1])
output_directory = Path(sys.argv[2])

output_path = output_directory / f"{input_path.stem}.segmentation.png"
                                   

image = Image.open(sys.argv[1])

resized_image = image.resize((513,513))
pixels = np.asarray(resized_image)
input_data = np.expand_dims(pixels, axis=0)

interpreter.set_tensor(interpreter.get_input_details()[0]["index"], input_data)
interpreter.invoke()


predictions = interpreter.get_tensor(interpreter.get_output_details()[0]["index"])

class_map = np.argmax(predictions[0], axis=-1)

colours = np.asarray([
                      [0, 0, 0],        # 0: background
                      [0, 128, 0],      # 1: leafy greens
                      [0, 200, 100],    # 2: stem vegetables
                      [100, 255, 0],    # 3: non-starchy roots
                      [0, 128, 128],    # 4: other vegetables
                      [255, 255, 0],    # 5: fruit
                      [255, 0, 0],      # 6: meat
                      [255, 128, 128],  # 7: poultry
                      [255, 128, 0],    # 8: seafood
                      [255, 240, 180],  # 9: eggs
                      [128, 64, 0],     # 10: beans/nuts
                      [200, 160, 100],  # 11: baked goods
                      [220, 220, 220],  # 12: rice/grains/cereals
                      [255, 200, 0],    # 13: noodles/pasta
                      [160, 120, 60],   # 14: starchy vegetables
                      [128, 128, 0],    # 15: other starches
                      [128, 0, 0],      # 16: soups/stews
                      [128, 255, 128],  # 17: herbs/spices
                      [255, 255, 255],  # 18: dairy
                      [255, 0, 255],    # 19: snacks
                      [180, 100, 220],  # 20: sweets/desserts
                      [0, 255, 255],    # 21: beverages
                      [128, 128, 128],  # 22: fats/oils/sauces
                      [0, 0, 255],      # 23: food containers
                      [100, 100, 255],  # 24: dining tools
                      [255, 100, 180],  # 25: other food
                      ], dtype=np.uint8)



colour_pixels = colours[class_map]
colour_image = Image.fromarray(colour_pixels)
colour_image = colour_image.resize(
                                   image.size,
                                   resample=Image.Resampling.NEAREST
                                   )
colour_image.save(
                  output_path
                  )
print(colour_pixels.shape)


