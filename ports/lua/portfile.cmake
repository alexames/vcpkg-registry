vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO alexames/lua
  REF a5522f06d2679b8f18534fd6a9968f7eb539dc31
  SHA512 2e79960c9617fc0ae9460cdb67bd6dc8cc8c378fa691a119d8545d2d51569bef52dbc3a3a86712ee18005fc8ff3a5f481b41014db9802a0a93b7590522e87b60
  HEAD_REF a5522f06d2679b8f18534fd6a9968f7eb539dc31
)

vcpkg_configure_cmake(
  SOURCE_PATH "${SOURCE_PATH}"
  PREFER_NINJA
)
vcpkg_install_cmake()
vcpkg_fixup_cmake_targets()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(
  INSTALL "${SOURCE_PATH}/LICENSE"
  DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}"
  RENAME copyright)
