vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO alexames/lua
  REF 8de2c3c75537b57929d66617a83a207e807ee6ee
  SHA512 d88158ed9a3950b1697033aaaf6babe86d26aae854ff1b692e3bd8d4f7729a29b388670188c173b7816fb84a851cd86fddeaf05779f316cea0cc0855f87e93de
  HEAD_REF extensions/5.5/master
)

# LUA_BUILD_AS_CXX makes a Lua error a C++ throw instead of a longjmp, which is
# what a host with C++ lua_CFunction frames needs: on Windows a longjmp unwinds
# those frames for real, and MSVC keeps a frame's unwind state accurate only
# across calls it believes can throw -- which an extern "C" call is not. It
# costs the API its C linkage, so a consumer must include lua.h WITHOUT an
# `extern "C"` wrapper.
vcpkg_cmake_configure(
  SOURCE_PATH "${SOURCE_PATH}"
  OPTIONS
    -DLUA_PROJECT_NAME=lx55
    -DLUA_BUILD_AS_CXX=ON
)
vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/${PORT})
vcpkg_copy_tools(TOOL_NAMES ${PORT} SEARCH_DIR "${CURRENT_PACKAGES_DIR}/bin" AUTO_CLEAN)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(
  INSTALL "${SOURCE_PATH}/LICENSE"
  DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}"
  RENAME copyright)
