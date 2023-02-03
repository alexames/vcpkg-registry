set(VCPKG_BUILD_TYPE release)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO alexames/luawrapper
    REF 0a0f4d37bb9462f99b97414284736fde5b48c948
    SHA512 b6ccacade60173ae0c92f42795e1e4d03ed5208f29b28192180242128ac0fa4f0ea9551ba21ad641377f7187353803eda3498f5e67964c137f69bfa60bbb0e07
    HEAD_REF experimental
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