vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO alexames/lua-z3
  REF c166fb21f912b021ad44a7f109bd1816c48ba23a
  SHA512 6f5fe78a788fd558938636e9fbb8cfc88ce3aae0e849ec04afb243bfa47c2a2c0cb4399be69333d00addf2166d6935be8a04df5f1e51d5210eec037ce4c1a222
  HEAD_REF main
)

vcpkg_cmake_configure(
  SOURCE_PATH "${SOURCE_PATH}"
  OPTIONS
    -DLUA_Z3_ENABLE_INSTALL=ON
)

vcpkg_cmake_install()

# lua-z3 is a Lua module, not a CMake library - no config files to fixup
# Remove empty directories if they exist
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
