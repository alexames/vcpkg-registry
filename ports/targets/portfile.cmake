vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO alexames/targets
  REF 7d66a97e05ab0ccf5c855cdc25012e99b518ae5c
  SHA512 ecbdf247c36bce194b0dd129ccc0a9419b837316c3e6efcf278a894aa6c0107777cd8aa690d959bc5a5b5e0e525b80c06ef11abdeabb35233cd540ca7fcb10ab
  HEAD_REF 7d66a97e05ab0ccf5c855cdc25012e99b518ae5c
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
