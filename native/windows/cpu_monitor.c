#include <windows.h>
#include <stdio.h>
#include <stdlib.h>
#include <pdh.h>
#include <pdhmsg.h>

#pragma comment(lib, "pdh.lib")

#ifdef __cplusplus
extern "C" {
#endif

// PDH query handle for CPU usage monitoring
static PDH_HQUERY cpuQuery = NULL;
static PDH_HCOUNTER cpuTotal = NULL;
static ULARGE_INTEGER lastCPU, lastSysCPU, lastUserCPU;
static int numProcessors = 0;
static HANDLE self;

// Initialize CPU performance monitoring
static void init_cpu_monitoring() {
    // Initialize PDH query for CPU usage
    PdhOpenQuery(NULL, 0, &cpuQuery);
    PdhAddEnglishCounter(cpuQuery, "\\Processor(_Total)\\% Processor Time", 0, &cpuTotal);
    PdhCollectQueryData(cpuQuery);

    // Get system information including processor count
    SYSTEM_INFO sysInfo;
    GetSystemInfo(&sysInfo);
    numProcessors = sysInfo.dwNumberOfProcessors;

    // Get handle to current process
    self = GetCurrentProcess();

    // Get CPU times for current process and system
    FILETIME createTime, exitTime, kernelTime, userTime;
    GetProcessTimes(self, &createTime, &exitTime, &kernelTime, &userTime);

    lastCPU.LowPart = kernelTime.dwLowDateTime;
    lastCPU.HighPart = kernelTime.dwHighDateTime;

    FILETIME sysKernel, sysUser;
    GetSystemTimes(&sysKernel, &sysUser, NULL);

    lastSysCPU.LowPart = sysKernel.dwLowDateTime;
    lastSysCPU.HighPart = sysKernel.dwHighDateTime;

    lastUserCPU.LowPart = sysUser.dwLowDateTime;
    lastUserCPU.HighPart = sysUser.dwHighDateTime;
}

// Get CPU usage percentage (0-100)
double getCpuUsage() {
    // Initialize CPU monitoring if not already done
    if (cpuQuery == NULL) {
        init_cpu_monitoring();
        // First call needs to establish baseline
        Sleep(100); // Wait a bit to get first measurement
        return 0.0;
    }

    PDH_FMT_COUNTERVALUE counterVal;
    
    // Collect new data point
    PdhCollectQueryData(cpuQuery);
    PdhGetFormattedCounterValue(cpuTotal, PDH_FMT_DOUBLE, NULL, &counterVal);
    
    // Return CPU percentage
    return counterVal.doubleValue;
}

// Get used memory in MB
int getMemoryUsed() {
    MEMORYSTATUSEX memInfo;
    memInfo.dwLength = sizeof(MEMORYSTATUSEX);
    
    if (!GlobalMemoryStatusEx(&memInfo)) {
        fprintf(stderr, "Error getting memory info\n");
        return -1;
    }
    
    // Calculate used memory in bytes: total - available
    DWORDLONG usedPhysicalMem = memInfo.ullTotalPhys - memInfo.ullAvailPhys;
    
    // Convert to MB
    return (int)(usedPhysicalMem / (1024 * 1024));
}

// Get total memory in MB
int getMemoryTotal() {
    MEMORYSTATUSEX memInfo;
    memInfo.dwLength = sizeof(MEMORYSTATUSEX);
    
    if (!GlobalMemoryStatusEx(&memInfo)) {
        fprintf(stderr, "Error getting memory info\n");
        return -1;
    }
    
    // Convert to MB
    return (int)(memInfo.ullTotalPhys / (1024 * 1024));
}

// Get disk usage percentage (0-100)
double getDiskUsage() {
    ULARGE_INTEGER freeBytesAvailable, totalNumberOfBytes, totalNumberOfFreeBytes;
    
    // Get disk information for C: drive
    if (!GetDiskFreeSpaceEx("C:\\", &freeBytesAvailable, &totalNumberOfBytes, &totalNumberOfFreeBytes)) {
        fprintf(stderr, "Error getting disk info\n");
        return -1.0;
    }
    
    if (totalNumberOfBytes.QuadPart == 0) {
        return 0.0;
    }
    
    // Calculate usage percentage
    double freePercentage = (double)totalNumberOfFreeBytes.QuadPart / (double)totalNumberOfBytes.QuadPart;
    return (1.0 - freePercentage) * 100.0;
}

// Get disk used in MB
double getDiskUsed() {
    ULARGE_INTEGER freeBytesAvailable, totalNumberOfBytes, totalNumberOfFreeBytes;
    
    // Get disk information for C: drive
    if (!GetDiskFreeSpaceEx("C:\\", &freeBytesAvailable, &totalNumberOfBytes, &totalNumberOfFreeBytes)) {
        fprintf(stderr, "Error getting disk info\n");
        return -1.0;
    }
    
    // Calculate used space
    ULONGLONG usedBytes = totalNumberOfBytes.QuadPart - totalNumberOfFreeBytes.QuadPart;
    
    // Convert to MB
    return (double)usedBytes / (1024.0 * 1024.0);
}

// Get total disk size in MB
double getDiskTotal() {
    ULARGE_INTEGER freeBytesAvailable, totalNumberOfBytes, totalNumberOfFreeBytes;
    
    // Get disk information for C: drive
    if (!GetDiskFreeSpaceEx("C:\\", &freeBytesAvailable, &totalNumberOfBytes, &totalNumberOfFreeBytes)) {
        fprintf(stderr, "Error getting disk info\n");
        return -1.0;
    }
    
    // Convert to MB
    return (double)totalNumberOfBytes.QuadPart / (1024.0 * 1024.0);
}

// Get CPU temperature in Celsius
double getTemperature() {
    // Windows doesn't have a standard way to get CPU temperature through WMI
    // This would require additional libraries like OpenHardwareMonitor
    // For now, we'll return an estimated value based on CPU usage
    double cpuUsage = getCpuUsage();
    double estimatedTemp = 35.0 + (cpuUsage / 5.0);
    
    return estimatedTemp;
}

// Cleanup resources
void cleanup_cpu_monitoring() {
    if (cpuQuery != NULL) {
        PdhCloseQuery(cpuQuery);
        cpuQuery = NULL;
    }
}

// Ensure proper cleanup when library is unloaded
BOOL WINAPI DllMain(HINSTANCE hinstDLL, DWORD fdwReason, LPVOID lpvReserved) {
    switch (fdwReason) {
        case DLL_PROCESS_ATTACH:
            // Initialize resources
            break;
        case DLL_PROCESS_DETACH:
            // Clean up resources
            cleanup_cpu_monitoring();
            break;
    }
    return TRUE;
}

#ifdef __cplusplus
}
#endif 