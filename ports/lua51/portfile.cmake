vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO alexames/lua
  REF 3d7d24ce16b2841f5f3fc4e644f24ddc7d9ae180
  SHA512 0b7259dcc8f5b39baad870e5820b44c72deeb5ccd2c723f8021251b9ddd1aea5a32979d05399727f810bf69e538c9109924a8e9a71b00d1f961e13e73f7496bb
  HEAD_REF extensions/5.1/project
)

vcpkg_cmake_configure(
  SOURCE_PATH "${SOURCE_PATH}"
  OPTIONS
    -DLUA_PROJECT_NAME=lua51
)
vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/lua51)

vcpkg_copy_tools(TOOL_NAMES lua5151 AUTO_CLEAN)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

file(
  INSTALL "${SOURCE_PATH}/LICENSE"
  DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}"
  RENAME copyright)
