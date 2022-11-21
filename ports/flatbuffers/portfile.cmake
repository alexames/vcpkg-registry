vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO alexames/flatbuffers
    REF 9e93dfa38e57803956896b1391ec95032e9c8d39
    SHA512 36e47f145a5bab7870119e061847c107dab05ec2d6de809225e3f9045ebc1aa58524db8edc2a8a38ec762a6bbab27ca862f548bf11a0c87b8844b87f2b9704e2
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
file(INSTALL "${SOURCE_PATH}/LICENSE.txt" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
