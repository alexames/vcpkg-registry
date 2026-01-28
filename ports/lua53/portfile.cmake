vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO alexames/lua
  REF aee79f8ea01d5d1b32d160d0629cbc82c55f08c0
  SHA512 811209f3064ee5d4e6dd586de251f1a12344dce743dc5285c4654c4dc58819c3599ed0b4bbdb4ec344770070311367280a2e93ec1fbf72a152c18acc050c32fd
  HEAD_REF extensions/5.3/project
)

vcpkg_cmake_configure(
  SOURCE_PATH "${SOURCE_PATH}"
  OPTIONS
    -DLUA_PROJECT_NAME=lua53
)
vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/lua53)

vcpkg_copy_tools(TOOL_NAMES lua5353 AUTO_CLEAN)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

file(
  INSTALL "${SOURCE_PATH}/LICENSE"
  DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}"
  RENAME copyright)
