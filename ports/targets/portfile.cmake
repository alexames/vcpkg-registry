vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO alexames/targets
  REF 7aba3533cbf847e3d9326f2d3c8aa95ff35d9c1a
  SHA512 eb2b9592b6d878f6bd4c9eef4f75dfa88e2e98b818735cfeb54920e8cdf64bbd0c89a16af6e519adacb07cfd3ff658def472ffd02d3113562743aa84125f2404
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
