# Oref integration experiment
Can the dosing algorithm run independently of Trio, and which integration route
can OrefAdapter use? Branch:`spike/oref`; experiment location: `spikes/OrefSpike/`.
Time limit: 2 working days
Estimated time: \~18 hours (future OrefAdapter implementation)
Elapsed spike time: 5 hours
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
Trio's oref can be built separately from the app, and can be called from a separte executable through a small public bridge. If glucose data is stale, the algorithm accomodates it and adjusts the dosing output accordingly. Tests run on the independent build produce same outputs as Trio's pre-existing tests in the selected scenario.
The test used for this was "shortenLongZeroTempTooOldBG" from Trio's "DetermineBasalEarlyExitTests.swift". The inputs were defined as:
- Glucose data - 15 minutes old
- Pre-existing temporary basal rate of 0 Units/hour for 60 minutes 
#### Expected results:
- Basal rate stays at 0 U/hour
- Duration is reduced from 60 mins to 30 mins
- Explanation as to why includes 'shortening'
#### Observed results: 
The separate executable returned all three expected values
#### Check verification:
Changing the expected duration from 30 to 31 made the executable fail; restoring it to 30 made it pass again, demonstrating that this check can detect a mismatch and that this scenario does work as intended through the bridge. It does not establish that every dosing scenario would also work.

After editing the TrioAlgorithm package.swift to include iOS as a platform and executing the following command, the build succeeded, evidencing that the bridge approach is worth pursuing:

```bash
xcodebuild \
  -scheme TrioAlgorithm \
  -destination 'generic/platform=iOS Simulator' \
  CODE_SIGNING_ALLOWED=NO \
  build
```

The fixture was run on macOS and compiled for an iOS simulator.
- 75 files, only importing Apple's 'Foundation' and 'CoreGraphics'; no pump/CGM drivers etc.
- These files cover the current package selection - not a minimum subset 
- Small substitute implemented to remove app dependency - already provided by Trio

#### License details:
- Release: v1.0
- Commit: 46b559dcdcb2a5f6ca6316eda32c7be6b7d5387e
- Licence file inspected: LICENSE.txt
- Licence stated: MIT
##### Functional changes made to existing code:
- Created "OrefSpikeBridge.swift" in "Trio/Trio/Sources/APS/OpenAPSSwift"
- Edited platforms in "Trio/AlgorithmPackage/Package.swift" to include iOS 18.0
- Added the following to the same "Package.swift" to prevent translation-related build errors:
```swift
exclude: ["Localizations"],
```
   
## Decision
The integration route to be taken is to use an isolated third-party Swift package, containing the selected algorithm sources and a small public bridge. I have decided the because of the evidence supporting it:
- It built independently
- Successfully reproduced the selected scenario
- Compiled for the iOS simulator

More work remains to be done; namely the bridge needs to be added to in order to be able to accept changing inputs, and the OrefAdapter needs the necessary translation code and regression tests.
This route also means more maintainence will be required; attributions must be preserved, upstream commits must be recorded, and any modifications made need to be tracked.


