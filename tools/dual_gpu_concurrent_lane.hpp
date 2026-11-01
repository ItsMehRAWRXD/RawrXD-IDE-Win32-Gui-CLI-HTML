/* dual_gpu_concurrent_lane.hpp — lane work types for concurrent auth. */
#pragma once
#include "dual_vk_probe_util.hpp"
#include <vector>

struct LaneWork {
    ProbePhys phys{};
    const char* tag = "";
    uint64_t fills = 0;
    int ok = 0;
    int vkCreate = -1;
    char name[128]{};
    char uuid[65]{};
};

int LaneConcurrent(LaneWork* L);
int PickPropDiscrete(const std::vector<ProbePhys>& all, ProbePhys* a,
                     ProbePhys* b);
