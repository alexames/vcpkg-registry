vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO alexames/targets
  REF 873cbaca6d01ff4c72bb532ded14b31fe1ddd9c9
  SHA512 e40916a0eac9a254689f92899d112fad3ae557a9add390fdbc4a7850f50240f3fc4ef07159dae805bf078f1ac65ff848348f03d8a032b3f9397e13a310159744
  HEAD_REF 873cbaca6d01ff4c72bb532ded14b31fe1ddd9c9
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
