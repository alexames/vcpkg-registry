# Source-distribution port for the VST3 SDK.
# Downloads the SDK and all submodules, assembles them, and installs the
# complete source tree. Consumers use add_subdirectory() on the installed
# source, preserving all SDK cmake macros (smtg_add_vst3plugin, etc.).

set(VERSION v3.8.0_build_66)

vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO steinbergmedia/vst3sdk
  REF ${VERSION}
  SHA512 7dd3483420abd79ee6dcb9db16663fb4e4d448e4243f8b905600ca871593701e66da97badaf3d723aafa1321cf72cbc013066ea8177a9497ab740fd98171efa3
  HEAD_REF master
)

# --- Submodule: base ---
vcpkg_from_github(
  OUT_SOURCE_PATH BASE_SOURCE_PATH
  REPO steinbergmedia/vst3_base
  REF ${VERSION}
  SHA512 be67019cd63f9f37fd541806f29e5e95899fba29153515048080e7d08aa397061d253d9f3de54d49303c99a36d197fd53fe9b54074e54092332020e4d4c845c8
  HEAD_REF master
)
file(REMOVE_RECURSE "${SOURCE_PATH}/base")
file(RENAME "${BASE_SOURCE_PATH}" "${SOURCE_PATH}/base")

# --- Submodule: cmake ---
vcpkg_from_github(
  OUT_SOURCE_PATH CMAKE_SOURCE_PATH
  REPO steinbergmedia/vst3_cmake
  REF ${VERSION}
  SHA512 b138ac696eb8f4f4ac2b28708972fabec576b7958c5ce74a94068c3a4ec3b2648ca992b4646529eff076efbc7c66bb335d9d883ce245df0e949bad76eafac7ac
  HEAD_REF master
)
file(REMOVE_RECURSE "${SOURCE_PATH}/cmake")
file(RENAME "${CMAKE_SOURCE_PATH}" "${SOURCE_PATH}/cmake")

# --- Submodule: doc ---
vcpkg_from_github(
  OUT_SOURCE_PATH DOC_SOURCE_PATH
  REPO steinbergmedia/vst3_doc
  REF ${VERSION}
  SHA512 d211bd475fa6f3fd1e0b12bfc592ceff6867d1e62bc7e7e816b88f12fa7c3eb7357b08d753eadd53c409135518e944a836b628e2af78ca6271322636e967f21f
  HEAD_REF master
)
file(REMOVE_RECURSE "${SOURCE_PATH}/doc")
file(RENAME "${DOC_SOURCE_PATH}" "${SOURCE_PATH}/doc")

# --- Submodule: pluginterfaces ---
vcpkg_from_github(
  OUT_SOURCE_PATH PLUGINTERFACES_SOURCE_PATH
  REPO steinbergmedia/vst3_pluginterfaces
  REF ${VERSION}
  SHA512 199a928e834f9ec50247305bd759a14135c7e4c88767867feae402f37edc38cc148b06e3f5b4d7d18812a1fb885eb09c6619ffc80bb2b5d951b77951b660d476
  HEAD_REF master
)
file(REMOVE_RECURSE "${SOURCE_PATH}/pluginterfaces")
file(RENAME "${PLUGINTERFACES_SOURCE_PATH}" "${SOURCE_PATH}/pluginterfaces")

# --- Submodule: public.sdk ---
vcpkg_from_github(
  OUT_SOURCE_PATH PUBLIC_SDK_SOURCE_PATH
  REPO steinbergmedia/vst3_public_sdk
  REF ${VERSION}
  SHA512 248b62ab7fa26e81aa306c38aed657c1ca738caac53d3aa9d1c2076997bad2ccb21abce1f77d6adb4fe7f53c6e51e2757ef2ce4a72db1f68d9c286947efd20c0
  HEAD_REF master
)
file(REMOVE_RECURSE "${SOURCE_PATH}/public.sdk")
file(RENAME "${PUBLIC_SDK_SOURCE_PATH}" "${SOURCE_PATH}/public.sdk")

# --- Install the assembled source tree ---
file(INSTALL "${SOURCE_PATH}/" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}/src")

# --- Generate a config file that provides vst3sdk_SOURCE_DIR ---
file(WRITE "${CURRENT_PACKAGES_DIR}/share/${PORT}/vst3sdkConfig.cmake" [=[
get_filename_component(vst3sdk_SOURCE_DIR "${CMAKE_CURRENT_LIST_DIR}/src" ABSOLUTE CACHE)
]=])

# --- License ---
file(
  INSTALL "${SOURCE_PATH}/LICENSE.txt"
  DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}"
  RENAME copyright)

# This is a source-only port — no compiled binaries to install.
set(VCPKG_POLICY_EMPTY_INCLUDE_FOLDER enabled)
set(VCPKG_POLICY_DLLS_NOT_FOUND enabled)
set(VCPKG_POLICY_EMPTY_PACKAGE enabled)
