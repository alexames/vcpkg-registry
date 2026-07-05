vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO alexames/flatbuffers-request
    REF 36c44b83fd41bac4f3afed6fb3989c582239a290
    SHA512 fc152fa1f78e4df7045322272d8805162ea41a97157b3ced5869719f869b64a53bd321e00d61a78a60fa600dc09e4679d7777e72d3e81d89a06bc017c16b9791
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
