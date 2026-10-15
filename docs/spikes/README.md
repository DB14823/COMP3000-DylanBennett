# Sprint 0b spike workflow

Sprint 0b runs from 13 to 26 October 2026. Its purpose is to resolve the oref,
segmentation, LiDAR, and ML setup uncertainties before production implementation.
These AI-assisted planning notes provide structure; Dylan supplies implementation,
measurements, conclusions, and assessed writing.

## Working sequence

1. Read the relevant sprint-plan task and experiment sheet below. Confirm the
   question, time limit, inputs, and success criteria before collecting results.
2. Dylan creates or selects the planned branch. Keep experiment code isolated;
   do not merge spike implementation into main. The assistant uses GitHub only
   to inspect information and never stages, commits, or changes remote state.
3. Agree one interface or file at a time. The assistant supplies guidance and
   suitable failing tests; Dylan implements and explains the result.
4. Run the smallest experiment that can answer the question. Record exact source
   revisions, tool versions, fixtures, commands, outputs, and failure details.
5. At the time limit, stop expanding the experiment. Record worked, partial,
   failed, or inconclusive, with evidence and remaining uncertainty.
6. Dylan records the chosen approach, alternatives, licence implications where
   relevant, revised effort estimate, and effect on the design and backlog.
7. The assistant reviews the evidence and checks consistency. Dylan commits the
   relevant files himself and retains findings separately from throwaway code.

## Experiment sheets

| Task | Sheet | Time limit | Decision |
| --- | --- | --- | --- |
| 4 | [oref-spike.md](oref-spike.md) | 2 working days | Dependency, isolated third-party sources, or JavaScriptCore route |
| 5 | [vision-masks-spike.md](vision-masks-spike.md) | 1.5 working days | Apple Vision or a trained segmenter |
| 6 | [lidar-spike.md](lidar-spike.md) | 2.5 working days | Volume feasibility and capture format |
| 7 | [ml-setup.md](ml-setup.md) | 1 working day, allowing for downloads | Reproducible training environment and dataset readiness |

Use [template.md](template.md) for further experiments. Record actual hours and
dates rather than assuming how many hours a working day contains.

## Evidence and criteria

Use the existing Task 5 criteria: at least 70% of food items individually
segmented, with plate inclusion in fewer than 30% of masks. The risk plan's
10-image IoU threshold is supplementary evidence, not a replacement pass rule.
Dylan should reconcile R3 with this criterion before starting the experiment.
Any subsequent change to the criteria must be dated and explained before scoring.

Store small commands, metadata, tables, and text outputs with the sheet. Keep
large image, depth, dataset, and model files outside Git and record their absolute
paths. Retain originals so results can be reproduced. Do not claim upstream
licensing or API behaviour is verified until the pinned source is inspected.

## Local checks

From the repository root:

```sh
scripts/check-architecture.sh
swift test --package-path Packages/Domain --scratch-path Packages/Domain/.build/cli
scripts/check-local.sh packages
scripts/check-local.sh app
```

The package check covers production packages, not standalone spike projects.
Each spike must record its own build or run command. The app command builds for
the simulator; it does not install software on a real device.

## Sprint review

Task 8 brings together the four decisions, evidence, remaining risks, revised
estimates, and proposed Sprint 1 work. Update the design and risk plan from
observed results. Bring unresolved choices to the supervisor. Never fill in
findings before the experiment is performed.
