# Builds the Lua 5.1.5 library, and optionally its standalone interpreter, from
# the release's src/, into which the portfile copies this file. Stands in for
# the release's own Makefile, which has no install rule for Windows and exports
# no CMake package.
#
# Options:
#   LUA51_BUILD_AS_CXX       Compile every source as C++. luaconf.h's
#                            LUAI_THROW then raises a Lua error as a C++
#                            exception, which runs the destructors of the C++
#                            frames it unwinds; a C build's longjmp skips them.
#                            The API then has C++ linkage.
#   LUA51_WITH_BITOP         Build Lua BitOp's bit.c into the library.
#   LUA51_WITH_LUAJIT_API    Build lextensions.c into the library.
#   LUA51_BUILD_INTERPRETER  Also build the standalone interpreter, lua51.

cmake_minimum_required(VERSION 3.20)

project(lua51 VERSION 5.1.5 LANGUAGES C)

option(LUA51_BUILD_AS_CXX "Compile Lua as C++" OFF)
option(LUA51_WITH_BITOP "Build Lua BitOp's bit library into the library" OFF)
option(LUA51_WITH_LUAJIT_API "Build the LuaJIT 2.1 API additions" OFF)
option(LUA51_BUILD_INTERPRETER "Build the standalone interpreter" OFF)

if(LUA51_BUILD_AS_CXX)
  enable_language(CXX)
endif()

if(WIN32)
  add_compile_definitions(_CRT_SECURE_NO_WARNINGS)
endif()

if(UNIX)
  add_compile_definitions(LUA_USE_POSIX LUA_USE_DLOPEN)
  find_library(LUA51_LIBM NAMES m)
endif()

set(library_sources
  lapi.c lcode.c ldebug.c ldo.c ldump.c lfunc.c lgc.c llex.c lmem.c
  lobject.c lopcodes.c lparser.c lstate.c lstring.c ltable.c ltm.c
  lundump.c lvm.c lzio.c
  lauxlib.c lbaselib.c ldblib.c liolib.c lmathlib.c loslib.c ltablib.c
  lstrlib.c loadlib.c linit.c
)
if(LUA51_WITH_BITOP)
  list(APPEND library_sources bit.c)
endif()
if(LUA51_WITH_LUAJIT_API)
  list(APPEND library_sources lextensions.c)
endif()
if(LUA51_BUILD_AS_CXX)
  set_source_files_properties(${library_sources} lua.c
    PROPERTIES LANGUAGE CXX)
endif()

add_library(lua51 ${library_sources})
target_include_directories(lua51 PUBLIC
  "$<BUILD_INTERFACE:${PROJECT_SOURCE_DIR}>"
  "$<INSTALL_INTERFACE:include>"
)
if(WIN32 AND BUILD_SHARED_LIBS)
  target_compile_definitions(lua51 PUBLIC LUA_BUILD_AS_DLL)
endif()
if(UNIX)
  target_link_libraries(lua51 PRIVATE ${CMAKE_DL_LIBS})
  if(LUA51_LIBM)
    target_link_libraries(lua51 PRIVATE m)
  endif()
endif()

install(FILES lua.h luaconf.h lualib.h lauxlib.h lua.hpp DESTINATION include)
install(TARGETS lua51
  EXPORT lua51-targets
  RUNTIME DESTINATION bin
  LIBRARY DESTINATION lib
  ARCHIVE DESTINATION lib
)

if(LUA51_BUILD_INTERPRETER)
  add_executable(lua51-interpreter lua.c)
  # Named apart from the library's lua51.pdb, which shares bin with it.
  set_target_properties(lua51-interpreter PROPERTIES
    OUTPUT_NAME lua51
    PDB_NAME lua51-interpreter)
  target_link_libraries(lua51-interpreter PRIVATE lua51)
  install(TARGETS lua51-interpreter RUNTIME DESTINATION bin)
endif()

include(CMakePackageConfigHelpers)
write_basic_package_version_file(
  "${PROJECT_BINARY_DIR}/lua51-config-version.cmake"
  COMPATIBILITY SameMinorVersion
)
install(EXPORT lua51-targets
  FILE lua51-config.cmake
  NAMESPACE lua51::
  DESTINATION share/lua51
)
install(FILES "${PROJECT_BINARY_DIR}/lua51-config-version.cmake"
  DESTINATION share/lua51
)
