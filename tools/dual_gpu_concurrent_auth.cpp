/* dual_gpu_concurrent_auth.cpp — enumerate + dual concurrent fill proof. */
#include "dual_gpu_concurrent_lane.hpp"
#include <thread>
#include <vector>

void ProbeFillPhys(VkPhysicalDevice pd, uint32_t idx, ProbePhys& o);
void ProbeEmitDevice(unsigned slot, const ProbePhys& o);

int main() {
    std::printf("PROBE=DUAL_GPU_CONCURRENT_AUTH_001\nPROMOTE=0\n");
    VkInstance inst = VK_NULL_HANDLE;
    if (ProbeMakeInstance(&inst) != VK_SUCCESS) {
        std::printf("ENUM=FAIL\nDUAL_GPU_PERFORMANCE_PASS=0\n");
        return 10;
    }
    uint32_t count = 0;
    vkEnumeratePhysicalDevices(inst, &count, nullptr);
    std::vector<VkPhysicalDevice> pds(count);
    vkEnumeratePhysicalDevices(inst, &count, pds.data());
    std::vector<ProbePhys> all(count);
    for (uint32_t i = 0; i < count; ++i) {
        ProbeFillPhys(pds[i], i, all[i]);
        ProbeEmitDevice(i, all[i]);
    }
    ProbePhys a{}, b{};
    if (!PickPropDiscrete(all, &a, &b)) {
        std::printf("PROP_PICK=FAIL\nDUAL_GPU_PERFORMANCE_PASS=0\n");
        vkDestroyInstance(inst, nullptr);
        return 11;
    }
    vkDestroyInstance(inst, nullptr);
    std::printf("PROP_PICK=PASS\nLANE0_UUID=%s\nLANE1_UUID=%s\n", a.uuidHex,
                b.uuidHex);
    LaneWork w0{a, "lane0"}, w1{b, "lane1"};
    std::thread t0([&] { LaneConcurrent(&w0); });
    std::thread t1([&] { LaneConcurrent(&w1); });
    t0.join();
    t1.join();
    std::printf("LANE0_NAME=%s\nLANE0_UUID=%s\nLANE0_VK_CREATE=%d\n"
                "LANE0_FILLS=%llu\nLANE0_OK=%d\n",
                w0.name, w0.uuid, w0.vkCreate,
                (unsigned long long)w0.fills, w0.ok);
    std::printf("LANE1_NAME=%s\nLANE1_UUID=%s\nLANE1_VK_CREATE=%d\n"
                "LANE1_FILLS=%llu\nLANE1_OK=%d\n",
                w1.name, w1.uuid, w1.vkCreate,
                (unsigned long long)w1.fills, w1.ok);
    const int both = w0.ok && w1.ok && w0.fills > 0 && w1.fills > 0;
    std::printf("CONCURRENT_FILL_BOTH=%s\nTOKEN_INFERENCE=NOT_PROVEN\n"
                "DUAL_GPU_PERFORMANCE_PASS=0\nWORK_PER_GPU=%s\n",
                both ? "PASS" : "FAIL",
                both ? "FILL_PROVEN" : "NOT_PROVEN");
    return both ? 0 : 12;
}
