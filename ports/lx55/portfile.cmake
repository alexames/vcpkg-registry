vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO alexames/lua
  REF 04f87c750eb24e6bb780256e6f59375e2185a015
  SHA512 f56652c6cab342c42f769bc6da699652d22a8c9d8819bc300a47bfa62afc4f2768c57ea8dd8d856793f2c5f872bb157923ae111f835ef0f64a3f8adf0e17d9cf
  HEAD_REF extensions/5.5/master
)

vcpkg_cmake_configure(
  SOURCE_PATH "${SOURCE_PATH}"
  OPTIONS
    -DLUA_PROJECT_NAME=lx55
)
vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/${PORT})
vcpkg_copy_tools(TOOL_NAMES ${PORT} SEARCH_DIR "${CURRENT_PACKAGES_DIR}/bin" AUTO_CLEAN)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(
  INSTALL "${SOURCE_PATH}/LICENSE"
  DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}"
  RENAME copyright)
