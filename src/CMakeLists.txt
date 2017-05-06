find_package (PkgConfig)

# Add all your dependencies to the list below
# pkg_check_modules (DEPS REQUIRED polkit-gobject-1 gthread-2.0 gtk+-3.0 switchboard-2.0 granite gnome-settings-daemon)
pkg_check_modules (DEPS REQUIRED polkit-gobject-1 gthread-2.0 gtk+-3.0 switchboard-2.0 granite)

add_definitions (${DEPS_CFLAGS})
link_directories (${DEPS_LIBRARY_DIRS})

find_package (Vala REQUIRED)
include (ValaVersion)
ensure_vala_version ("0.34.4" MINIMUM)

include (ValaPrecompile)
# Add all your vala files and requires packages to the List below to include them in the build
vala_precompile (VALA_C
    Plug.vala
    CropView.vala
    AvatarDialog.vala
    AvatarPopover.vala
    DBusInterfaces.vala
    MachineInfo.vala
    Permission.vala
    ${CMAKE_CURRENT_BINARY_DIR}/config.vala
PACKAGES
    gtk+-3.0
    switchboard-2.0
    granite
    polkit-gobject-1
    posix
    gio-2.0
OPTIONS
    --thread
)

add_library (${PLUGNAME} MODULE ${VALA_C})
target_link_libraries(${PLUGNAME} ${DEPS_LIBRARIES})

# Installation
install (TARGETS ${PLUGNAME} DESTINATION ${PKGDATADIR})
