set(VCPKG_BUILD_TYPE release)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO alexames/luawrapper
    REF ce0e7ed9147c60a0cadd80024112f0d4168d4d7c
    SHA512 be3dca356aefe3985e682ea1396b7dd4abe1aa45c50f06da1210c4b69f30e0f2ac8c2f4b2801eee5012994ea37228d828810869e53a66bec07841975f891076e
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