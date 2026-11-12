# Builds the Lua 5.1.5 release. With no feature the library is stock Lua 5.1.5,
# compiled as C; every feature departs from it, and none is on by default. The
# cpp feature adds a second library beside it rather than changing it.
#
# Update this port by hand: `vcpkger.py update` rewrites the first
# vcpkg_from_github call as the port's source, and here that call is the
# bitop feature's Lua BitOp download.

# The lua.org release tarball, whose published SHA256 is
# 2640fc56a795f29d28ef15e13c34a47e223960b0240e8cb0a82d9b0738695333. The
# mirrors serve the same file, Debian's under a name of its own.
vcpkg_download_distfile(ARCHIVE
    URLS
        "https://www.lua.org/ftp/lua-${VERSION}.tar.gz"
        "https://www.tecgraf.puc-rio.br/lua/mirror/ftp/lua-${VERSION}.tar.gz"
        "https://deb.debian.org/debian/pool/main/l/lua5.1/lua5.1_${VERSION}.orig.tar.gz"
    FILENAME "lua-${VERSION}.tar.gz"
    SHA512 0142fefcbd13afcd9b201403592aa60620011cc8e8559d4d2db2f92739d18186860989f48caa45830ff4f99bfc7483287fd3ff3a16d4dec928e2767ce4d542a9
)
vcpkg_extract_source_archive(RELEASE_PATH ARCHIVE "${ARCHIVE}")
set(SOURCE_PATH "${RELEASE_PATH}/src")

file(COPY "${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt" DESTINATION "${SOURCE_PATH}")

# The release's lua.hpp, which includes the headers inside extern "C", is for
# the C library; a consumer of the cpp feature's lua51-cpp includes lua.h,
# lualib.h and lauxlib.h directly.
file(COPY "${RELEASE_PATH}/etc/lua.hpp" DESTINATION "${SOURCE_PATH}")

set(COPYRIGHT_FILES "${RELEASE_PATH}/COPYRIGHT")

if("bitop" IN_LIST FEATURES)
    # Lua BitOp 1.0.2. Its home, bitop.luajit.org, serves no archive, so the
    # release is taken from the LuaDist mirror.
    vcpkg_from_github(
        OUT_SOURCE_PATH BITOP_SOURCE_PATH
        REPO LuaDist/luabitop
        REF 1.0.2
        SHA512 c3d587ab3275b6454e84a6b73beaa8ee259ccc3d14bee58c2efc6cb5c74ae65d246adbf3b30c3ea98d9037075975b484786fe2c8eaee84c0c2b2171564de8c82
        HEAD_REF master
    )
    file(COPY "${BITOP_SOURCE_PATH}/bit.c" DESTINATION "${SOURCE_PATH}")

    # Declares bit beside the other libraries, under the names LuaJIT's
    # lualib.h gives it, and opens it in luaL_openlibs after debug, where
    # LuaJIT does.
    vcpkg_replace_string("${SOURCE_PATH}/lualib.h"
        "LUALIB_API int (luaopen_package) (lua_State *L);"
        "LUALIB_API int (luaopen_package) (lua_State *L);\n\n#define LUA_BITLIBNAME\t\"bit\"\nLUALIB_API int (luaopen_bit) (lua_State *L);"
    )
    vcpkg_replace_string("${SOURCE_PATH}/linit.c"
        "  {LUA_DBLIBNAME, luaopen_debug},"
        "  {LUA_DBLIBNAME, luaopen_debug},\n  {LUA_BITLIBNAME, luaopen_bit},"
    )

    # Lua BitOp's license is the comment that opens bit.c.
    file(READ "${BITOP_SOURCE_PATH}/bit.c" bitop_source)
    string(FIND "${bitop_source}" "*/" bitop_license_end)
    string(SUBSTRING "${bitop_source}" 0 ${bitop_license_end} bitop_license)
    file(WRITE "${CURRENT_BUILDTREES_DIR}/bitop-license.txt" "${bitop_license}*/\n")
    list(APPEND COPYRIGHT_FILES "${CURRENT_BUILDTREES_DIR}/bitop-license.txt")
endif()

if("luajit-api" IN_LIST FEATURES)
    file(COPY "${CMAKE_CURRENT_LIST_DIR}/lextensions.c" DESTINATION "${SOURCE_PATH}")

    # Declares LUA_OK and what lextensions.c defines, under the names and
    # signatures LuaJIT 2.1's headers give them.
    vcpkg_replace_string("${SOURCE_PATH}/lua.h"
        "#define LUA_ERRERR\t5"
        "#define LUA_ERRERR\t5\n\n#define LUA_OK\t\t0"
    )
    vcpkg_replace_string("${SOURCE_PATH}/lua.h"
        "LUA_API lua_Integer     (lua_tointeger) (lua_State *L, int idx);"
        "LUA_API lua_Integer     (lua_tointeger) (lua_State *L, int idx);\nLUA_API lua_Number      (lua_tonumberx) (lua_State *L, int idx, int *isnum);\nLUA_API lua_Integer     (lua_tointegerx) (lua_State *L, int idx, int *isnum);"
    )
    vcpkg_replace_string("${SOURCE_PATH}/lauxlib.h"
        "LUALIB_API const char *(luaL_findtable) (lua_State *L, int idx,\n                                         const char *fname, int szhint);"
        [[LUALIB_API const char *(luaL_findtable) (lua_State *L, int idx,
                                         const char *fname, int szhint);

LUALIB_API void (luaL_setfuncs) (lua_State *L, const luaL_Reg *l, int nup);
LUALIB_API void *(luaL_testudata) (lua_State *L, int ud, const char *tname);
LUALIB_API void (luaL_setmetatable) (lua_State *L, const char *tname);
LUALIB_API void (luaL_traceback) (lua_State *L, lua_State *L1,
                                  const char *msg, int level);
LUALIB_API int (luaL_loadbufferx) (lua_State *L, const char *buff, size_t sz,
                                   const char *name, const char *mode);

#define luaL_newlibtable(L, l) \
  lua_createtable(L, 0, sizeof(l) / sizeof((l)[0]) - 1)
#define luaL_newlib(L, l) (luaL_newlibtable(L, l), luaL_setfuncs(L, l, 0))]]
    )

    # Files package.preload in the registry under "_PRELOAD", where LuaJIT and
    # Lua 5.2 and later file it, so C code reaches it there on any of them.
    vcpkg_replace_string("${SOURCE_PATH}/loadlib.c"
        "  lua_newtable(L);\n  lua_setfield(L, -2, \"preload\");"
        "  luaL_findtable(L, LUA_REGISTRYINDEX, \"_PRELOAD\", 0);\n  lua_setfield(L, -2, \"preload\");"
    )
endif()

if("int64" IN_LIST FEATURES)
    # Lua 5.1's own lua_Integer, ptrdiff_t, is 32 bits on a 32-bit target such
    # as wasm32, where it wraps any integer past 2^31 that a double still holds
    # exactly. On 32-bit x86 luaconf.h converts through lua_number2int, which
    # stores an int; it is replaced by the cast every other target uses.
    vcpkg_replace_string("${SOURCE_PATH}/luaconf.h"
        "#define LUA_INTEGER\tptrdiff_t"
        "#define LUA_INTEGER\tlong long"
    )
    vcpkg_replace_string("${SOURCE_PATH}/luaconf.h"
        "#define lua_number2integer(i,n)\t\tlua_number2int(i, n)"
        "#define lua_number2integer(i,n)\t((i)=(lua_Integer)(n))"
    )
endif()

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        cpp LUA51_BUILD_CXX_LIBRARY
        bitop LUA51_WITH_BITOP
        luajit-api LUA51_WITH_LUAJIT_API
        tools LUA51_BUILD_INTERPRETER
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
    OPTIONS_DEBUG
        -DLUA51_BUILD_INTERPRETER=OFF
)
vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_cmake_config_fixup(CONFIG_PATH share/lua51)

if("tools" IN_LIST FEATURES)
    vcpkg_copy_tools(TOOL_NAMES lua51 AUTO_CLEAN)
endif()

# A consumer that includes the headers without the CMake target, as a native
# module built by luarocks does, still imports the API from the DLL.
if(VCPKG_TARGET_IS_WINDOWS AND VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/luaconf.h"
        "#if defined(LUA_BUILD_AS_DLL)" "#if 1")
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

configure_file("${CMAKE_CURRENT_LIST_DIR}/usage" "${CURRENT_PACKAGES_DIR}/share/${PORT}/usage" COPYONLY)
if("cpp" IN_LIST FEATURES)
    file(APPEND "${CURRENT_PACKAGES_DIR}/share/${PORT}/usage"
        [[

The cpp feature adds lua51::lua51-cpp, the same Lua compiled as C++, beside
the C library lua51::lua51:

    target_link_libraries(main PRIVATE lua51::lua51-cpp)

Its API has C++ linkage: include lua.h, lualib.h and lauxlib.h without an
`extern "C"` around them, and not lua.hpp, which adds one. A Lua error
raises a C++ exception. A toolchain that compiles catch blocks away turns
every Lua error into an abort: on Emscripten, compile and link with
-fwasm-exceptions or -sDISABLE_EXCEPTION_CATCHING=0.
]])
endif()
if("tools" IN_LIST FEATURES)
    file(APPEND "${CURRENT_PACKAGES_DIR}/share/${PORT}/usage"
        [[

The interpreter, tools/lua51/lua51, runs lua51-cpp when the cpp feature is
installed, and lua51 otherwise, so it loads the native modules built against
that library. Off Windows it exports the whole Lua API, for a module that
links no core.
]])
endif()

vcpkg_install_copyright(FILE_LIST ${COPYRIGHT_FILES})
