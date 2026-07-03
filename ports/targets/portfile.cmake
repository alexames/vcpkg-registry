vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO alexames/targets
  REF af6dd84eb13675e8d24631f32f73595db7beb174
  SHA512 456965e3366114ac845b3e67cab0c3eb5ef69ee7a0b0c84f67b4610e3f3c55ef69915daa987f8a3fea166738bf60bbe545851ec60303a8b0fb75d70dfc00e4af
  HEAD_REF main
)

vcpkg_configure_cmake(
  SOURCE_PATH "${SOURCE_PATH}"
  PREFER_NINJA
  OPTIONS
    -DTARGETS_BUILD_EXAMPLES=OFF
    -DTARGETS_BUILD_TESTS=OFF
)
vcpkg_install_cmake()
vcpkg_fixup_cmake_targets()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(
  INSTALL "${SOURCE_PATH}/LICENSE"
  DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}"
  RENAME copyright)
