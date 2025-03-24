cmake_minimum_required(VERSION 3.10)

project(native_cpu_lib)

if(WIN32)
    add_definitions(-D_WIN32_WINNT=0x0600)
    add_definitions(-DWIN32_LEAN_AND_MEAN)
endif()

add_library(native_cpu_lib SHARED cpu_usage.cpp)

set_target_properties(native_cpu_lib PROPERTIES 
    OUTPUT_NAME "native_cpu_lib"
    WINDOWS_EXPORT_ALL_SYMBOLS ON
    PREFIX ""
)

# Add WMI and COM libraries
target_link_libraries(native_cpu_lib PRIVATE 
    kernel32
    pdh          # Performance Data Helper
    advapi32     # For Registry functions
)
