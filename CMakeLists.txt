cmake_minimum_required(VERSION 3.29)
set(CMAKE_POLICY_DEFAULT_CMP0168 NEW)

project(
    cyrillic-encoder
    VERSION 0.0.1
    DESCRIPTION "A sample application which maps alphanumeric latin characters to cyrillic characters"
    HOMEPAGE_URL https://github.com/jwillikers/cyrillic-encoder
    LANGUAGES CXX)

set(CMAKE_EXPORT_COMPILE_COMMANDS yes)
set(CMAKE_LINK_LIBRARIES_ONLY_TARGETS yes)

if(PROJECT_IS_TOP_LEVEL AND CMAKE_EXPORT_COMPILE_COMMANDS)
    list(APPEND CMAKE_C_STANDARD_INCLUDE_DIRECTORIES ${CMAKE_C_IMPLICIT_INCLUDE_DIRECTORIES})
    list(REMOVE_DUPLICATES CMAKE_C_STANDARD_INCLUDE_DIRECTORIES)
    list(APPEND CMAKE_CXX_STANDARD_INCLUDE_DIRECTORIES ${CMAKE_CXX_IMPLICIT_INCLUDE_DIRECTORIES})
    list(REMOVE_DUPLICATES CMAKE_CXX_STANDARD_INCLUDE_DIRECTORIES)
endif()

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
    yes
    CACHE BOOL "")
set(CMAKE_COMPILE_WARNING_AS_ERROR
    ${PROJECT_IS_TOP_LEVEL}
    CACHE BOOL "Treat compiler warnings as errors")

set(CMAKE_MSVC_RUNTIME_LIBRARY
    "$<$<CONFIG:Debug>:MultiThreadedDebugDLL>"
    CACHE STRING "")
set(CMAKE_OPTIMIZE_DEPENDENCIES
    yes
    CACHE BOOL "")
set(CYRILLIC_ENCODER_GENERATED_INCLUDEDIR
    "${PROJECT_BINARY_DIR}/generated/include"
    CACHE PATH "The include directory for generated header files.")

# This is necessary for CMake to detect executables within the Python virtual environment for the project.
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

include(CheckCXXCompilerFlag)
check_cxx_compiler_flag("-gsplit-dwarf" HAVE_SPLIT_DWARF)
if(HAVE_SPLIT_DWARF)
    add_compile_options("$<$<CONFIG:Debug,RelWithDebInfo>:-gsplit-dwarf>")
endif()

option(CYRILLIC_ENCODER_ENABLE_CLANG_TIDY "Enable Clang-Tidy" ${PROJECT_IS_TOP_LEVEL})
option(CYRILLIC_ENCODER_ENABLE_FETCHCONTENT "Enable fetching external dependencies" ${PROJECT_IS_TOP_LEVEL})
option(CYRILLIC_ENCODER_ENABLE_IWYU "Enable include-what-you-use" ${PROJECT_IS_TOP_LEVEL})
option(CYRILLIC_ENCODER_ENABLE_TESTING "Build tests" ${PROJECT_IS_TOP_LEVEL})

if(CMAKE_CXX_COMPILER_ID MATCHES "Clang")
    option(CYRILLIC_ENCODER_ENABLE_COVERAGE_CLANG "Enable Clang source-based coverage" ${PROJECT_IS_TOP_LEVEL})
else()
    option(CYRILLIC_ENCODER_ENABLE_COVERAGE_CLANG "Enable Clang source-based coverage" no)
    mark_as_advanced(CYRILLIC_ENCODER_ENABLE_COVERAGE_CLANG)
endif()

if(NOT PROJECT_IS_TOP_LEVEL)
    mark_as_advanced(CYRILLIC_ENCODER_ENABLE_CLANG_TIDY CYRILLIC_ENCODER_ENABLE_COVERAGE_CLANG
                     CYRILLIC_ENCODER_ENABLE_FETCHCONTENT CYRILLIC_ENCODER_ENABLE_IWYU CYRILLIC_ENCODER_ENABLE_TESTING)
endif()

if(CYRILLIC_ENCODER_ENABLE_CLANG_TIDY)
    find_program(CLANG_TIDY_EXECUTABLE clang-tidy REQUIRED)
    set(CMAKE_C_CLANG_TIDY ${CLANG_TIDY_EXECUTABLE} -p ${CMAKE_BINARY_DIR})
    set(CMAKE_CXX_CLANG_TIDY ${CLANG_TIDY_EXECUTABLE} -p ${CMAKE_BINARY_DIR})
    file(
        WRITE ${CMAKE_CURRENT_BINARY_DIR}/.clang-tidy
        "
---
Checks: >
  -misc-include-cleaner
InheritParentConfig: true
")
endif()

if(CYRILLIC_ENCODER_ENABLE_IWYU)
    find_program(INCLUDE_WHAT_YOU_USE_EXECUTABLE include-what-you-use REQUIRED)
    set(CMAKE_CXX_INCLUDE_WHAT_YOU_USE
        ${INCLUDE_WHAT_YOU_USE_EXECUTABLE}
        -w
        -Xiwyu
        --error
        -Xiwyu
        --experimental=clang_mappings
        -Xiwyu
        --comment_style=long
        -Xiwyu
        --mapping_file=${CMAKE_CURRENT_SOURCE_DIR}/iwyu.imp
        -Xiwyu
        --max_line_length=1200
        # -Xiwyu --verbose=7
        CACHE STRING "Include-what-you-use command")
endif()

include(CTest)
include(GNUInstallDirs)

if(CYRILLIC_ENCODER_ENABLE_FETCHCONTENT)
    include(dependencies.cmake)
endif()

add_subdirectory(src)
