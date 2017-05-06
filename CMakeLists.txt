
cmake_minimum_required (VERSION 2.6)
cmake_policy (VERSION 2.6)

# Set the Properties of your Plug

# Set the Name of the plug, should be an executable command, lowercase, no spaces 
set (PLUGNAME "machineinfo")
# Set the Category of the Plug, one of:
# personal, hardware, network, system
set (PLUGCATEGORY "network")
# Set the Title to use for the Plug in the Overview and in the Titlebar
set (PLUGTITLE "Machine Info")
set (PLUGDESCRIPTION "Configure machine information")
# The symbolic name of the Icon to use for the plug
set (PLUGICON "computer")

project (${PLUGNAME})

#########################################################
# Only alter stuff below if you know what you are doing #
#########################################################

include (GNUInstallDirs)
set (DATADIR "${CMAKE_INSTALL_FULL_LIBDIR}/switchboard")
set (PKGDATADIR "${DATADIR}/network/pantheon-${PLUGNAME}")
set (GETTEXT_PACKAGE "${PLUGNAME}-plug")

list (APPEND CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/cmake)

# Configure file
configure_file (plug.plugin ${CMAKE_BINARY_DIR}/${PLUGNAME}.plugin)
install (FILES ${CMAKE_BINARY_DIR}/${PLUGNAME}.plugin DESTINATION ${PKGDATADIR})
configure_file (${CMAKE_SOURCE_DIR}/config.vala.cmake ${CMAKE_BINARY_DIR}/src/config.vala)
add_definitions (-DGETTEXT_PACKAGE=\"${GETTEXT_PACKAGE}\")

# Comment this out to enable C compiler warnings
add_definitions (-w)

# Traslation stuff
add_subdirectory (po)
# Info-plug
install (FILES ${resources} DESTINATION ${PKGDATADIR})

#Polkit Policy
configure_file (${CMAKE_SOURCE_DIR}/data/org.pantheon.switchboard.machine-info.policy.cmake ${CMAKE_BINARY_DIR}/data/org.pantheon.switchboard.machine-info.policy)
install (FILES ${CMAKE_BINARY_DIR}/data/org.pantheon.switchboard.machine-info.policy DESTINATION ${CMAKE_INSTALL_FULL_DATAROOTDIR}/polkit-1/actions/)

add_subdirectory(src)
add_subdirectory(cli)







