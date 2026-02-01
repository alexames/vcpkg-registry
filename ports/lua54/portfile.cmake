vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO alexames/lua
  REF 7f2fa17cdb275e7f1d2d9385e5cccdffbbabb383
  SHA512 25da8d87964bc61c39f21e843b0b4b3421c3690a639c50bc5d64aeecd2f1f8b329b7e6df0ff71e6a77a178cf7e01f4278295368b583ed0ec754d5ca2678d0e70
  HEAD_REF extensions/5.4/project
)

vcpkg_cmake_configure(
  SOURCE_PATH "${SOURCE_PATH}"
)
vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/${PORT})
vcpkg_copy_tools(TOOL_NAMES ${PORT} SEARCH_DIR "${CURRENT_PACKAGES_DIR}/bin" AUTO_CLEAN)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(
  INSTALL "${SOURCE_PATH}/LICENSE"
  DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}"
  RENAME copyright)
