vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO alexames/Flicks
  REF 1116d733ff893e223e1bb5cbec14dfef4e2b4a6b
  SHA512 09ae2036fca90574f9b0e1e4f4574c60a3f64dc5963ab34b34fc1fa5abe4c0ad73171522a4a9c5fc9265b156905b5d3facf259c3c3f78c7c02a1a61ff9507aed
  HEAD_REF master
)

vcpkg_configure_cmake(
  SOURCE_PATH "${SOURCE_PATH}"
  PREFER_NINJA
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/${PORT})

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")

file(
  INSTALL "${SOURCE_PATH}/LICENSE"
  DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}"
  RENAME copyright)
