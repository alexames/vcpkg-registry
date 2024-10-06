vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO alexames/lua
  REF b04661ab85cc05a7548d852342f6a7de7d17b0ac
  SHA512 bb7ceb33128fd9612b61d1ed2931ceef3f9aac0298329d708883ea120e1d4bc039a90afb48337c9b41995fafa3eac3c68340f5b769b3ad299a741971e83aa79d
  HEAD_REF master
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
