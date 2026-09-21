vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO alexames/flatbuffers-request
    REF 208451ef07d9f733e5b7e78ee59fd43250a09dca
    SHA512 b16865234b761ad58e59191b258d8646ed4b9da7ff5856f78eecb953821b734de9d7098eb3779039c503ac021d2b4ea5c88279a6bddf9c9d1baeac3a226775ee
    HEAD_REF main
)

vcpkg_check_features(
    OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        tools FBREQUEST_BUILD_TOOLS
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DFBREQUEST_BUILD_TESTS=OFF
        -DFBREQUEST_BUILD_FUZZERS=OFF
        -DFBREQUEST_INSTALL=ON
        ${FEATURE_OPTIONS}
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(
    PACKAGE_NAME FlatbuffersRequest
    CONFIG_PATH lib/cmake/FlatbuffersRequest
)

# Relocate the CLI (when the tools feature is on) from bin/ to tools/<port>/.
if("tools" IN_LIST FEATURES)
    vcpkg_copy_tools(TOOL_NAMES fbrequest AUTO_CLEAN)
endif()

# A static library ships no headers or cmake config in the debug tree.
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
