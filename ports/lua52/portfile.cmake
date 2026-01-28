vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO alexames/lua
  REF 2d43382976e1d28f58c584b336e18e979466dd3e
  SHA512 4e3f03ba5475ebb5fe5d11b6f8dd95879caf35c2be3fe3e45764d7e66068bac79815f989e06b8537e00744c794fa9da5954c0548e01047cb1d06d1caf09b8c7c
  HEAD_REF extensions/5.2/project
)

vcpkg_cmake_configure(
  SOURCE_PATH "${SOURCE_PATH}"
  OPTIONS
    -DLUA_PROJECT_NAME=lua52
)
vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/lua52)

vcpkg_copy_tools(TOOL_NAMES lua5252 AUTO_CLEAN)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

file(
  INSTALL "${SOURCE_PATH}/LICENSE"
  DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}"
  RENAME copyright)
