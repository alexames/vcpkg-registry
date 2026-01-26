vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO alexames/lua
  REF c6e6f928b0bb297fb8b4b3497846b3051f55d769
  SHA512 03f04c8937fb2fddaff53bb2f59f1d6add92e2756548c7cf5b2c4584e3c74669db1e797ad6ec7525036ac04d2af7c077362af4e2b6609c02ebba788374d6d1cc
  HEAD_REF extensions/5.4/project
)

vcpkg_cmake_configure(
  SOURCE_PATH "${SOURCE_PATH}"
  OPTIONS
    -DLUA_PROJECT_NAME=lua54
)
vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/lua54)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(
  INSTALL "${SOURCE_PATH}/LICENSE"
  DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}"
  RENAME copyright)
