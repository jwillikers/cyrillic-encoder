include(GenerateExportHeader)

find_package(Boost REQUIRED COMPONENTS headers)

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
          $<$<CXX_COMPILER_ID:Clang>:-Wno-c++98-compat>
          $<$<CXX_COMPILER_ID:Clang>:-Wno-c++98-compat-pedantic>
          $<$<CXX_COMPILER_ID:GNU>:-Werror>
          $<$<CXX_COMPILER_ID:GNU>:-Wall>
          $<$<CXX_COMPILER_ID:MSVC>:/WX>
          $<$<CXX_COMPILER_ID:MSVC>:/W3>)
target_link_libraries(cyrillic-encoder-encode PRIVATE Boost::headers)

find_package(Microsoft.GSL REQUIRED)
find_package(Qt6 6.5 REQUIRED COMPONENTS Core Widgets)

# todo Fix other build types.
get_target_property(_qt_core_location CONAN_LIB::qt_Qt6Core_RELWITHDEBINFO LOCATION_RELWITHDEBINFO)
message(STATUS "_qt_core_location: ${_qt_core_location}")
cmake_path(GET _qt_core_location PARENT_PATH _qt_libdir)
cmake_path(GET _qt_libdir PARENT_PATH _qt_root_dir)
cmake_path(APPEND _qt_root_dir res archdatadir plugins OUTPUT_VARIABLE _qt_plugin_dir)

add_executable(cyrillic-encoder)

target_sources(cyrillic-encoder PRIVATE main.cpp)

set(_qt_plugin_types egldeviceintegrations generic imageformats platforminputcontexts platforms sqldrivers tls wayland-decoration-client wayland-graphics-integration-client wayland-graphics-integration-server wayland-shell-integration xcbglintegrations)
foreach(_plugin_type IN LISTS _qt_plugin_types)
	cmake_path(APPEND _qt_plugin_dir ${_plugin_type} OUTPUT_VARIABLE _qt_${plugin_type}_plugin_dir)
	target_link_directories(cyrillic-encoder PRIVATE ${_qt_${plugin_type}_plugin_dir})
endforeach()

set(_qt_generic_plugins qevdevkeyboardplugin qevdevmouseplugin qevdevtabletplugin qevdevtouchplugin qtuiotouchplugin)
set(_qt_imageformats_plugins qgif qico)
set(_qt_platforms_plugins qeglfs qlinuxfb qminimal qminimalegl qoffscreen qvnc qwayland-egl qwayland-generic qxcb)
set(_qt_platforminputcontexts_plugins composeplatforminputcontextplugin)
set(_qt_sqldrivers_plugins qsqlite qsqlodbc qsqlpsql)
set(_qt_tls_plugins qcertonlybackend qopensslbackend)
set(_qt_wayland-decoration-client_plugins bradient)
set(_qt_wayland-graphics-integration-client_plugins drm-egl-server qt-plugin-wayland-egl shm-emulation-server)
set(_qt_wayland-graphics-integration-server_plugins qt-wayland-compositor-drm-egl-server-buffer qt-wayland-compositor-shm-emulation-server qt-wayland-compositor-wayland-egl qt-wayland-compositor-wayland-eglstream-controller)
set(_qt_wayland-shell-integration_plugins fullscreen-shell-v1 ivi-shell qt-shell wl-shell-plugin xdg-shell)
set(_qt_xcbglintegrations_plugins qxcb-egl-integration qxcb-glx-integration)

foreach(_plugin_type IN LISTS _qt_plugin_types)
	target_link_libraries(cyrillic-encoder PRIVATE ${_qt_${_plugin_type}_plugins})
endforeach()

target_link_directories(cyrillic-encoder PRIVATE ${_qt_libdir})
target_link_libraries(cyrillic-encoder PRIVATE Qt6::QXcbIntegrationPlugin Qt6::XcbQpaPrivate Qt6::Platform Qt6::WaylandClient wayland::wayland-cursor wayland::wayland-client Qt6::OpenGL wayland::wayland-egl EGL xcb-glx xcb Qt6WaylandEglClientHwIntegration Qt6WlShellIntegration)
# Qt6::QWaylandWlShellIntegrationPlugin
# Qt6::QWaylandBradientDecorationPlugin
# Qt6::WaylandClientPrivate
# Qt6::QWaylandEglClientBufferPlugin

target_link_libraries(
  cyrillic-encoder PRIVATE Boost::headers cyrillic-encoder::encode
                           Microsoft.GSL::GSL Qt6::Core Qt6::Widgets)

if(TEST_CYRILLIC_ENCODER OR CMAKE_SOURCE_DIR STREQUAL PROJECT_SOURCE_DIR)
  find_package(ut)

  add_executable(cyrillic-encoder-encode-test)
  target_sources(cyrillic-encoder-encode-test PRIVATE encode.test.cpp)
  target_link_libraries(cyrillic-encoder-encode-test
                        PRIVATE Boost::headers cyrillic-encoder::encode boost-ext-ut::ut)
  target_compile_options(
    cyrillic-encoder-encode-test
    PRIVATE $<$<CXX_COMPILER_ID:Clang>:-Werror>
            $<$<CXX_COMPILER_ID:Clang>:-Weverything>
            $<$<CXX_COMPILER_ID:Clang>:-Wno-c++98-compat>
            $<$<CXX_COMPILER_ID:Clang>:-Wno-c++98-compat-pedantic>
            $<$<CXX_COMPILER_ID:Clang>:-Wno-c99-extensions>
            $<$<CXX_COMPILER_ID:Clang>:-Wno-comma>
            $<$<CXX_COMPILER_ID:Clang>:-Wno-global-constructors>
            $<$<CXX_COMPILER_ID:Clang>:-Wno-missing-variable-declarations>
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

include(GNUInstallDirs)
install(TARGETS cyrillic-encoder)
