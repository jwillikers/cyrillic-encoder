cmake_minimum_required(VERSION 3.27)

project(
  cyrillic-encoder
  VERSION 0.0.1
  DESCRIPTION
    "A sample application which maps alphanumeric latin characters to cyrillic characters"
  HOMEPAGE_URL https://github.com/jwillikers/cyrillic-encoder
  LANGUAGES CXX)

set(BUILD_SHARED_LIBS
    no
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

get_property(isMultiConfig GLOBAL PROPERTY GENERATOR_IS_MULTI_CONFIG)
if(NOT isMultiConfig)
  set(allowedBuildTypes Debug MinSizeRel Release RelWithDebInfo)
  set_property(CACHE CMAKE_BUILD_TYPE PROPERTY STRINGS "${allowedBuildTypes}")
  if(NOT CMAKE_BUILD_TYPE)
    set(CMAKE_BUILD_TYPE
        RelWithDebInfo
        CACHE STRING "" FORCE)
  elseif(NOT CMAKE_BUILD_TYPE IN_LIST allowedBuildTypes)
    message(FATAL_ERROR "Unknown build type: ${CMAKE_BUILD_TYPE}")
  endif()
  string(TOUPPER ${CMAKE_BUILD_TYPE} _BUILD_TYPE_UPPER)
endif()

include(CheckIPOSupported)
check_ipo_supported(RESULT result OUTPUT output)
if(result)
  set(CMAKE_INTERPROCEDURAL_OPTIMIZATION
      yes
      CACHE BOOL "")
else()
  message(SEND_ERROR "IPO is not supported: ${output}")
endif()

include(CTest)
include(FetchContent)

FetchContent_Declare(
  cmake-scripts
  GIT_REPOSITORY https://github.com/StableCoder/cmake-scripts
  GIT_TAG 23.06)
FetchContent_GetProperties(cmake-scripts)
if(NOT cmake-scripts_POPULATED)
  FetchContent_Populate(cmake-scripts)
  list(APPEND CMAKE_MODULE_PATH ${cmake-scripts_SOURCE_DIR})
endif()

include(sanitizers)
include(tools)

set(FORMAT_CHECK_CMAKE
    yes
    CACHE BOOL "")
FetchContent_Declare(
  format
  GIT_REPOSITORY https://github.com/TheLartians/Format.cmake.git
  GIT_TAG v1.7.3)
FetchContent_MakeAvailable(format)

set(USE_CCACHE
    yes
    CACHE BOOL "")
FetchContent_Declare(
  ccache.cmake
  GIT_REPOSITORY https://github.com/TheLartians/Ccache.cmake.git
  GIT_TAG v1.2.4)
FetchContent_MakeAvailable(ccache.cmake)

add_subdirectory(src)
