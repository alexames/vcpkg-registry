# Builds the Lua 5.1.5 library, and optionally a second copy compiled as C++
# and a standalone interpreter on each, from the release's src/, into which
# the portfile copies this file. Stands in for the release's own Makefile, which
# has no install rule for Windows and exports no CMake package.
#
# Targets, exported under the lua51:: namespace:
#   lua51      The library, compiled as C. Always built.
#   lua51-cpp  The same sources compiled as C++, so luaconf.h's LUAI_THROW
#              raises a Lua error as a C++ exception, which runs the
#              destructors of the C++ frames it unwinds; a C build's longjmp
#              skips them. Its API has C++ linkage. Built with
#              LUA51_BUILD_CXX_LIBRARY.
#
# Options:
#   LUA51_BUILD_CXX_LIBRARY  Also build lua51-cpp.
#   LUA51_WITH_BITOP         Build Lua BitOp's bit.c into each library.
#   LUA51_WITH_LUAJIT_API    Build lextensions.c into each library.
#   LUA51_BUILD_INTERPRETER  Also build the standalone interpreters: lua51,
#                            which runs lua51, and with LUA51_BUILD_CXX_LIBRARY
#                            lua51-cpp, which runs lua51-cpp.

# 3.24 for $<LINK_LIBRARY:WHOLE_ARCHIVE,...>.
cmake_minimum_required(VERSION 3.24)

project(lua51 VERSION 5.1.5 LANGUAGES C)

option(LUA51_BUILD_CXX_LIBRARY "Also build lua51-cpp, Lua compiled as C++" OFF)
option(LUA51_WITH_BITOP "Build Lua BitOp's bit library into the library" OFF)
option(LUA51_WITH_LUAJIT_API "Build the LuaJIT 2.1 API additions" OFF)
option(LUA51_BUILD_INTERPRETER "Build the standalone interpreter" OFF)

if(LUA51_BUILD_CXX_LIBRARY)
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

# Gives TARGET, a library built from the release's sources, what both
# libraries share: the headers, the DLL export switch and the POSIX libraries.
function(lua51_configure_library target)
  target_include_directories(${target} PUBLIC
    "$<BUILD_INTERFACE:${PROJECT_SOURCE_DIR}>"
    "$<INSTALL_INTERFACE:include>"
  )
  if(WIN32 AND BUILD_SHARED_LIBS)
    target_compile_definitions(${target} PUBLIC LUA_BUILD_AS_DLL)
  endif()
  if(UNIX)
    target_link_libraries(${target} PRIVATE ${CMAKE_DL_LIBS})
    if(LUA51_LIBM)
      target_link_libraries(${target} PRIVATE m)
    endif()
  endif()
endfunction()

add_library(lua51 ${library_sources})
lua51_configure_library(lua51)
set(installed_targets lua51)

# A source file's language is a property of the file, not of the target that
# compiles it, so the C++ library compiles copies of the sources. A copy
# still finds the headers on the include path.
if(LUA51_BUILD_CXX_LIBRARY)
  set(cxx_source_dir "${PROJECT_BINARY_DIR}/cpp")
  set(cxx_library_sources "")
  foreach(source IN LISTS library_sources)
    configure_file("${PROJECT_SOURCE_DIR}/${source}"
      "${cxx_source_dir}/${source}" COPYONLY)
    list(APPEND cxx_library_sources "${cxx_source_dir}/${source}")
  endforeach()
  set(cxx_interpreter_source "${cxx_source_dir}/lua.c")
  configure_file("${PROJECT_SOURCE_DIR}/lua.c" "${cxx_interpreter_source}"
    COPYONLY)
  set_source_files_properties(${cxx_library_sources} ${cxx_interpreter_source}
    PROPERTIES LANGUAGE CXX)

  add_library(lua51-cpp ${cxx_library_sources})
  lua51_configure_library(lua51-cpp)
  list(APPEND installed_targets lua51-cpp)
endif()

install(FILES lua.h luaconf.h lualib.h lauxlib.h lua.hpp DESTINATION include)
install(TARGETS ${installed_targets}
  EXPORT lua51-targets
  RUNTIME DESTINATION bin
  LIBRARY DESTINATION lib
  ARCHIVE DESTINATION lib
)

# Adds INTERPRETER, the standalone interpreter built from SOURCE, lua.c or its
# C++ copy, on CORE, one of the libraries. A native module loads only in the
# interpreter of the library it was built against: each core is a copy of its
# own, and the two raise a Lua error differently.
function(lua51_add_interpreter interpreter source core)
  add_executable(${interpreter}-interpreter "${source}")
  # Named apart from the library's PDB, which shares bin with it.
  set_target_properties(${interpreter}-interpreter PROPERTIES
    OUTPUT_NAME ${interpreter}
    PDB_NAME ${interpreter}-interpreter)
  # Off Windows a native module may link no core, binding its Lua calls to
  # the process's when it is loaded. A static core is linked whole, since
  # otherwise only the archive members lua.c calls are kept, and exported: an
  # ELF executable exports nothing unless told to (-Wl,-E), and a macOS one
  # exports its globals by default. On Windows the module and the interpreter
  # each link the core's DLL.
  if(NOT WIN32)
    set_target_properties(${interpreter}-interpreter PROPERTIES
      ENABLE_EXPORTS ON)
  endif()
  if(NOT WIN32 AND NOT BUILD_SHARED_LIBS)
    target_link_libraries(${interpreter}-interpreter PRIVATE
      "$<LINK_LIBRARY:WHOLE_ARCHIVE,${core}>")
  else()
    target_link_libraries(${interpreter}-interpreter PRIVATE ${core})
  endif()
  install(TARGETS ${interpreter}-interpreter RUNTIME DESTINATION bin)
endfunction()

if(LUA51_BUILD_INTERPRETER)
  lua51_add_interpreter(lua51 lua.c lua51)
  if(LUA51_BUILD_CXX_LIBRARY)
    lua51_add_interpreter(lua51-cpp "${cxx_interpreter_source}" lua51-cpp)
  endif()
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
