cmake_minimum_required(VERSION 3.29)
set(CMAKE_POLICY_DEFAULT_CMP0168 NEW)

project(
  cyrillic-encoder
  VERSION 0.0.1
  DESCRIPTION
    "A sample application which maps alphanumeric latin characters to cyrillic characters"
  HOMEPAGE_URL https://github.com/jwillikers/cyrillic-encoder
  LANGUAGES CXX)

set(CMAKE_LINK_LIBRARIES_ONLY_TARGETS yes)

set(CMAKE_CXX_VISIBILITY_PRESET hidden)
set(CMAKE_WINDOWS_EXPORT_ALL_SYMBOLS no)
set(CMAKE_VISIBILITY_INLINES_HIDDEN 1)

if(DEFINED CMAKE_CXX_STANDARD)
    if(CMAKE_CXX_STANDARD EQUAL 98 OR CMAKE_CXX_STANDARD LESS 20)
        message(FATAL_ERROR "This project requires at least C++20")
    endif()
else()
    set(CMAKE_CXX_STANDARD 20)
endif()
set(CMAKE_CXX_STANDARD_REQUIRED yes)
if(NOT DEFINED CMAKE_CXX_EXTENSIONS)
    set(CMAKE_CXX_EXTENSIONS no)
endif()

set(BUILD_SHARED_LIBS
    no
    CACHE BOOL "")
set(CMAKE_COMPILE_WARNING_AS_ERROR
    ${PROJECT_IS_TOP_LEVEL}
    CACHE BOOL "Treat compiler warnings as errors"
)

set(CMAKE_MSVC_RUNTIME_LIBRARY
    "$<$<CONFIG:Debug>:MultiThreadedDebugDLL>"
    CACHE STRING ""
)
set(CMAKE_OPTIMIZE_DEPENDENCIES
    yes
    CACHE BOOL ""
)
set(CYRILLIC_ENCODER_GENERATED_INCLUDEDIR
    "${PROJECT_BINARY_DIR}/generated/include"
    CACHE PATH "The include directory for generated header files.")

# This is necessary for CMake to detect executables within the Python virtual
# environment for the project.
set(Python_FIND_VIRTUALENV
    STANDARD
    CACHE STRING "")

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

set(CYRILLIC_ENCODER_ENABLE_TESTING ${PROJECT_IS_TOP_LEVEL} CACHE BOOL "")
set(CYRILLIC_ENCODER_ENABLE_FETCHCONTENT ${PROJECT_IS_TOP_LEVEL} CACHE BOOL "")

include(CTest)
include(GNUInstallDirs)

if(CYRILLIC_ENCODER_ENABLE_FETCHCONTENT)
  include(dependencies.cmake)
endif()

add_subdirectory(src)
