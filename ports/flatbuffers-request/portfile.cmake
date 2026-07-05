vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO alexames/flatbuffers-request
  REF 81ce1006e0b1a4df71009bdf4f3a544a75cc5cf8
  SHA512 3e841f1de04fa8b3961ef2759717ff20a0f89c59458fce5cb1989fa71bae2d67adbf5a3f5eca9d8fd33691ec05cfbd68923520243ea9f1425da3d4ab38fcc765
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
