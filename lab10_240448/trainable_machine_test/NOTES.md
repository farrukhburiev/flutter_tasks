# Lab 10: Teach It, Ship It

## Class list
1. window
2. me
3. phone
4. termiz
5. lights
6. nothing (background class)

## Part 1: Model

**What does the model answer for an object that belongs to none of the classes? How does the background class change that?**
The model ends in a softmax, so it always spreads 100% over the known classes and must pick the closest one, often with high confidence. It has no "I don't know" output. The background class gives it a place to put empty or unrelated scenes, so those map to "nothing" instead of a random object. It does not catch every unknown object.

**Floating point vs Quantized?**
- Size: the quantized file is roughly 4 times smaller.
- Input type: floating point takes float32 values from -1 to 1; quantized takes uint8 values from 0 to 255.
- Dart code: floating point needs `value / 127.5 - 1`; quantized needs no normalisation and the output is divided by 255.

## Part 2: Setup

**`assets/model/` vs `assets/`?**
`assets/model/` bundles only the files directly inside that folder (`model_unquant.tflite`, `labels.txt`). `assets/` bundles only files directly inside `assets/`, not those in subfolders, so the model files would be missing.

**Why do `image` and `http` run in plain Dart tests but `tflite_flutter` and `image_picker` do not?**
`image` and `http` are pure Dart and run on the Dart VM. `tflite_flutter` and `image_picker` call native Android and iOS code through platform channels, which do not exist in a unit test.

## Part 3: Classifier

**How is the classifier shared?**
It is created once in `main.dart` (`Classifier.load()` in `initState`) and passed to screens through the constructor. No screen calls `Classifier.load()` itself. `close()` is called in `dispose` and when the app lifecycle reaches `detached`.

**Change the normalisation to `value / 255`. What happens and why does nothing crash?**
The input values now range from 0 to 1 instead of -1 to 1. The tensor still has the right shape and type, so the model runs without error. But the pixel values are different from what it saw in training, so the percentages become wrong and often confidently skewed towards one class.

**Where is the number of classes written down? What to edit after a seventh class?**
Only in `labels.txt` and in the model's output shape. The code uses `labels.length` and checks it against the output tensor at start-up. After retraining with a seventh class, replace both exported files in `assets/model/`; no Dart code changes.

## Evaluation table (Part 5)
| Source | Expected | Predicted | Percentage | Correct |
|---|---|---|---|---|

Overall accuracy: 

Weakest class: 
