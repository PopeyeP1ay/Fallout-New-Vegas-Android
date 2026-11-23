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
| Menu / in-game music | **Missing in latest test; unresolved** | Verify `Data/Music/Special/MainTitle.mp3` exists in the app’s private game directory, inspect `FNVMedia` file/decoder logs, then investigate Android MediaPlayer bridge |
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

## 2026-11-23: first measured native FPS profile

The developer ran the instrumented APK on the Honor and uploaded the `FNVPerf` log. Eleven 60-frame windows reported **10.61–17.05 FPS** (mean ~12.9), **58.64–94.28 ms total frame time** (mean ~79.2 ms), **2.72–4.23 ms presentation CPU time** (mean ~3.44 ms), **0.98–1.35 ms EGL swap** (mean ~1.13 ms), **~0.10–0.13 ms final blit**, **~0.04–0.14 ms draw error checks**, and roughly **146–552 draw calls per frame**. The specifically instrumented readback and query-poll paths were near zero in these windows.

**Interpretation:** final framebuffer blit, swap and per-draw GL error checks are not enough to explain the slow frames. Approximately **~76 ms per frame on average occurred outside measured presentation**, but that remainder includes guest game execution, graphics command setup, potential driver work, and other uninstrumented operations; it is **not automatically CPU gameplay time**. The higher-draw windows generally had lower FPS, but scenes were not controlled, so draw-call correlation is not proof of causality.

**Next diagnostic:** apply `Profile-NewVegas-DrawCalls-v2.ps1` locally (not yet committed as source). It adds `FNVPerf2` counters for CPU time in draw dispatch, program/shader setup, texture/sampler binding, uniforms, rendering state, vertex attributes and GL draw submission. Rebuild and test the same outdoor scene. Preserve the existing working APK, HUD, joystick, USE, OBB and Stage 27 diagnostics. Do **not** remove correctness checks or modify shader semantics speculatively.

## 2026-11-23: FPS v2 device profile

The Honor test produced 12 real gameplay samples in `FNV-Raw-FPS.txt` between 07:46:15 and 07:47:18 (local time):

- Mean frame time: **95.00 ms** (~**10.55 FPS** as the mean of reported FPS samples).
- Mean **outsideDraw**: **69.91 ms/frame** (~74% of frame time). This includes game execution and any native operations not timed by the draw-call profiler; it does **not** prove the x86 game itself consumes all that time.
- Mean **drawAll**: **22.08 ms/frame** (~23%); preparation **8.24 ms**, vertex attributes **1.88 ms**, draw issue **10.97 ms**.
- Mean final presentation: **3.01 ms/frame** (~3%).
- Mean visible draw calls: **603.4/frame** (range 511.8–698.8).
- `glGetError`, `glReadPixels`, and measured query waits contributed negligible time in these samples.

**Conclusion:** The highest-priority work is measuring and eliminating unnecessary time outside actual draws, including possible D3D shim overhead, EGL context transfers between guest imports, and native/recompiled game execution. Do not claim one of these is the proven root cause yet.

**Unverified experiment only:** `Try-NewVegas-FastContext-v1.ps1` can retain EGL ownership across non-graphics guest imports until another thread requests it. This is **not** a verified fix and is **not committed** to GitHub; it must be compiled and A/B benchmarked on device with a rollback source/APK.
