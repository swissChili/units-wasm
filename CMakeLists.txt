cmake_minimum_required(VERSION 3.13)

project(units C)

file(GLOB SOURCES *.c *.h)
add_executable(units-host ${SOURCES})
