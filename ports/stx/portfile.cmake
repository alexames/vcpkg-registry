vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO lamarrr/stx
  REF 9a71373c0135a096b4df8319a6e51b248b5c604b
  SHA512 d311141470232be06f4cbbf303582bf0bad38ea936ebf2555d119f93b7f8bacfd4741997099a8bc0206b016e29fa919899185442cb965f41280977dd24629fa5
  HEAD_REF 'main'
)

vcpkg_cmake_configure(
  SOURCE_PATH "${SOURCE_PATH}"
)
vcpkg_cmake_install()
vcpkg_cmake_config_fixup()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(
  INSTALL "${SOURCE_PATH}/LICENSE"
  DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}"
  RENAME copyright)
