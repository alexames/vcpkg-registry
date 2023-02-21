set(VCPKG_BUILD_TYPE release)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO alexames/luawrapper
    REF aa23890767290ac3bddd563e847e65c0a27fcb33
    SHA512 ff6b0109070033832d9966b9e6d6501c5508df7c7866ca35c3ba5b269157a45805b10107fa4fd103248a4535a8be7d40a0d7d62a6b18d93d29a4e04c8b87b0af
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