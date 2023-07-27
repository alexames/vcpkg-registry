vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO thedmd/imgui-node-editor
  REF 2f99b2d613a400f6579762bd7e7c343a0d844158
  SHA512 706e98d6feb5bcbb3de94aa4f4de83927230b229e97f8b7ef8754f3f0a7e2dd6097d54ac3b62e791226124468a8438cb7c9bbedeb8d6ad2819d4c9b6461f9f5f
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
