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

get_target_property(aliased_target Qt6::Core ALIASED_TARGET)
get_target_property(_qt_core_interface_link_libraries Qt6::Core
                    INTERFACE_LINK_LIBRARIES)
string(REGEX MATCH [[CONAN_LIB::qt_Qt6_Core_Qt6Core.*_([A-Za-z]*)]]
             _qt_core_target ${_qt_core_interface_link_libraries})
set(_qt_build_type ${CMAKE_MATCH_1})

if(NOT TARGET ${_qt_core_target})
  message(FATAL_ERROR "Missing Conan Qt target '${_qt_core_target}'")
endif()

if(TARGET ${_qt_core_target})
  get_target_property(_qt_core_location ${_qt_core_target}
                      LOCATION_${_qt_build_type})
  if(NOT _qt_core_location)
    message(
      FATAL_ERROR
        "Could not determine the location of the '${_qt_core_target}' library.")
  endif()
endif()

set(_qt_static no)
if(_qt_core_location MATCHES "${CMAKE_STATIC_LIBRARY_SUFFIX}$")
  set(_qt_static yes)
endif()

if(_qt_static)
  cmake_path(GET _qt_core_location PARENT_PATH _qt_libdir)
  cmake_path(GET _qt_libdir PARENT_PATH _qt_root_dir)

  # Conan puts the plugins in "res/archdatadir/plugins."
  cmake_path(
    APPEND
    _qt_root_dir
    res
    archdatadir
    plugins
    OUTPUT_VARIABLE
    _qt_plugin_dir)

  set(_qt_plugin_types
      egldeviceintegrations
      generic
      imageformats
      platforminputcontexts
      platforms
      sqldrivers
      tls
      wayland-decoration-client
      wayland-graphics-integration-client
      wayland-graphics-integration-server
      wayland-shell-integration
      xcbglintegrations)

  # set(_qt_egldeviceintegrations_plugins qeglfs-emu-integration
  # qeglfs-kms-egldevice-integration qeglfs-x11-integration)

  set(_qt_generic_plugins qevdevkeyboardplugin qevdevmouseplugin
                          qevdevtabletplugin qevdevtouchplugin qtuiotouchplugin)

  # qevdevkeyboardplugin
  set(_qt_qevdevkeyboardplugin_plugin_target Qt6::QEvdevKeyboardPlugin)
  set(_qt_qevdevkeyboardplugin_plugin_QT_DEFAULT_PLUGIN "0")
  set(_qt_qevdevkeyboardplugin_plugin_QT_MODULE "Gui")
  set(_qt_qevdevkeyboardplugin_plugin_QT_PLUGIN_CLASS_NAME
      "QEvdevKeyboardPlugin")
  set(_qt_qevdevkeyboardplugin_plugin_QT_PLUGIN_TYPE "generic")

  # qevdevmouseplugin
  set(_qt_qevdevmouseplugin_plugin_target Qt6::QEvdevMousePlugin)
  set(_qt_qevdevmouseplugin_plugin_QT_DEFAULT_PLUGIN "0")
  set(_qt_qevdevmouseplugin_plugin_QT_MODULE "Gui")
  set(_qt_qevdevmouseplugin_plugin_QT_PLUGIN_CLASS_NAME "QEvdevMousePlugin")
  set(_qt_qevdevmouseplugin_plugin_QT_PLUGIN_TYPE "generic")

  # qevdevtabletplugin
  set(_qt_qevdevtabletplugin_plugin_target Qt6::QEvdevTabletPlugin)
  set(_qt_qevdevtabletplugin_plugin_QT_DEFAULT_PLUGIN "0")
  set(_qt_qevdevtabletplugin_plugin_QT_MODULE "Gui")
  set(_qt_qevdevtabletplugin_plugin_QT_PLUGIN_CLASS_NAME "QEvdevTabletPlugin")
  set(_qt_qevdevtabletplugin_plugin_QT_PLUGIN_TYPE "generic")

  # qevdevtouchplugin
  set(_qt_qevdevtouchplugin_plugin_target Qt6::QEvdevTouchScreenPlugin)
  set(_qt_qevdevtouchplugin_plugin_QT_DEFAULT_PLUGIN "0")
  set(_qt_qevdevtouchplugin_plugin_QT_MODULE "Gui")
  set(_qt_qevdevtouchplugin_plugin_QT_PLUGIN_CLASS_NAME
      "QEvdevTouchScreenPlugin")
  set(_qt_qevdevtouchplugin_plugin_QT_PLUGIN_TYPE "generic")

  # qtuiotouchplugin
  set(_qt_qtuiotouchplugin_plugin_target Qt6::QTuioTouchPlugin)
  set(_qt_qtuiotouchplugin_plugin_QT_DEFAULT_PLUGIN "0")
  set(_qt_qtuiotouchplugin_plugin_QT_MODULE "Gui")
  set(_qt_qtuiotouchplugin_plugin_QT_PLUGIN_CLASS_NAME "QTuioTouchPlugin")
  set(_qt_qtuiotouchplugin_plugin_QT_PLUGIN_TYPE "generic")

  # set(_qt_imageformats_plugins qgif qico qjpeg qsvg qtiff qwebp)

  set(_qt_platforms_plugins
      # qeglfs
      # qlinuxfb
      # qminimal
      # qminimalegl
      # qoffscreen
      # qvnc
      qwayland-egl qwayland-generic qxcb)

  # qwayland-egl
  set(_qt_qwayland-egl_plugin_target Qt6::QWaylandEglPlatformIntegrationPlugin)
  set(_qt_qwayland-egl_plugin_QT_DEFAULT_PLUGIN "0")
  set(_qt_qwayland-egl_plugin_QT_MODULE "Gui")
  set(_qt_qwayland-egl_plugin_QT_PLUGIN_CLASS_NAME
      "QWaylandEglPlatformIntegrationPlugin")
  set(_qt_qwayland-egl_plugin_QT_PLUGIN_TYPE "platforms")
  set(_qt_qwayland-egl_plugin_INTERFACE_LINK_LIBRARIES "Qt6::WaylandClient")

  # qwayland-generic
  set(_qt_qwayland-generic_plugin_target Qt6::QWaylandIntegrationPlugin)
  set(_qt_qwayland-generic_plugin_QT_DEFAULT_PLUGIN "0")
  set(_qt_qwayland-generic_plugin_QT_MODULE "Gui")
  set(_qt_qwayland-generic_plugin_QT_PLUGIN_CLASS_NAME
      "QWaylandIntegrationPlugin")
  set(_qt_qwayland-generic_plugin_QT_PLUGIN_TYPE "platforms")
  set(_qt_qwayland-generic_plugin_INTERFACE_LINK_LIBRARIES "Qt6::WaylandClient")

  # qxcb
  set(_qt_qxcb_plugin_target Qt6::QXcbIntegrationPlugin)
  set(_qt_qxcb_plugin_QT_DEFAULT_PLUGIN "1")
  set(_qt_qxcb_plugin_QT_MODULE "Gui")
  set(_qt_qxcb_plugin_QT_PLUGIN_CLASS_NAME "QXcbIntegrationPlugin")
  set(_qt_qxcb_plugin_QT_PLUGIN_TYPE "platforms")
  # set(_qt_qxcb_plugin_INTERFACE_LINK_LIBRARIES "Qt6::WaylandClient")

  # set(_qt_platforminputcontexts_plugins composeplatforminputcontextplugin)

  # set(_qt_sqldrivers_plugins qsqlite qsqlodbc qsqlpsql)

  # set(_qt_tls_plugins qcertonlybackend qopensslbackend)

  set(_qt_wayland-decoration-client_plugins bradient)

  # bradient
  set(_qt_bradient_plugin_target Qt6::QWaylandBradientDecorationPlugin)
  set(_qt_bradient_plugin_QT_DEFAULT_PLUGIN "1")
  set(_qt_bradient_plugin_QT_MODULE "WaylandClient")
  set(_qt_bradient_plugin_QT_PLUGIN_CLASS_NAME
      "QWaylandBradientDecorationPlugin")
  set(_qt_bradient_plugin_QT_PLUGIN_TYPE "wayland_decoration_client")
  set(_qt_bradient_plugin_INTERFACE_LINK_LIBRARIES "Qt6::WaylandClient")

  set(_qt_wayland-graphics-integration-client_plugins
      drm-egl-server qt-plugin-wayland-egl shm-emulation-server)

  # drm-egl-server
  set(_qt_drm-egl-server_plugin_target Qt6::DrmEglServerBufferPlugin)
  set(_qt_drm-egl-server_plugin_QT_DEFAULT_PLUGIN "1")
  set(_qt_drm-egl-server_plugin_QT_MODULE "WaylandClient")
  set(_qt_drm-egl-server_plugin_QT_PLUGIN_CLASS_NAME "DrmEglServerBufferPlugin")
  set(_qt_drm-egl-server_plugin_QT_PLUGIN_TYPE
      "wayland_graphics_integration_client")
  set(_qt_drm-egl-server_plugin_INTERFACE_LINK_LIBRARIES "Qt6::WaylandClient")

  # qt-plugin-wayland-egl
  set(_qt_qt-plugin-wayland-egl_plugin_target
      Qt6::QWaylandEglClientBufferPlugin)
  set(_qt_qt-plugin-wayland-egl_plugin_QT_DEFAULT_PLUGIN "1")
  set(_qt_qt-plugin-wayland-egl_plugin_QT_MODULE "WaylandClient")
  set(_qt_qt-plugin-wayland-egl_plugin_QT_PLUGIN_CLASS_NAME
      "QWaylandEglClientBufferPlugin")
  set(_qt_qt-plugin-wayland-egl_plugin_QT_PLUGIN_TYPE
      "wayland_graphics_integration_client")
  set(_qt_qt-plugin-wayland-egl_plugin_INTERFACE_LINK_LIBRARIES
      "Qt6::WaylandClient;Qt6::WaylandEglClientHwIntegration")

  # shm-emulation-server
  set(_qt_shm-emulation-server_plugin_target Qt6::ShmServerBufferPlugin)
  set(_qt_shm-emulation-server_plugin_QT_DEFAULT_PLUGIN "1")
  set(_qt_shm-emulation-server_plugin_QT_MODULE "WaylandClient")
  set(_qt_shm-emulation-server_plugin_QT_PLUGIN_CLASS_NAME
      "ShmServerBufferPlugin")
  set(_qt_shm-emulation-server_plugin_QT_PLUGIN_TYPE
      "wayland_graphics_integration_client")
  set(_qt_shm-emulation-server_plugin_INTERFACE_LINK_LIBRARIES
      "Qt6::WaylandClient")

  # set(_qt_wayland-graphics-integration-server_plugins
  # qt-wayland-compositor-drm-egl-server-buffer
  # qt-wayland-compositor-shm-emulation-server qt-wayland-compositor-wayland-egl
  # qt-wayland-compositor-wayland-eglstream-controller)

  set(_qt_wayland-shell-integration_plugins fullscreen-shell-v1 # ivi-shell
                                            qt-shell wl-shell-plugin xdg-shell)

  # fullscreen-shell-v1
  set(_qt_fullscreen-shell-v1_plugin_target
      Qt6::QWaylandFullScreenShellV1IntegrationPlugin)
  set(_qt_fullscreen-shell-v1_plugin_QT_DEFAULT_PLUGIN "1")
  set(_qt_fullscreen-shell-v1_plugin_QT_MODULE "WaylandClient")
  set(_qt_fullscreen-shell-v1_plugin_QT_PLUGIN_CLASS_NAME
      "QWaylandFullScreenShellV1IntegrationPlugin")
  set(_qt_fullscreen-shell-v1_plugin_QT_PLUGIN_TYPE
      "wayland_graphics_integration_client")
  set(_qt_fullscreen-shell-v1_plugin_INTERFACE_LINK_LIBRARIES
      "Qt6::WaylandClient")

  # qt-shell
  set(_qt_qt-shell_plugin_target Qt6::QWaylandQtShellIntegrationPlugin)
  set(_qt_qt-shell_plugin_QT_DEFAULT_PLUGIN "1")
  set(_qt_qt-shell_plugin_QT_MODULE "WaylandClient")
  set(_qt_qt-shell_plugin_QT_PLUGIN_CLASS_NAME
      "QWaylandQtShellIntegrationPlugin")
  set(_qt_qt-shell_plugin_QT_PLUGIN_TYPE "wayland_graphics_integration_client")
  set(_qt_qt-shell-plugin_INTERFACE_LINK_LIBRARIES "Qt6::WaylandClient")

  # wl-shell-plugin
  set(_qt_wl-shell-plugin_plugin_target Qt6::QWaylandWlShellIntegrationPlugin)
  set(_qt_wl-shell-plugin_plugin_QT_DEFAULT_PLUGIN "1")
  set(_qt_wl-shell-plugin_plugin_QT_MODULE "WaylandClient")
  set(_qt_wl-shell-plugin_plugin_QT_PLUGIN_CLASS_NAME
      "QWaylandWlShellIntegrationPlugin")
  set(_qt_wl-shell-plugin_plugin_QT_PLUGIN_TYPE
      "wayland_graphics_integration_client")
  set(_qt_wl-shell-plugin_plugin_INTERFACE_LINK_LIBRARIES
      "Qt6::WaylandClient;Qt6::WlShellIntegration")

  # xdg-shell
  set(_qt_xdg-shell_plugin_target Qt6::QWaylandXdgShellIntegrationPlugin)
  set(_qt_xdg-shell_plugin_QT_DEFAULT_PLUGIN "1")
  set(_qt_xdg-shell_plugin_QT_MODULE "WaylandClient")
  set(_qt_xdg-shell_plugin_QT_PLUGIN_CLASS_NAME
      "QWaylandXdgShellIntegrationPlugin")
  set(_qt_xdg-shell_plugin_QT_PLUGIN_TYPE "wayland_graphics_integration_client")
  set(_qt_xdg-shell-plugin_INTERFACE_LINK_LIBRARIES "Qt6::WaylandClient")

  # set(_qt_xcbglintegrations_plugins qxcb-egl-integration qxcb-glx-integration)

  foreach(_plugin_type IN LISTS _qt_plugin_types)
    foreach(_plugin IN LISTS _qt_${_plugin_type}_plugins)
      message(STATUS "plugin: ${_plugin}")
      if(NOT TARGET ${_qt_${_plugin}_plugin_target}
         AND EXISTS ${_qt_plugin_dir}/${_plugin_type}/lib${_plugin}.a)
        message(STATUS "plugin target: ${_qt_${_plugin}_plugin_target}")
        add_library(${_qt_${_plugin}_plugin_target} MODULE IMPORTED)
        set_target_properties(
          ${_qt_${_plugin}_plugin_target}
          PROPERTIES IMPORTED_LOCATION
                     ${_qt_plugin_dir}/${_plugin_type}/lib${_plugin}.a
                     INTERFACE_QT_MAJOR_VERSION "6"
                     COMPATIBLE_INTERFACE_STRING "QT_MAJOR_VERSION")
        foreach(_property IN ITEMS INTERFACE_LINK_LIBRARIES QT_DEFAULT_PLUGIN
                                   QT_MODULE QT_PLUGIN_CLASS_NAME)
          if(NOT DEFINED _qt_${_plugin}_plugin_${_property})
            continue()
          endif()
          set_target_properties(
            ${_qt_${_plugin}_plugin_target}
            PROPERTIES ${_property} "${_qt_${_plugin}_plugin_${_property}}")
        endforeach()
      endif()
    endforeach()
  endforeach()

  find_package(OpenGL REQUIRED COMPONENTS EGL)
  add_library(Qt6::WaylandEglClientHwIntegration STATIC IMPORTED)
  set_target_properties(
    Qt6::WaylandEglClientHwIntegration
    PROPERTIES
      IMPORTED_LOCATION ${_qt_libdir}/libQt6WaylandEglClientHwIntegration.a
      INTERFACE_LINK_LIBRARIES
      "dl;OpenGL::EGL;Qt6::Core;Qt6::Gui;Qt6::OpenGL;wayland::wayland-client;wayland::wayland-egl"
      INTERFACE_QT_MAJOR_VERSION "6"
      COMPATIBLE_INTERFACE_STRING "QT_MAJOR_VERSION")

  add_library(Qt6::WlShellIntegration STATIC IMPORTED)
  set_target_properties(
    Qt6::WlShellIntegration
    PROPERTIES IMPORTED_LOCATION ${_qt_libdir}/libQt6WlShellIntegration.a
               INTERFACE_QT_MAJOR_VERSION "6"
               COMPATIBLE_INTERFACE_STRING "QT_MAJOR_VERSION")

  # todo Add this missing dependency to the Conan package.
  set_property(
    TARGET Qt6::WaylandClient
    APPEND
    PROPERTY INTERFACE_LINK_LIBRARIES wayland::wayland-cursor)
endif()

add_executable(cyrillic-encoder)

target_sources(cyrillic-encoder PRIVATE main.cpp)

target_include_directories(cyrillic-encoder
                           PRIVATE ${CYRILLIC_ENCODER_GENERATED_INCLUDEDIR})

if(_qt_static)
  set(_qt_plugin_imports
      [[
  #include <QtPlugin>

  Q_IMPORT_PLUGIN(QXcbIntegrationPlugin)

  Q_IMPORT_PLUGIN(QWaylandBradientDecorationPlugin)

  // qwayland-egl
  Q_IMPORT_PLUGIN(QWaylandEglClientBufferPlugin)
  Q_IMPORT_PLUGIN(QWaylandEglPlatformIntegrationPlugin)

  // qwayland
  Q_IMPORT_PLUGIN(QWaylandXdgShellIntegrationPlugin)
  Q_IMPORT_PLUGIN(QWaylandIntegrationPlugin)
]])

  target_link_libraries(
    cyrillic-encoder
    PRIVATE Qt6::QWaylandBradientDecorationPlugin
            Qt6::QWaylandEglPlatformIntegrationPlugin
            Qt6::QWaylandEglClientBufferPlugin
            Qt6::QWaylandIntegrationPlugin
            Qt6::QWaylandXdgShellIntegrationPlugin
            Qt6::QXcbIntegrationPlugin)
endif()

configure_file(
  qt_plugin_imports.h.in
  ${CYRILLIC_ENCODER_GENERATED_INCLUDEDIR}/cyrillic-encoder/qt_plugin_imports.h
  @ONLY)

target_link_libraries(
  cyrillic-encoder PRIVATE Boost::headers cyrillic-encoder::encode
                           Microsoft.GSL::GSL Qt6::Core Qt6::Widgets)

if(TEST_CYRILLIC_ENCODER OR CMAKE_SOURCE_DIR STREQUAL PROJECT_SOURCE_DIR)
  find_package(ut)

  add_executable(cyrillic-encoder-encode-test)
  target_sources(cyrillic-encoder-encode-test PRIVATE encode.test.cpp)
  target_link_libraries(
    cyrillic-encoder-encode-test
    PRIVATE Boost::headers cyrillic-encoder::encode boost-ext-ut::ut)
  target_compile_options(
    cyrillic-encoder-encode-test
    PRIVATE $<$<CXX_COMPILER_ID:Clang>:-Werror>
            $<$<CXX_COMPILER_ID:Clang>:-Weverything>
            $<$<CXX_COMPILER_ID:Clang>:-Wno-c++98-compat>
            $<$<CXX_COMPILER_ID:Clang>:-Wno-c++98-compat-pedantic>
            $<$<CXX_COMPILER_ID:Clang>:-Wno-c99-extensions>
            $<$<CXX_COMPILER_ID:Clang>:-Wno-comma>
            $<$<CXX_COMPILER_ID:Clang>:-Wno-ctad-maybe-unsupported>
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

clang_tidy(-header-filter='${CMAKE_PROJECT_SOURCE_DIR}/*')

include(GNUInstallDirs)
install(TARGETS cyrillic-encoder)
