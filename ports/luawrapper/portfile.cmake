set(VCPKG_BUILD_TYPE release)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO alexames/luawrapper
    REF 1ba586660070d7b33174a2c2ba0f89f09fbe5f13
    SHA512 c2cc62d1af610b7ce405eb779d5adbc9bfc3114c6c191c39080655ce35c9497e41a216def38ee724e01465f756fb0b6a7e05047bd52fb410c67af78bd2b4330b
    HEAD_REF master
)

vcpkg_configure_cmake(
  SOURCE_PATH "${SOURCE_PATH}"
  PREFER_NINJA
)
vcpkg_install_cmake()
vcpkg_fixup_cmake_targets()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(
  INSTALL "${SOURCE_PATH}/LICENSE"
  DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}"
  RENAME copyright)