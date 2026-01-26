vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO alexames/lua
  REF 6d90329e41adf690b37c27dfd8c427770c0b7f88
  SHA512 6e97e644e6db59589c29856f7cff9f325fb0d9045bdff50d219e5b41753a620fd523e3b066761ee53a9d4ddd5a9a5b99752f9e37551f5f4b8874cbf833ebcd44
  HEAD_REF extensions/5.4/project
)

vcpkg_cmake_configure(
  SOURCE_PATH "${SOURCE_PATH}"
  OPTIONS
    -DLUA_PROJECT_NAME=lua54
)
vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/lua54)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(
  INSTALL "${SOURCE_PATH}/LICENSE"
  DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}"
  RENAME copyright)
