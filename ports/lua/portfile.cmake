vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO alexames/lua
  REF ebf18698a576c7317e074f58d9c124041bd1331f
  SHA512 475c8d3448c193c8b675f2ea6df6a7ebac6a68e35e3d7ed985d7869f2e776acc7214dece9a2a0ccb088031523dfedabded297d162a85debc5c4fb1cf419e454c
  HEAD_REF ebf18698a576c7317e074f58d9c124041bd1331f
)

vcpkg_cmake_configure(
  SOURCE_PATH "${SOURCE_PATH}"
)
vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/lua)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(
  INSTALL "${SOURCE_PATH}/LICENSE"
  DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}"
  RENAME copyright)
