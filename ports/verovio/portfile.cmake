vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO rism-digital/verovio
  REF 43f806031bfff2c64003fc8ddd9910820445f6ab
  SHA512 7125eb46a66ba6c666b9abbfae47159b8a5077dde494a59061787100a48b43150c74361d0ce4cc3f618e10930094dd8ca2eccc924ee9ad5101736ca8ebb7fd73
  HEAD_REF develop
)

# The buildable CMake project lives in the cmake/ subdirectory, not the repo
# root. BUILD_AS_LIBRARY produces a shared library; on Windows the symbols are
# only exported when CMAKE_WINDOWS_EXPORT_ALL_SYMBOLS is set as a CMake
# variable (the compile definition upstream adds is not enough).
vcpkg_cmake_configure(
  SOURCE_PATH "${SOURCE_PATH}/cmake"
  OPTIONS
    -DBUILD_AS_LIBRARY=ON
    -DCMAKE_WINDOWS_EXPORT_ALL_SYMBOLS=TRUE
)
vcpkg_cmake_install()
vcpkg_fixup_pkgconfig()

# Upstream's data install rule only matches *.xml/*.svg/*.css; the runtime
# resource directory also needs the .json files (e.g. tuning-glyphnames.json),
# so mirror the whole directory into share/verovio.
file(COPY "${SOURCE_PATH}/data/" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")

file(REMOVE_RECURSE
  "${CURRENT_PACKAGES_DIR}/debug/include"
  "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING" "${SOURCE_PATH}/COPYING.LESSER")
