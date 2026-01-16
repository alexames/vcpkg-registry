vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO alexames/lua-z3
  REF d5f5e0a4b45a19285f490f9275faee9c52dc0e1e
  SHA512 57d0de3511a4e0d370df41fe5ccdf841551a35fcc6f88becf34dcf9910c76f2aae408aa9d6fca056deced5067f6f7fd281bcd8fc6023b188825e1c6a19fd1c98
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
