vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO alexames/luawrapper
  REF 44d4fd7db30b461578a6d59079bde409ee2b1743
  SHA512 c9096cc111f18791981f0845fb12cb3627c804f4ac85d54fe7f3d4d9b417e1fff1e7ea1d2b0f87e369064abe28a2bb0ea7b7453164f3609361bbda0048c389e5
  HEAD_REF main
)

vcpkg_configure_cmake(
  SOURCE_PATH "${SOURCE_PATH}"
)
vcpkg_install_cmake()
vcpkg_fixup_cmake_targets()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(
  INSTALL "${SOURCE_PATH}/LICENSE"
  DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}"
  RENAME copyright)
