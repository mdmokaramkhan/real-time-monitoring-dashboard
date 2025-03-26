#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include <sys/statvfs.h>
#include <sys/sysinfo.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>

#ifdef __cplusplus
extern "C" {
#endif

// Last CPU values for calculating deltas
static unsigned long long prev_idle = 0;
static unsigned long long prev_total = 0;

// Helper function to read CPU stats from /proc/stat
static int read_cpu_stats(unsigned long long *idle_time, unsigned long long *total_time) {
    FILE *fp = fopen("/proc/stat", "r");
    if (fp == NULL) {
        perror("Error opening /proc/stat");
        return -1;
    }
    
    char buffer[1024];
    if (fgets(buffer, sizeof(buffer), fp) == NULL) {
        fclose(fp);
        return -1;
    }
    
    fclose(fp);
    
    unsigned long long user, nice, system, idle, iowait, irq, softirq, steal;
    if (sscanf(buffer, "cpu %llu %llu %llu %llu %llu %llu %llu %llu", 
               &user, &nice, &system, &idle, &iowait, &irq, &softirq, &steal) < 8) {
        return -1;
    }
    
    // Idle time is the sum of idle and iowait
    *idle_time = idle + iowait;
    
    // Total time is the sum of all CPU times
    *total_time = user + nice + system + idle + iowait + irq + softirq + steal;
    
    return 0;
}

// Get CPU usage percentage (0-100)
double getCpuUsage() {
    unsigned long long idle, total;
    
    if (read_cpu_stats(&idle, &total) < 0) {
        return -1.0;
    }
    
    // First call, just save values and return 0
    if (prev_total == 0) {
        prev_idle = idle;
        prev_total = total;
        return 0.0;
    }
    
    // Calculate deltas from previous call
    unsigned long long idle_delta = idle - prev_idle;
    unsigned long long total_delta = total - prev_total;
    
    // Save current values for next call
    prev_idle = idle;
    prev_total = total;
    
    if (total_delta == 0) {
        return 0.0;
    }
    
    // Calculate CPU usage percentage
    double cpu_usage = 100.0 * (1.0 - ((double)idle_delta / (double)total_delta));
    return cpu_usage;
}

// Get used memory in MB
int getMemoryUsed() {
    struct sysinfo info;
    
    if (sysinfo(&info) != 0) {
        perror("Error getting memory info");
        return -1;
    }
    
    // Calculate used memory: total - free
    unsigned long long used_bytes = (info.totalram - info.freeram) * info.mem_unit;
    
    // Convert to MB
    return (int)(used_bytes / (1024 * 1024));
}

// Get total memory in MB
int getMemoryTotal() {
    struct sysinfo info;
    
    if (sysinfo(&info) != 0) {
        perror("Error getting memory info");
        return -1;
    }
    
    // Convert to MB
    return (int)((info.totalram * info.mem_unit) / (1024 * 1024));
}

// Get disk usage percentage (0-100)
double getDiskUsage() {
    struct statvfs fs_stats;
    
    if (statvfs("/", &fs_stats) != 0) {
        perror("Error getting disk info");
        return -1.0;
    }
    
    // Calculate total and free space
    double total = (double)fs_stats.f_blocks * fs_stats.f_frsize;
    double free = (double)fs_stats.f_bfree * fs_stats.f_frsize;
    
    if (total == 0) {
        return 0.0;
    }
    
    // Calculate percentage used
    return ((total - free) / total) * 100.0;
}

// Get disk used in MB
double getDiskUsed() {
    struct statvfs fs_stats;
    
    if (statvfs("/", &fs_stats) != 0) {
        perror("Error getting disk info");
        return -1.0;
    }
    
    // Calculate used space
    double used = (double)(fs_stats.f_blocks - fs_stats.f_bfree) * fs_stats.f_frsize;
    
    // Convert to MB
    return used / (1024.0 * 1024.0);
}

// Get total disk size in MB
double getDiskTotal() {
    struct statvfs fs_stats;
    
    if (statvfs("/", &fs_stats) != 0) {
        perror("Error getting disk info");
        return -1.0;
    }
    
    // Calculate total space
    double total = (double)fs_stats.f_blocks * fs_stats.f_frsize;
    
    // Convert to MB
    return total / (1024.0 * 1024.0);
}

// Get CPU temperature in Celsius
double getTemperature() {
    // Try to read temperature from thermal zone 0
    int fd = open("/sys/class/thermal/thermal_zone0/temp", O_RDONLY);
    if (fd < 0) {
        // Try alternate location
        fd = open("/sys/devices/virtual/thermal/thermal_zone0/temp", O_RDONLY);
        if (fd < 0) {
            return -1.0; // Temperature not available
        }
    }
    
    char buffer[20];
    ssize_t bytes_read = read(fd, buffer, sizeof(buffer) - 1);
    close(fd);
    
    if (bytes_read <= 0) {
        return -1.0;
    }
    
    buffer[bytes_read] = '\0';
    
    // Temperature is reported in millidegrees Celsius
    long temp_millicelsius = strtol(buffer, NULL, 10);
    
    // Convert to Celsius
    return (double)temp_millicelsius / 1000.0;
}

#ifdef __cplusplus
}
#endif 