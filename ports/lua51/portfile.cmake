vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO alexames/lua
  REF 4ab84ced062ad34136a7e2beae8af8323ca1679f
  SHA512 4aa8eed40ddb8bd89652defcaddac86d4712e1579402a42e4f70bc1abe3ae74b7aeb6716a1266a8584ad894416f18f373677c1f0246cb9f4eaffc5678f97a78e
  HEAD_REF extensions/5.1/project
)

vcpkg_cmake_configure(
  SOURCE_PATH "${SOURCE_PATH}"
  OPTIONS
    -DLUA_PROJECT_NAME=lua51
)
vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/lua51)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(
  INSTALL "${SOURCE_PATH}/LICENSE"
  DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}"
  RENAME copyright)
