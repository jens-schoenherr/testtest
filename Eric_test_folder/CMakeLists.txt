cmake_minimum_required(VERSION 3.15)
project(Bin2bcd)

set(CMAKE_CXX_STANDARD 17)

add_executable(Bin2bcd_4 bin2bcd_4.cpp)
add_executable(Bin2bcd_tb bin2bcd_tb.cpp)

include_directories(Z:/Libs/ap_include)