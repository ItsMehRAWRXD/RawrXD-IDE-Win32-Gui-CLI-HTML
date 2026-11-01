#include <windows.h>
#include <string>
#include <vector>
#include <mutex>

namespace RawrXD::IDE {

struct TerminalProfile {
    std::string name;
    std::string shellPath;
    std::vector<std::string> args;
};

class TerminalProfileManager {
public:
    // AUDIT_002_OPENISH_OTHER_DRAIN_015:
    // Prior: ctor invent PowerShell/cmd/Git-Bash profiles as terminal-profile
    // product ready PASS without validated shell path / product wire (fake-ready).
    // Now: FEATURE_FICTION=1 FAIL_CLOSED — no invent PASS.
    // Orphan TU (not tip link). PROMOTE=0 TIP_CLIMB=HOLD CERTIFIED=0 PERFECT=0 NOT_RUN!=PASS
    TerminalProfileManager() {
        // Was: invent 3 shell profiles ready PASS.
        OutputDebugStringA(
            "[TerminalProfiles] FEATURE_FICTION=1 FAIL_CLOSED ctor "
            "(no invent terminal-profile ready PASS)\n");
    }

    int count() const {
        std::lock_guard<std::mutex> lock(mu_);
        return static_cast<int>(profiles_.size());
    }

    bool addProfile(const TerminalProfile& p) {
        (void)p;
        std::lock_guard<std::mutex> lock(mu_);
        // Was: invent push_back ready PASS.
        return false;
    }

    const TerminalProfile* getByIndex(int idx) const {
        std::lock_guard<std::mutex> lock(mu_);
        if (idx < 0 || idx >= static_cast<int>(profiles_.size())) return nullptr;
        return &profiles_[idx];
    }

private:
    mutable std::mutex mu_;
    std::vector<TerminalProfile> profiles_;
};

static TerminalProfileManager g_termProfiles;

} // namespace RawrXD::IDE

extern "C" {

int RawrXD_IDE_TerminalProfileCount() {
    return RawrXD::IDE::g_termProfiles.count();
}

bool RawrXD_IDE_AddTerminalProfile(const char* name, const char* shellPath) {
    if (!name || !shellPath) return false;
    RawrXD::IDE::TerminalProfile p;
    p.name = name;
    p.shellPath = shellPath;
    return RawrXD::IDE::g_termProfiles.addProfile(p);
}

}
