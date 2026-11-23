# Fallout New Vegas Android — development status

**Snapshot date:** 2026-11-23. The source and APK are local to the developer. This document distinguishes user-observed behavior from unverified patches.

| Area | Status | Evidence / next action |
|---|---|---|
| Native ARM64 gameplay | **Runs on Honor** | Actual New Vegas gameplay has been reached |
| Android launcher | **Working local build** | Package `com.mojave.nativeedition` |
| Game-data OBB | **Previously verified** | ~9.2 GB local OBB with automatic extraction; do not upload |
| Graphics Stage 74 | **Previously fixed** | Preserve depth rounding/quantization change |
| Custom Mojave HUD | **User likes current layout** | Independent styling and custom tools; preserve |
| Menu cursor dragging | **Working in latest reports** | Direct menu tapping is optional and not verified |
| USE / Activate | **User confirmed working** | No speculative USE rewrite required |
| `~` console and keyboard | **Previously working** | Keep accessible during play |
| HIDE / SHOW | **Partially verified** | Invisible control hitboxes can still trigger actions; investigate unwanted menu touches |
| NPC dialogue | **Not fully verified** | Test Goodbye, scroll and exit from multiple NPCs |
| MAP in TOOLS | **Needs verification** | F3 should open Pip-Boy DATA; user selects World Map |
| Stage 27 graphics crash | **Intermittent, unresolved** | Need GL vs EGL error diagnostics |
| Null-function-pointer crash | **Intermittent, unresolved** | Need `FNVCall` caller/native trace |
| Outdoor gameplay FPS | **Needs optimization** | Latest: ~7–10 FPS at 1920×1080, High textures; prior ~15 FPS |
| FPS improvement | **No confirmed gain yet** | Profile actual CPU/GPU costs and retest |
| Full source upload | **Deferred by developer** | Only workflow docs committed now |

## Rules for the next development session

1. **Do not overwrite the working local baseline** until another build is verified on the actual device.
2. Fix reproducible crashes and input regressions with precise logs, not speculative patches.
3. Leave the custom HUD, 9.2 GB OBB, working menu mouse, console and USE intact.
4. Fix incomplete conversation flow only after verifying the game receives expected inputs.
5. Profile CPU guest execution, native GL calls, framebuffer blits, texture/shader work and synchronization for FPS.
6. Record before/after outdoor FPS with identical graphics settings and location.
7. Upload only permitted redistributable source and scripts later; do not commit proprietary Fallout assets.

The user's current goal is a stable full native Android game with customized controls, not a demo. Performance targets such as 20–30 FPS are aspirations, not verified results.
