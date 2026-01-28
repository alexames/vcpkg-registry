vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO alexames/lua
  REF 1ee048a3ef57a2a39705ce13fb44fcee96098094
  SHA512 a784181c5a061ffa15674b14cbc4db6662b96a1fa51612911972ad9e901f907bcb174ddeb5e0c4dc1d393264bf7e758a95ba0b06152167baba77f49a147eeb31
  HEAD_REF extensions/5.5/project
)

vcpkg_cmake_configure(
  SOURCE_PATH "${SOURCE_PATH}"
  OPTIONS
    -DLUA_PROJECT_NAME=lua55
)
vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/lua55)

vcpkg_copy_tools(TOOL_NAMES lua5555 AUTO_CLEAN)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

file(
  INSTALL "${SOURCE_PATH}/LICENSE"
  DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}"
  RENAME copyright)
