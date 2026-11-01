# AUDIT_002_OPENISH_OTHER_DRAIN_015 — FILE_EVIDENCE

```
QUALITY_BAR=1
tip748B=1
STOPPED_SUPERSEDED=1
TIP_REBUILD=0
RUNTIME_REACHED=NOT_RUN
PROMOTE=0
TIP_CLIMB=HOLD
CERTIFIED=0
PERFECT=0
DUAL_COUNT_CAVEAT=1
  OPENISH_-9 and OTHER_-9 = same nine classifications (not 18)
ASOF_UTC=2026-10-29T17:50:00Z
```

## Selection (next nine eligible OPENISH/OTHER after DRAIN_014)

| # | Path | Prior class | After class | Surface gated | Implementation (actual) | Missing dependency / gap |
|--:|------|-------------|-------------|---------------|-------------------------|--------------------------|
| 1 | `src/win32app/gguf_loader_masm.cpp` | OTHER | GATED_FICTION | `Win32IDE_InitGGUFLoader` | Export present; EnsureEngine/Bridge path held — returns `false` + SetErr | Tip product GGUF wire; orphan TU ≠ tip link |
| 2 | `src/win32app/gguf_loader_masm_real.cpp` | OTHER | GATED_FICTION | `Win32IDE_InitGGUFLoader` | Parallel “real” TU; same fail-close | Same; duplicate surface must not invent ready |
| 3 | `src/win32app/memory_modules/memory_module_template.cpp` | OTHER | GATED_FICTION | `OptimizeContextBuffer` | Template TU; pre-fault/SetProcessInfo theater removed | Product memory-module bind + measured optimize |
| 4 | `src/win32app/UnifiedEditorContext.cpp` | OTHER | GATED_FICTION | `UnifiedEditorContext::Initialize` | Class body exists; Initialize nulls HWND/snapshot and logs FAIL_CLOSED | Validated editor HWND product wire (UECR) |
| 5 | `src/win32app/Win32IDE_ReferenceGraph.cpp` | OTHER | GATED_FICTION | `initReferenceGraphPanel` | Graph TU present; RegisterClass ready invent held | Real graph panel register + data source |
| 6 | `src/win32app/IDELogger.cpp` | OTHER | GATED_FICTION | `IDELogger::initialize` | Logger TU present; spdlog/ofstream ready invent held | Product log sink wired + verified open |
| 7 | `src/win32app/Win32IDE_TerminalProfiles.cpp` | OTHER | GATED_FICTION | `TerminalProfileManager` ctor | Profiles TU present; invent-3-shells held | Shell discovery / profile I/O |
| 8 | `src/win32app/AgenticBrowser_Relayout.cpp` | OTHER | GATED_FICTION | `Show` / `Relayout` | Browser helpers present; empty Show/Relayout invent held | Real browser HWND + layout engine |
| 9 | `src/win32app/Win32IDE_Main.cpp` | OTHER | GATED_FICTION | legacy `WinMain` | Legacy entry TU; VSIX/agentic/engine theater held | Canonical product entry ≠ this orphan theater |

## Source-gate presence (spot-check)

| Path | `DRAIN_015` mark | `FEATURE_FICTION=1 FAIL_CLOSED` hits |
|------|:----------------:|------------------------------------:|
| gguf_loader_masm.cpp | 1 | 3 |
| gguf_loader_masm_real.cpp | 1 | 3 |
| memory_module_template.cpp | 1 | 2 |
| UnifiedEditorContext.cpp | 1 | 2 |
| Win32IDE_ReferenceGraph.cpp | 1 | 2 |
| IDELogger.cpp | 1 | 2 |
| Win32IDE_TerminalProfiles.cpp | 1 | 2 |
| AgenticBrowser_Relayout.cpp | 2 | 4 |
| Win32IDE_Main.cpp | 1 | 3 |

## Regression — DRAIN_014 sites (not re-touched; gates intact)

| Path | FAIL_CLOSED hits | Status |
|------|-----------------:|--------|
| Win32IDE_FileIcons.cpp | 3 | OK |
| Win32IDE_Refactoring.cpp | 3 | OK |
| Win32IDE_Git.cpp | 2 | OK |
| Win32IDE_FailureIntelligence_Handler.cpp | 4 | OK |
| Win32IDE_RingBuffer.cpp | 3 | OK |
| Win32IDE_MMF_Core.cpp | 5 | OK |
| Win32IDE_SharedState.cpp | 3 | OK |
| Win32IDE_LineStripEditor.cpp | 2 | OK |
| StatusBarGitMonitor.cpp | 2 | OK |

## Tip authority (no rebuild)

```
EXE=G:\~dev\rawrxd\evidence\TIP_FREEZE_001\bin\RawrXD-Win32IDE.exe
LIVE_SHA256=748B210A8F17C6C47685BE1E2718CB0113C070E47881AD3A76B2EBB013934145
tip748B=1 MATCH
TIP_REBUILD=0 ABSORB=NOT_AUTHORIZED
STOPPED_SUPERSEDED=1 (campaign prior workers; tip freeze authority preserved)
```

## Ledger reconcile (adjudicated inventory TOTAL=323)

| Bucket | N |
|--------|--:|
| GATED_FICTION | 153 |
| BRIDGE_GATED | 14 |
| OTHER | 62 |
| EXTENSION | 23 |
| UI_PANEL | 24 |
| DEBUGGER | 9 |
| TEST | 22 |
| HEADLESS_ALT | 8 |
| GHOSTTEXT | 3 |
| QUARANTINE | 3 |
| STUB | 2 |
| **TOTAL** | **323** |

Seal counts (strict drain math; same nine): OPENISH 135→126 (−9); OTHER 71→62 (−9); GATEDISH 188→197 (+9).

## Explicit non-claims

```
SOURCE_WIRED != RUNTIME_REACHED != PASS
NOT_RUN != PASS
nine_file_gates != nine_runtime_components
OPENISH_OTHER_dual_delta != eighteen_resolutions
PROMOTE=0 PERFECT=0 CERTIFIED=0
```
