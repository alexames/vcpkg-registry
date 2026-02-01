vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO alexames/lua
  REF dc62923fe9ba71f7d379415eb5f0a9d0df24a1f5
  SHA512 f467adc7f80db262854ca676ac16e0819cd0fe03f6d333694b92b2684275ca01b176f970477fd58ba8ada9d48434729eae1de47e3c237bd4aa72f502de4aca27
  HEAD_REF extensions/5.1/project
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
