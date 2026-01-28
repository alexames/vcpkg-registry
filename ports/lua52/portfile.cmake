vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO alexames/lua
  REF 6de2bed9c9f1a0804cfb3d7601722d680cbbc71e
  SHA512 e59d7689a71e7b632fe13771665a368584f5bef45adcedbcc71834351fabc7ac36f2bee984495439ca648cfe8f13319d4d1117b8f2ce0ebf23275c432c18f505
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
