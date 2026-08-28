set(VCPKG_BUILD_TYPE release)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO alexames/luawrapper
    REF 36a487e70ba7240421490cb75acc3add3468824a
    SHA512 5de233a050645dce027d2bf324d9f3d095d29a9923d1a0b89e4199f298230f8775bf3c3f75bd7dd1e8a0d24c8dd90e4506e9c5b9b54d5fdc1bdcf7720160abaf
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