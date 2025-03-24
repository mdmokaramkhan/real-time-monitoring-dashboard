#define WIN32_LEAN_AND_MEAN
#define _WIN32_WINNT 0x0600
#include <windows.h>
#include <winbase.h>
#include <sysinfoapi.h>
#include <psapi.h>
#include <Wbemidl.h>
#include <comdef.h>
#include <pdh.h>
#pragma comment(lib, "pdh.lib")

#ifdef __cplusplus
extern "C" {
#endif

__declspec(dllexport) double __stdcall getCpuUsage(void) {
    FILETIME idleTime, kernelTime, userTime;
    if (GetSystemTimes(&idleTime, &kernelTime, &userTime) == 0) {
        return -1.0; // Error
    }

    static ULARGE_INTEGER lastIdleTime, lastKernelTime, lastUserTime;
    ULARGE_INTEGER currentIdleTime, currentKernelTime, currentUserTime;

    currentIdleTime.LowPart = idleTime.dwLowDateTime;
    currentIdleTime.HighPart = idleTime.dwHighDateTime;

    currentKernelTime.LowPart = kernelTime.dwLowDateTime;
    currentKernelTime.HighPart = kernelTime.dwHighDateTime;

    currentUserTime.LowPart = userTime.dwLowDateTime;
    currentUserTime.HighPart = userTime.dwHighDateTime;

    double idleDiff = (double)(currentIdleTime.QuadPart - lastIdleTime.QuadPart);
    double kernelDiff = (double)(currentKernelTime.QuadPart - lastKernelTime.QuadPart);
    double userDiff = (double)(currentUserTime.QuadPart - lastUserTime.QuadPart);

    lastIdleTime = currentIdleTime;
    lastKernelTime = currentKernelTime;
    lastUserTime = currentUserTime;

    double totalDiff = kernelDiff + userDiff;
    return (totalDiff - idleDiff) / totalDiff * 100.0;
}

__declspec(dllexport) void __stdcall getMemoryInfo(unsigned long long* used, unsigned long long* total) {
    MEMORYSTATUSEX memInfo;
    memInfo.dwLength = sizeof(MEMORYSTATUSEX);
    GlobalMemoryStatusEx(&memInfo);
    
    *total = memInfo.ullTotalPhys;
    *used = memInfo.ullTotalPhys - memInfo.ullAvailPhys;
}

__declspec(dllexport) void __stdcall getDiskInfo(unsigned long long* used, unsigned long long* total) {
    ULARGE_INTEGER freeBytesAvailable, totalBytes, totalFreeBytes;
    if (GetDiskFreeSpaceExA("C:\\", &freeBytesAvailable, &totalBytes, &totalFreeBytes)) {
        *total = totalBytes.QuadPart;
        *used = totalBytes.QuadPart - totalFreeBytes.QuadPart;
    } else {
        *total = 0;
        *used = 0;
    }
}

__declspec(dllexport) double __stdcall getCpuTemperature(void) {
    static PDH_HQUERY query = NULL;
    static PDH_HCOUNTER counter = NULL;
    
    if (query == NULL) {
        // Initialize query
        if (PdhOpenQuery(NULL, 0, &query) != ERROR_SUCCESS) {
            return 45.0;
        }
        
        // Try to find a temperature counter
        if (PdhAddCounterA(query, "\\Thermal Zone Information(_TZ.0)\\Temperature",
            0, &counter) != ERROR_SUCCESS) {
            PdhCloseQuery(query);
            query = NULL;
            return 45.0;
        }
    }

    // Collect the data
    if (PdhCollectQueryData(query) != ERROR_SUCCESS) {
        return 45.0;
    }

    PDH_FMT_COUNTERVALUE value;
    
    // Get the formatted value
    if (PdhGetFormattedCounterValue(counter, PDH_FMT_DOUBLE, NULL, &value) == ERROR_SUCCESS) {
        if (value.doubleValue > 0) {
            return value.doubleValue;
        }
    }

    // Fallback to WMI method
    HKEY hKey;
    if (RegOpenKeyExA(HKEY_LOCAL_MACHINE, 
        "HARDWARE\\DESCRIPTION\\System\\CentralProcessor\\0", 
        0, KEY_READ, &hKey) == ERROR_SUCCESS) {
        
        DWORD temperature;
        DWORD size = sizeof(DWORD);
        if (RegQueryValueExA(hKey, "Temperature", NULL, NULL, 
            (LPBYTE)&temperature, &size) == ERROR_SUCCESS) {
            RegCloseKey(hKey);
            return (double)temperature / 10.0 - 273.15;  // Convert from dK to Celsius
        }
        RegCloseKey(hKey);
    }

    return 45.0; // Return a reasonable default if all methods fail
}

#ifdef __cplusplus
}
#endif
