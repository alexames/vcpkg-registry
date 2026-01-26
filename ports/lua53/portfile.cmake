vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO alexames/lua
  REF 3a871abea468f55cee7b446412364b0f9266b2c6
  SHA512 92f1a5a8dfc99c84f61f46816034e54c31f331b239b499195b1f5da62e82d9ea8e53e23d78abee30ff9786c30b563f76252845a28ff40dc5e5c2921218eb107e
  HEAD_REF extensions/5.3/project
)

vcpkg_cmake_configure(
  SOURCE_PATH "${SOURCE_PATH}"
  OPTIONS
    -DLUA_PROJECT_NAME=lua53
)
vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/lua53)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(
  INSTALL "${SOURCE_PATH}/LICENSE"
  DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}"
  RENAME copyright)
