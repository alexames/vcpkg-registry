vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO BalazsJako/ImGuiColorTextEdit
  REF ca2f9f1462e3b60e56351bc466acda448c5ea50d
  SHA512 36f5ca274ceea80a6cfd4ed55ec238751ac81854eca58958a175467117d9cc2c21cf67eed2b0dc025f5b382f1a15c5971685fafd5dd9491d85509681890757e5
  HEAD_REF master
)

# The upstream repo has no CMakeLists.txt, so we provide one.
file(WRITE "${SOURCE_PATH}/CMakeLists.txt" [=[
cmake_minimum_required(VERSION 3.21)
project(ImGuiColorTextEdit LANGUAGES CXX)

find_package(imgui CONFIG REQUIRED)

add_library(ImGuiColorTextEdit STATIC TextEditor.cpp TextEditor.h)
target_include_directories(ImGuiColorTextEdit PUBLIC
  $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}>
  $<INSTALL_INTERFACE:include>
)
target_link_libraries(ImGuiColorTextEdit PUBLIC imgui::imgui)

install(TARGETS ImGuiColorTextEdit EXPORT ImGuiColorTextEditTargets
  ARCHIVE DESTINATION lib
  LIBRARY DESTINATION lib
  RUNTIME DESTINATION bin
)
install(FILES TextEditor.h DESTINATION include)
install(EXPORT ImGuiColorTextEditTargets
  FILE imgui-color-text-edit-config.cmake
  NAMESPACE imgui-color-text-edit::
  DESTINATION share/imgui-color-text-edit
)
]=])

vcpkg_cmake_configure(
  SOURCE_PATH "${SOURCE_PATH}"
)
vcpkg_cmake_install()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(
  INSTALL "${SOURCE_PATH}/LICENSE"
  DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}"
  RENAME copyright)
