vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO google/flatbuffers
    REF 7e163021e59cca4f8e1e35a7c828b5c6b7915953
    SHA512 44144f67e8f35d1806a6c36a858ca559cd0d52750d136c56f540094de34f106eabd78622fdd894ecfea1c29f492e1ce33fa72760d7f9d9eaff8979e354b9b865
    HEAD_REF master
)

set(options "")
if(VCPKG_CROSSCOMPILING)
    list(APPEND options -DFLATBUFFERS_BUILD_FLATC=OFF -DFLATBUFFERS_BUILD_FLATHASH=OFF)
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DFLATBUFFERS_BUILD_TESTS=OFF
        -DFLATBUFFERS_BUILD_GRPCTEST=OFF
        ${options}
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/flatbuffers)
vcpkg_fixup_pkgconfig()

file(GLOB flatc_path ${CURRENT_PACKAGES_DIR}/bin/flatc*)
if(flatc_path)
    make_directory("${CURRENT_PACKAGES_DIR}/tools/flatbuffers")
    get_filename_component(flatc_executable ${flatc_path} NAME)
    file(
        RENAME
        ${flatc_path}
        ${CURRENT_PACKAGES_DIR}/tools/flatbuffers/${flatc_executable}
    )
    vcpkg_copy_tool_dependencies("${CURRENT_PACKAGES_DIR}/tools/flatbuffers")
else()
    file(APPEND "${CURRENT_PACKAGES_DIR}/share/flatbuffers/FlatbuffersConfig.cmake"
"include(\"\${CMAKE_CURRENT_LIST_DIR}/../../../${HOST_TRIPLET}/share/flatbuffers/FlatcTargets.cmake\")\n")
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")

# Handle copyright
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
