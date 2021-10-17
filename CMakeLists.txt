cmake_minimum_required(VERSION 3.17 FATAL_ERROR)

project(
  cyrillic-encoder
  VERSION 0.0.1
  DESCRIPTION
    "A sample application which maps alphanumeric latin characters to cyrillic characters"
  HOMEPAGE_URL https://github.com/jwillikers/cyrillic-encoder
  LANGUAGES CXX)

include(CTest)
include(FetchContent)

FetchContent_Declare(
  cmake-scripts
  GIT_REPOSITORY https://github.com/StableCoder/cmake-scripts
  GIT_TAG 20.11)
FetchContent_GetProperties(cmake-scripts)
if(NOT cmake-scripts_POPULATED)
  FetchContent_Populate(cmake-scripts)
  list(APPEND CMAKE_MODULE_PATH ${cmake-scripts_SOURCE_DIR})
endif()

include(sanitizers)

set(FORMAT_CHECK_CMAKE
    yes
    CACHE BOOL "")
FetchContent_Declare(
  format
  GIT_REPOSITORY https://github.com/TheLartians/Format.cmake.git
  GIT_TAG v1.6)
FetchContent_MakeAvailable(format)

set(USE_CCACHE
    yes
    CACHE BOOL "")
FetchContent_Declare(
  ccache.cmake
  GIT_REPOSITORY https://github.com/TheLartians/Ccache.cmake.git
  GIT_TAG v1.2.1)
FetchContent_MakeAvailable(ccache.cmake)

set(BUILD_SHARED_LIBS
    yes
    CACHE BOOL "")
set(CMAKE_CXX_EXTENSIONS
    no
    CACHE BOOL "")
set(CMAKE_CXX_STANDARD
    20
    CACHE STRING "")
set(CMAKE_CXX_STANDARD_REQUIRED
    yes
    CACHE BOOL "")
set(CYRILLIC_ENCODER_GENERATED_INCLUDEDIR
    "${PROJECT_BINARY_DIR}/generated/include"
    CACHE PATH "The include directory for generated header files.")

# This is necessary for CMake to detect executables within the Python virtual
# environment for the project.
set(Python_FIND_VIRTUALENV
    STANDARD
    CACHE STRING "")

set(CMAKE_CXX_VISIBILITY_PRESET hidden)
set(CMAKE_WINDOWS_EXPORT_ALL_SYMBOLS no)
set(CMAKE_VISIBILITY_INLINES_HIDDEN 1)

add_subdirectory(src)
