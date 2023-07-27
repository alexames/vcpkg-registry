vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO aiekick/ImGuiFileDialog
  REF c989ceffa3bc3bb4652357a947fb77325e5df4c9
  SHA512 54b0980d468889396e10644a2e6f34a02b7f4c20b4f3160f0e4e9f260bef98baf2b3b542d2494649faf915e2ed9cf24ad146ee2b29cc03c098b3820a4fd1cba2
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
