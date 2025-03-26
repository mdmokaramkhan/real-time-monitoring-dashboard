#ifndef CPU_MONITOR_H
#define CPU_MONITOR_H

#ifdef __cplusplus
extern "C" {
#endif

// CPU monitoring functions
void init_cpu_monitoring();
double getCpuUsage();

// Memory monitoring functions
int getMemoryUsed();
int getMemoryTotal();

// Disk monitoring functions
double getDiskUsage();
double getDiskUsed();
double getDiskTotal();

// Temperature monitoring
double getTemperature();

// System information functions
const char* getCpuModel();
const char* getOsVersion();
const char* getHostname();
const char* getKernelVersion();
int getCpuCoreCount();

#ifdef __cplusplus
}
#endif

#endif // CPU_MONITOR_H 