vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO alexames/lua
  REF a53df0af53ac0c0dabf0b8ebd0c25cf21983be57
  SHA512 dcc1c4e950ff694c26d9bd7ada04ef8684be28306189dd9c91178ce1bca10827a8108997a6dbdd7db93715ebc4388d21d14a2d2e7a061a798bd35b093172c57e
  HEAD_REF extensions/5.4/project
)

vcpkg_cmake_configure(
  SOURCE_PATH "${SOURCE_PATH}"
  OPTIONS
    -DLUA_PROJECT_NAME=lua54
)
vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/lua54)

vcpkg_copy_tools(TOOL_NAMES lua5454 AUTO_CLEAN)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

file(
  INSTALL "${SOURCE_PATH}/LICENSE"
  DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}"
  RENAME copyright)
