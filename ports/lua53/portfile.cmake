vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO alexames/lua
  REF 9c4d0631fcd03da45ae2971548968f4c127f2125
  SHA512 70c8c8cfcf83afc73f44a1ed44a02bc70d75df0d97c740c47ad4170ae3a07860cd1cc84239ec8dbd70b92cea0a9b1fb270b5948a253c6beb37fe9256a9aed272
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
