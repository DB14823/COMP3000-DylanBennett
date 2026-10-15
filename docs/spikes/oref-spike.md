# Oref integration experiment

AI-assisted planning scaffold for Task 4. Status: not started.

Can the dosing algorithm run independently of Trio, and which integration route
can OrefAdapter use? Time limit: 2 working days. Dylan-managed branch:
`spike/oref`; experiment location: `spikes/OrefSpike/`.

## Inputs and criteria

- Inspect the planned Trio v1.0.0 release; record its actual tag and commit.
  Locate the algorithm and map imports, app-specific types, and model dependencies.
- Record whether the implementation is Swift, JavaScript, or a combination;
  do not assume a standalone Swift library exists.
- Success evidence: an independently building experiment runs one upstream
  fixture and records the dosing output and comparison with the reference result.
- Identify fixtures suitable for later regression tests and choose dependency,
  isolated attributed third-party package, or JavaScriptCore integration.
- Inspect licences for the exact files and revisions used. Existing notes
  distinguish the Trio app from trio-oref; verify applicability for this route.
- At the time limit, a partial or failed result still informs the fallback choice.

## Reproduction and observations

Record source revisions, files and size, dependency map, licence paths, commands,
fixture provenance, outputs, failures, actual dates, hours, and evidence paths.

## Decision

Dylan records the route, justification, remaining unknowns, revised OrefAdapter
estimate, and proposed design, risk, and backlog changes after running the spike.
