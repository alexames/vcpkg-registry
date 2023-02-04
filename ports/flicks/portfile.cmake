vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO alexames/Flicks
  REF 6d6362fb77e7645a0d45e1ba8a2f6de8bda3bdfa
  SHA512 d8332871b00338ddbac27a7528667df7b7b3f679f66949e486227ff979904952d92b9de6dc37dbc892d83033b095960c13a7a7736a1a8611b613cb55e049e4bc
  HEAD_REF 'main'
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
