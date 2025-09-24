# The Flutter tooling requires that developers have CMake 3.10 or later
# installed. You should not increase this version, as doing so will cause
# the plugin to fail to compile for some customers of the plugin.
cmake_minimum_required(VERSION 3.10)

project(hydrogen_flutter_library VERSION 0.0.1 LANGUAGES C)

add_library(hydrogen_flutter SHARED
  "libhydrogen/hydrogen.c"
)

set_target_properties(hydrogen_flutter PROPERTIES
  PUBLIC_HEADER libhydrogen/hydrogen.h
  OUTPUT_NAME "hydrogen_flutter"
)

target_compile_definitions(hydrogen_flutter PUBLIC DART_SHARED_LIB)
target_compile_options(hydrogen_flutter PUBLIC)