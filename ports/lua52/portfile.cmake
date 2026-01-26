vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO alexames/lua
  REF 92704ffc8c6c9911d1532819d2a68ea71068cbe5
  SHA512 9b02b56591e8a736b03ed78c77e88ed170c9af8542e0009dde0951fb9fa7cd089c16cfffe8323f7705fdb23eff9345ab426c941728dd44bb66ff55adbba4c448
  HEAD_REF extensions/5.2/project
)

vcpkg_cmake_configure(
  SOURCE_PATH "${SOURCE_PATH}"
  OPTIONS
    -DLUA_PROJECT_NAME=lua52
)
vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/lua52)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(
  INSTALL "${SOURCE_PATH}/LICENSE"
  DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}"
  RENAME copyright)
