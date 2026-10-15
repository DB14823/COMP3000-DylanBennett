# Training environment and dataset readiness

AI-assisted planning scaffold for Task 7. Status: not started.

Can the training PC run the intended GPU workflow with a reproducible Nutrition5k
subset? Time limit: 1 working day, allowing for downloads. Planned locations:
`ml/requirements.txt`, `ml/README.md`, and Dylan's `ml/scripts/check_env.py`.

## Inputs and criteria

- Use the RTX 4060 training PC. Record Python, driver, PyTorch, torchvision, and
  other direct dependency versions installed in a dedicated environment.
- Dylan implements the environment check. Success evidence: CUDA available,
  expected GPU and VRAM reported, and a 1024 by 1024 GPU matrix multiplication
  runs under float16 autocast.
- Acquire only Nutrition5k overhead RGB-D, metadata, labels, and splits.
  Record the source, licence evidence, download date, local path, disk size,
  dish count, and missing or corrupt files.
- Preserve the supplied train and test split. Record how files and labels match;
  downloaded files alone do not establish dataset readiness.
- Keep datasets and model outputs outside Git. Commit only configuration,
  setup documentation, and Dylan's environment-check implementation.

## Reproduction and observations

Record setup commands, exact versions, environment output, dataset inventory,
paths, failures, actual dates, hours, and remaining setup work.

## Decision

Dylan records environment and dataset readiness, blockers, reproducible setup,
and proposed backlog changes. Model training and measured model accuracy belong
to later work.
