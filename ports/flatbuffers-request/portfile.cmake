vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO alexames/flatbuffers-request
  REF b7245606ccb9ddbcf90044cc1ed5843c56cbcfc0
  SHA512 2baed89ca4ea70355d2aadbc9dbaa41fc21199dfb397869dfbcf377196ed48e389f411b728714abefc19bc9bfa406e990d7e7de1ada5918ee1f0f401cb90e4eb
  HEAD_REF main
)

vcpkg_cmake_configure(
  SOURCE_PATH "${SOURCE_PATH}"
  OPTIONS
    -DFBREQUEST_BUILD_TESTS=OFF
    -DFBREQUEST_BUILD_FUZZERS=OFF
    -DFBREQUEST_INSTALL=ON
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(
  PACKAGE_NAME FlatbuffersRequest
  CONFIG_PATH lib/cmake/FlatbuffersRequest
)

# A static library ships no headers or cmake config in the debug tree.
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
