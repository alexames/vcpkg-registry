set(VCPKG_BUILD_TYPE release)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO alexames/luawrapper
    REF a89f5d34d73a4da3c54d3191079925e1b50f1acd
    SHA512 ab4f002d3170576d02c4a20ab2623b921378c83623434d794c4d82475cd3ab4be4d5095551b9ff6258d8152acb2691d41992f2805ee448b4739f207238f75c66
    HEAD_REF master
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