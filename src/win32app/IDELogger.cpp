#include "IDELogger.h"

#include <windows.h>
#include <fstream>
#include <chrono>
#include <iomanip>
#include <sstream>
#include <thread>
#include <string>
#include <fstream>
#include <ctime>
#include <set>

namespace {
    std::mutex g_ideLoggerMutex;
    std::ofstream g_ideLogFile;

    const char* levelToString(IDELogLevel level) {
        switch (level) {
            case IDELogLevel::DEBUG:    return "DEBUG";
            case IDELogLevel::INFO:     return "INFO";
            case IDELogLevel::WARNING:  return "WARN";
#undef ERROR
            case IDELogLevel::ERROR:    return "ERROR";
            case IDELogLevel::CRITICAL: return "CRITICAL";
            default:                    return "UNKNOWN";
        }
    }

    std::string nowTimestamp() {
        using namespace std::chrono;
        auto now = system_clock::now();
        auto t = system_clock::to_time_t(now);
        auto ms = duration_cast<milliseconds>(now.time_since_epoch()) % 1000;

        std::tm tmLocal{};
#ifdef _WIN32
        localtime_s(&tmLocal, &t);
#else
        tmLocal = *std::localtime(&t);
#endif

        std::ostringstream ss;
        ss << std::put_time(&tmLocal, "%Y-%m-%d %H:%M:%S")
           << '.' << std::setfill('0') << std::setw(3) << ms.count();
        return ss.str();
    }

} // anonymous namespace

IDELogger& IDELogger::getInstance() {
    static IDELogger inst;
    return inst;
}

// AUDIT_002_OPENISH_OTHER_DRAIN_015:
// Prior: initialize invent spdlog empty-return / ofstream open as IDE logger
// product ready PASS without validated product log wire (fake-ready / empty-true).
// Now: FEATURE_FICTION=1 FAIL_CLOSED — no invent PASS.
// Orphan TU (not tip link). PROMOTE=0 TIP_CLIMB=HOLD CERTIFIED=0 PERFECT=0 NOT_RUN!=PASS
void IDELogger::initialize(const std::string& logFilePath) {
    (void)logFilePath;
    std::lock_guard<std::mutex> lock(g_ideLoggerMutex);
    // Was: invent spdlog no-op return / open log file ready PASS.
    if (g_ideLogFile.is_open()) {
        g_ideLogFile.close();
    }
    OutputDebugStringA(
        "[IDELogger] FEATURE_FICTION=1 FAIL_CLOSED initialize "
        "(no invent IDE logger ready PASS)\n");
}

void IDELogger::log(IDELogLevel level, const std::string& message) {
#if __has_include(<spdlog/spdlog.h>)
    try {
        switch (level) {
            case IDELogLevel::DEBUG:    spdlog::debug(message); break;
            case IDELogLevel::INFO:     spdlog::info(message); break;
            case IDELogLevel::WARNING:  spdlog::warn(message); break;
            case IDELogLevel::ERROR:    spdlog::error(message); break;
            case IDELogLevel::CRITICAL: spdlog::critical(message); break;
            default:                    spdlog::info(message); break;
        }

        return;
    } catch (...) {
        // Fall back below.
    }

#endif

    std::lock_guard<std::mutex> lock(g_ideLoggerMutex);

    std::string line = nowTimestamp();
    line += " [";
    line += levelToString(level);
    line += "] ";
    line += message;
    line += "\n";

    if (g_ideLogFile.is_open()) {
        g_ideLogFile << line;
        g_ideLogFile.flush();
    }

    OutputDebugStringA(line.c_str());
}


