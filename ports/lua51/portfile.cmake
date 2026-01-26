vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO alexames/lua
  REF 3655b0eef68784d9839429004529ef940deaadfd
  SHA512 3870a5834f9cf877303fc08c1d807a34de56feba7368257af0ce52c90110e3fbe2876c29cf3fb6a30f1ce7ca3bfa61dc3306b202544c5521cee3cc62693d678b
  HEAD_REF extensions/5.1/project
)

vcpkg_cmake_configure(
  SOURCE_PATH "${SOURCE_PATH}"
  OPTIONS
    -DLUA_PROJECT_NAME=lua51
)
vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/lua51)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(
  INSTALL "${SOURCE_PATH}/LICENSE"
  DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}"
  RENAME copyright)
