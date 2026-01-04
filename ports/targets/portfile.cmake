vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO alexames/targets
  REF a065a41464b65ff964ac1d7213b4fdc75f02f84f
  SHA512 d8b37d5247fb963ad74ceafcea30a7c8ad1cbd4c717e48349feddc893afff8367690fda89b485e943b046dd4faf353f40bce6656146b4f7557826dbbe231eae4
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
