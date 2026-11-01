// startup_sentinels.cpp
// CRT-level entry probe: fires before HeadlessIDE::initialize and main_win32 logic
// This confirms whether the process reaches user-mode initialization at all

#include <windows.h>
#include <cstdio>
#include <ctime>

// Static constructor - runs during CRT initialization, before main/WinMain
class CRTEntrySentinel
{
public:
    CRTEntrySentinel()
    {
        logCRTEntry();
    }

private:
    void logCRTEntry()
    {
        DWORD pid = GetCurrentProcessId();
        SYSTEMTIME st;
        GetSystemTime(&st);

        // Format: [HH:MM:SS.mmm] PID=XXXXX CRT_ENTRY_REACHED
        char buffer[256];
        snprintf(buffer, sizeof(buffer),
                 "[%02d:%02d:%02d.%03d] PID=%u CRT_ENTRY_REACHED\n",
                 st.wHour, st.wMinute, st.wSecond, st.wMilliseconds,
                 pid);

        // Log to stderr (visible in console/OutputDebugString)
        fputs(buffer, stderr);
        fflush(stderr);

        // Also log to file
        FILE* traceFile = nullptr;
        errno_t err = fopen_s(&traceFile, "startup_crt_entry.log", "a");
        if (err == 0 && traceFile)
        {
            fputs(buffer, traceFile);
            fclose(traceFile);
        }

        // Output to debugger
        OutputDebugStringA(buffer);
    }
};

// Global instance - ctor runs during CRT startup
static CRTEntrySentinel g_crt_entry_probe;

// ============================================================================
// STATIC INIT COMPLETION SENTINEL
// AUDIT_002_OPENISH_OTHER_DRAIN_016:
// Prior: invent STATIC_INIT_COMPLETE_OK as product startup ready PASS without
// validated product wire (fake-ready / empty-true).
// Now: FEATURE_FICTION=1 FAIL_CLOSED — no invent PASS.
// Orphan TU (not tip link). PROMOTE=0 TIP_CLIMB=HOLD CERTIFIED=0 PERFECT=0 NOT_RUN!=PASS
// ============================================================================
namespace
{
    class StaticInitCompleteSentinel
    {
    public:
        StaticInitCompleteSentinel()
        {
            DWORD pid = GetCurrentProcessId();
            SYSTEMTIME st;
            GetSystemTime(&st);

            char buffer[256];
            // Was: invent STATIC_INIT_COMPLETE_OK ready PASS.
            snprintf(buffer, sizeof(buffer),
                     "[%02d:%02d:%02d.%03d] PID=%u FEATURE_FICTION=1 FAIL_CLOSED "
                     "STATIC_INIT_COMPLETE invent ready held\n",
                     st.wHour, st.wMinute, st.wSecond, st.wMilliseconds,
                     pid);

            fputs(buffer, stderr);
            fflush(stderr);

            FILE* completeLog = nullptr;
            errno_t err = fopen_s(&completeLog, "startup_static_init_complete.log", "a");
            if (err == 0 && completeLog)
            {
                fputs(buffer, completeLog);
                fclose(completeLog);
            }

            OutputDebugStringA(buffer);
        }
    };

    static StaticInitCompleteSentinel g_static_init_complete_probe;
}
