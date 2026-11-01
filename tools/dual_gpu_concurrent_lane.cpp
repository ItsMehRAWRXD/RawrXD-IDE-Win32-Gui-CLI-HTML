/* dual_gpu_concurrent_lane.cpp — proprietary pick + fill lane (≤99). */
#include "dual_gpu_concurrent_lane.hpp"
#include <vector>

VkResult ProbeCreateComputeDeviceN(VkPhysicalDevice pd, uint32_t fam,
                                   uint32_t nQ, VkDevice* out,
                                   const char* tag);
int ProbeFindByUuid(VkInstance inst, const char* uuid, const char* luidOpt,
                    ProbePhys* filled);

static bool IsWarp(const char* n) {
    return ProbeNameHas(n, "Direct3D12") || ProbeNameHas(n, "Dozen") ||
           ProbeNameHas(n, "llvmpipe");
}

int PickPropDiscrete(const std::vector<ProbePhys>& all, ProbePhys* a,
                     ProbePhys* b) {
    int ia = -1, ib = -1;
    for (int i = 0; i < (int)all.size(); ++i) {
        if (!all[i].discrete || all[i].computeFamily == UINT32_MAX) continue;
        if (IsWarp(all[i].props.deviceName)) continue;
        if (ProbeNameHas(all[i].props.deviceName, "R9700")) ia = i;
        if (ProbeNameHas(all[i].props.deviceName, "7800")) ib = i;
    }
    if (ia < 0 || ib < 0 || ia == ib) return 0;
    *a = all[ia];
    *b = all[ib];
    return 1;
}

int LaneConcurrent(LaneWork* L) {
    VkInstance inst = VK_NULL_HANDLE;
    if (ProbeMakeInstance(&inst) != VK_SUCCESS) return 1;
    ProbePhys live{};
    const char* luid =
        L->phys.idProps.deviceLUIDValid ? L->phys.luidHex : nullptr;
    if (!ProbeFindByUuid(inst, L->phys.uuidHex, luid, &live)) {
        vkDestroyInstance(inst, nullptr);
        return 2;
    }
    std::snprintf(L->name, sizeof(L->name), "%s", live.props.deviceName);
    std::snprintf(L->uuid, sizeof(L->uuid), "%s", live.uuidHex);
    VkDevice dev = VK_NULL_HANDLE;
    VkResult r = ProbeCreateComputeDeviceN(live.pd, live.computeFamily, 1u,
                                           &dev, L->tag);
    L->vkCreate = (int)r;
    if (r != VK_SUCCESS || !dev) {
        vkDestroyInstance(inst, nullptr);
        return 3;
    }
    VkQueue q = VK_NULL_HANDLE;
    vkGetDeviceQueue(dev, live.computeFamily, 0, &q);
    VkCommandPoolCreateInfo pci{VK_STRUCTURE_TYPE_COMMAND_POOL_CREATE_INFO};
    pci.queueFamilyIndex = live.computeFamily;
    pci.flags = VK_COMMAND_POOL_CREATE_RESET_COMMAND_BUFFER_BIT;
    VkCommandPool pool = VK_NULL_HANDLE;
    if (vkCreateCommandPool(dev, &pci, nullptr, &pool) != VK_SUCCESS) {
        vkDestroyDevice(dev, nullptr);
        vkDestroyInstance(inst, nullptr);
        return 4;
    }
    VkCommandBufferAllocateInfo ai{
        VK_STRUCTURE_TYPE_COMMAND_BUFFER_ALLOCATE_INFO};
    ai.commandPool = pool;
    ai.level = VK_COMMAND_BUFFER_LEVEL_PRIMARY;
    ai.commandBufferCount = 1;
    VkCommandBuffer cmd = VK_NULL_HANDLE;
    vkAllocateCommandBuffers(dev, &ai, &cmd);
    VkBufferCreateInfo bci{VK_STRUCTURE_TYPE_BUFFER_CREATE_INFO};
    bci.size = 4096;
    bci.usage = VK_BUFFER_USAGE_TRANSFER_DST_BIT;
    VkBuffer buf = VK_NULL_HANDLE;
    vkCreateBuffer(dev, &bci, nullptr, &buf);
    VkMemoryRequirements req{};
    vkGetBufferMemoryRequirements(dev, buf, &req);
    VkPhysicalDeviceMemoryProperties mp{};
    vkGetPhysicalDeviceMemoryProperties(live.pd, &mp);
    uint32_t mi = UINT32_MAX;
    for (uint32_t i = 0; i < mp.memoryTypeCount; ++i) {
        if ((req.memoryTypeBits & (1u << i)) &&
            (mp.memoryTypes[i].propertyFlags &
             VK_MEMORY_PROPERTY_DEVICE_LOCAL_BIT)) {
            mi = i;
            break;
        }
    }
    VkDeviceMemory mem = VK_NULL_HANDLE;
    VkMemoryAllocateInfo mai{VK_STRUCTURE_TYPE_MEMORY_ALLOCATE_INFO};
    mai.allocationSize = req.size;
    mai.memoryTypeIndex = mi;
    if (mi == UINT32_MAX ||
        vkAllocateMemory(dev, &mai, nullptr, &mem) != VK_SUCCESS) {
        if (buf) vkDestroyBuffer(dev, buf, nullptr);
        vkDestroyCommandPool(dev, pool, nullptr);
        vkDestroyDevice(dev, nullptr);
        vkDestroyInstance(inst, nullptr);
        return 5;
    }
    vkBindBufferMemory(dev, buf, mem, 0);
    VkFence fence = VK_NULL_HANDLE;
    VkFenceCreateInfo fi{VK_STRUCTURE_TYPE_FENCE_CREATE_INFO};
    vkCreateFence(dev, &fi, nullptr, &fence);
    const uint32_t reps = 8;
    for (uint32_t i = 0; i < reps; ++i) {
        vkResetFences(dev, 1, &fence);
        vkResetCommandBuffer(cmd, 0);
        VkCommandBufferBeginInfo bi{
            VK_STRUCTURE_TYPE_COMMAND_BUFFER_BEGIN_INFO};
        bi.flags = VK_COMMAND_BUFFER_USAGE_ONE_TIME_SUBMIT_BIT;
        vkBeginCommandBuffer(cmd, &bi);
        vkCmdFillBuffer(cmd, buf, 0, 4096,
                        0xA5000000u + i + (uint32_t)(unsigned char)L->tag[0]);
        vkEndCommandBuffer(cmd);
        VkSubmitInfo si{VK_STRUCTURE_TYPE_SUBMIT_INFO};
        si.commandBufferCount = 1;
        si.pCommandBuffers = &cmd;
        if (vkQueueSubmit(q, 1, &si, fence) != VK_SUCCESS) break;
        if (vkWaitForFences(dev, 1, &fence, VK_TRUE, 2000000000ull) !=
            VK_SUCCESS)
            break;
        ++L->fills;
    }
    L->ok = (L->fills == reps) ? 1 : 0;
    vkDestroyFence(dev, fence, nullptr);
    vkDestroyBuffer(dev, buf, nullptr);
    vkFreeMemory(dev, mem, nullptr);
    vkDestroyCommandPool(dev, pool, nullptr);
    vkDestroyDevice(dev, nullptr);
    vkDestroyInstance(inst, nullptr);
    return L->ok ? 0 : 6;
}
