#ifndef CPU_MONITOR_H
#define CPU_MONITOR_H

#ifdef __cplusplus
extern "C" {
#endif

// CPU monitoring functions
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

// Resource cleanup
void cleanup_cpu_monitoring();

#ifdef __cplusplus
}
#endif

#endif // CPU_MONITOR_H 