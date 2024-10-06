vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO alexames/lua
  REF 299c0f0e573e4900ad556efdf94aabd067e142c8
  SHA512 5578fe98a44ebb7a90bdb932bfab04aabb7a1c9380821d94050b7323938322bc8c93c5df4f56ee0799053ad85ebaf3b333229ef87bb210be58f30e0e2d61b66a
  HEAD_REF lx/5.5/master
)

vcpkg_configure_cmake(
  SOURCE_PATH "${SOURCE_PATH}"
  PREFER_NINJA
  OPTIONS
    -DLUA_BUILD_TESTS=FALSE
    -DLUA_PROJECT_NAME=lx
)
vcpkg_install_cmake()
vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/${PORT})

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(
  INSTALL "${SOURCE_PATH}/LICENSE"
  DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}"
  RENAME copyright)
