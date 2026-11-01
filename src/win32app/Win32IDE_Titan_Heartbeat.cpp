/**
 * @file Win32IDE_Titan_Heartbeat.cpp
 * @brief Titan Paging Heartbeat Implementation (Phase 15.4)
 *
 * AUDIT_002_OPENISH_OTHER_DRAIN_005:
 * Prior: invent 0% paging + cacheHit=100 as live Titan telemetry (fake-ready).
 * Now: FEATURE_FICTION=1 FAIL_CLOSED — no invent PASS. Orphan TU (not tip link).
 * PROMOTE=0 TIP_CLIMB=HOLD CERTIFIED=0 PERFECT=0 NOT_RUN!=PASS
 */

#include "Win32IDE.h"
#include "Win32IDE_Phase16_AgenticController.h"

static const UINT_PTR TITAN_PAGING_HEARTBEAT_TIMER_ID = 8889;
static const UINT TITAN_PAGING_HEARTBEAT_INTERVAL_MS = 250;

namespace {
void GateFiction(const char* name) {
    char buf[224];
    wsprintfA(buf,
        "[TitanHeartbeat] FEATURE_FICTION=1 FAIL_CLOSED name=%s\n", name);
    OutputDebugStringA(buf);
}
} // namespace

void Win32IDE::startTitanPagingHeartbeat(uint32_t timeoutMs)
{
    if (m_titanPagingHeartbeatActive)
    {
        return;
    }

    m_titanPagingHeartbeatActive = true;
    m_titanPagingHeartbeatStartTime = GetTickCount64();
    m_titanPagingHeartbeatTimeoutMs = timeoutMs;

    SetTimer(m_hwndMain, TITAN_PAGING_HEARTBEAT_TIMER_ID, TITAN_PAGING_HEARTBEAT_INTERVAL_MS, nullptr);

    if (m_hwndStatusBar)
    {
        // Was: invent "[Titan] Paging... 0%" as live aperture readout.
        SendMessageW(m_hwndStatusBar, SB_SETTEXT, 0,
                     (LPARAM)L"[Titan] FEATURE_FICTION=1 FAIL_CLOSED (no aperture wire)");
    }

    GateFiction("startTitanPagingHeartbeat");
}

void Win32IDE::onTitanPagingHeartbeatTimer()
{
    if (!m_titanPagingHeartbeatActive)
    {
        return;
    }

    // Was: invent total_pct=0 + cacheHit=100 as live Titan metrics (no DLL query).
    GateFiction("onTitanPagingHeartbeatTimer");
    if (m_hwndStatusBar)
    {
        SendMessageW(m_hwndStatusBar, SB_SETTEXT, 0,
                     (LPARAM)L"[Titan] FEATURE_FICTION=1 FAIL_CLOSED (no invent metrics PASS)");
    }

    if (m_titanPagingHeartbeatTimeoutMs > 0)
    {
        uint64_t elapsed = GetTickCount64() - m_titanPagingHeartbeatStartTime;
        if (elapsed > m_titanPagingHeartbeatTimeoutMs)
        {
            stopTitanPagingHeartbeat();
        }
    }

    AgenticControllerHeartbeat();
}

void Win32IDE::stopTitanPagingHeartbeat()
{
    if (!m_titanPagingHeartbeatActive)
    {
        return;
    }

    KillTimer(m_hwndMain, TITAN_PAGING_HEARTBEAT_TIMER_ID);

    m_titanPagingHeartbeatActive = false;
    m_titanPagingHeartbeatStartTime = 0;
    m_titanPagingHeartbeatTimeoutMs = 0;

    if (m_hwndStatusBar)
    {
        SendMessageW(m_hwndStatusBar, SB_SETTEXT, 0, (LPARAM)L"Ready");
    }

    GateFiction("stopTitanPagingHeartbeat");
}
