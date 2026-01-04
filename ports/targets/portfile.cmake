vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO alexames/targets
  REF 9a8cbc464f395e08d93541b91eae5689684eb5ff
  SHA512 7ce9e04cea9e8142e76214aa436aca0360bf40dedf8d8a90094470ede991cbc8876779405e25574e9ca4626b8e27f28a47278e47fc7bae35880088d942f750fa
  HEAD_REF main
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
