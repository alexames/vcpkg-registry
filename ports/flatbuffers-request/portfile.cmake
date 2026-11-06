vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO alexames/flatbuffers-request
    REF d667f7fdbd82bea1750105c5507fbd602274ec56
    SHA512 9a91181a1f53a7bd86c21d986efcff3b8cb990f0e13dfe7a74b48740a3ea461b61ec7dae0f5805999de58bfb0fa4d661cc20ea7708ae5689fbc3b5711519f79b
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
