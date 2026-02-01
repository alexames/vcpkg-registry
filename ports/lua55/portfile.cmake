vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO alexames/lua
  REF 8814ec85cdf1a3711ecd6a0bed34132264cf07e3
  SHA512 648b76a3cc5848e7ea1fcf9aceadced327e32ce855bcb787708de1891b60119a1ac4e3a3af832ca2d33a85daae96217e4b9f9c53610ec57f6ac9884666569c99
  HEAD_REF extensions/5.5/project
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
