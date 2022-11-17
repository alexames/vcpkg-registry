set(VCPKG_BUILD_TYPE release)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO alexames/luawrapper
    REF 3708177b0916900bf3a2ebeafa67dd19ced49436
    SHA512 ea037543a224d629bd9c55204c4c8c828525d751574c3cb294e1bbc6eaeaae1369db3c2e9dc6005617408f23531f1871064c7a1ed40ba1eaf77c364a06521ed8
    HEAD_REF experimental
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