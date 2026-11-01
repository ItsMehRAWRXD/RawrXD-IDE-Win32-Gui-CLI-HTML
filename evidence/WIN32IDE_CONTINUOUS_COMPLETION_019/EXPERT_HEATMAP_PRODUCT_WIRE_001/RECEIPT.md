# EXPERT_HEATMAP_PRODUCT_WIRE_001

| Field | Value |
|-------|-------|
| Parent | WIN32IDE_CONTINUOUS_COMPLETION_019 |
| BEFORE | `DF9A0B5D…` (COMPLETION_018 SidebarRuntime) |
| AFTER | `62B2AF0458F259C843C1BA05247C7C140CCCDF9B67D68E278FE8623FBE865F74` |
| tip748B | `748B210A…` UNTOUCHED |
| LINK_EXIT | 0 |
| BUILT_SIZE | 332352000 |
| INVENT_HEATMAP_PASS | 0 |
| DEVICE_ORDINAL | WHY_HELD (ABSENT) |
| PROMOTE | 0 |

Wire: resurface `toggleExpertHeatmapPanel` + append-only `m_hwndExpertHeatmapPanel`;
facade `CaptureSwarmExpertHeatmap`/`SwarmPlanGeneration` on CPUInferenceEngine → RawrXDInference;
adapt orphan (planSpanOrdinal; no invent GPU affinity); cite
`RawrXD_UI_InitExpertHeatmapPanel`.
