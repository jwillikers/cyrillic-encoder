include(GenerateExportHeader)

find_package(Boost 1.65 REQUIRED)

add_library(cyrillic-encoder-encode)
add_library(cyrillic-encoder::encode ALIAS cyrillic-encoder-encode)
generate_export_header(
  cyrillic-encoder-encode EXPORT_FILE_NAME
  ${CYRILLIC_ENCODER_GENERATED_INCLUDEDIR}/cyrillic-encoder/export.h)
target_include_directories(
  cyrillic-encoder-encode
  INTERFACE $<BUILD_INTERFACE:${CYRILLIC_ENCODER_GENERATED_INCLUDEDIR}>
            $<BUILD_INTERFACE:${CMAKE_SOURCE_DIR}/include>
  PRIVATE ${CYRILLIC_ENCODER_GENERATED_INCLUDEDIR} ${CMAKE_SOURCE_DIR}/include)
target_sources(cyrillic-encoder-encode PRIVATE encode.cpp)
target_compile_options(
  cyrillic-encoder-encode
  PRIVATE $<$<CXX_COMPILER_ID:Clang>:-Werror>
          $<$<CXX_COMPILER_ID:Clang>:-Weverything>
          $<$<CXX_COMPILER_ID:GNU>:-Werror>
          $<$<CXX_COMPILER_ID:GNU>:-Wall>
          $<$<CXX_COMPILER_ID:MSVC>:/WX>
          $<$<CXX_COMPILER_ID:MSVC>:/W3>)
target_link_libraries(cyrillic-encoder-encode PRIVATE Boost::boost)

find_package(Qt5 5.9 REQUIRED COMPONENTS Core Widgets)

add_executable(cyrillic-encoder)

target_sources(cyrillic-encoder PRIVATE main.cpp)

target_link_libraries(
  cyrillic-encoder PRIVATE Boost::boost cyrillic-encoder::encode Qt5::Core
                           Qt5::Widgets)

if(TEST_CYRILLIC_ENCODER OR CMAKE_SOURCE_DIR STREQUAL PROJECT_SOURCE_DIR)
  find_package(ut 1.1.8 REQUIRED)

  add_executable(cyrillic-encoder-encode-test)
  target_sources(cyrillic-encoder-encode-test PRIVATE encode.test.cpp)
  target_link_libraries(cyrillic-encoder-encode-test
                        PRIVATE cyrillic-encoder::encode boost::ut)
  target_compile_options(
    cyrillic-encoder-encode-test
    PRIVATE $<$<CXX_COMPILER_ID:Clang>:-Werror>
            $<$<CXX_COMPILER_ID:Clang>:-Weverything>
            $<$<CXX_COMPILER_ID:Clang>:-Wno-c++98-compat>
            $<$<CXX_COMPILER_ID:Clang>:-Wno-c++98-compat-pedantic>
            $<$<CXX_COMPILER_ID:Clang>:-Wno-c99-extensions>
            $<$<CXX_COMPILER_ID:Clang>:-Wno-comma>
            $<$<CXX_COMPILER_ID:Clang>:-Wno-newline-eof>
            $<$<CXX_COMPILER_ID:GNU>:-Werror>
            $<$<CXX_COMPILER_ID:GNU>:-Wall>
            $<$<CXX_COMPILER_ID:MSVC>:/WX>
            $<$<CXX_COMPILER_ID:MSVC>:/W3>)
  add_test(NAME cyrillic-encoder-encode-test
           COMMAND cyrillic-encoder-encode-test)
  set_tests_properties(cyrillic-encoder-encode-test
                       PROPERTIES LABELS "cyrillic-encoder")
endif()
