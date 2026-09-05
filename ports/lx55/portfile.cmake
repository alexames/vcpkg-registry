vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO alexames/lua
  REF 4bf502c0a9fd07278856f25e407d6ba35e4f440b
  SHA512 62ac2f8ea794efd5546ec0aea0469f5bafcd457ac1d0fa9744e05b95fea58a0b637015f7afa864402b469a36c4292626037c0f9c2192bbf01350b79a8c74cdb4
  HEAD_REF extensions/5.5/master
)

# LUA_BUILD_AS_CXX makes a Lua error a C++ throw instead of a longjmp, which is
# what a host with C++ lua_CFunction frames needs: on Windows a longjmp unwinds
# those frames for real, and MSVC keeps a frame's unwind state accurate only
# across calls it believes can throw -- which an extern "C" call is not. It
# costs the API its C linkage, so a consumer must include lua.h WITHOUT an
# `extern "C"` wrapper. A target whose toolchain compiles catch blocks away --
# Emscripten does unless it is given -fwasm-exceptions or
# -sDISABLE_EXCEPTION_CATCHING=0 -- turns every Lua error into an abort, so a
# consumer building for one of those must pass the flag or leave this off.
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
