vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO alexames/lua
  REF fb8a0b55183a1bd02e46c474da60ca8883194bc7
  SHA512 026c5a2935917e92df3d820ffef765262c4e3fce573046a1126329d90e29c05f4baf0c0261da6bd3fe7474f8ac79e30e7babfd2f1b0d99243582c645bc08e82f
  HEAD_REF extensions/5.5/project
)

vcpkg_cmake_configure(
  SOURCE_PATH "${SOURCE_PATH}"
  OPTIONS
    -DLUA_PROJECT_NAME=lua55
)
vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/lua55)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(
  INSTALL "${SOURCE_PATH}/LICENSE"
  DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}"
  RENAME copyright)
