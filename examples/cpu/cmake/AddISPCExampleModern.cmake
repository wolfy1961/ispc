#
#  Copyright (c) 2018-2026, Intel Corporation
#
#  SPDX-License-Identifier: BSD-3-Clause

#
# ispc ADDISPCTest.cmake
#

function(add_single_ispc_example name full_lto thin_lto)
    add_executable(${name})
    target_sources(${name}
        PRIVATE
            "${CMAKE_CURRENT_SOURCE_DIR}/${ISPC_SRC_NAME}.ispc"
            ${example_TARGET_SOURCES}
        )

    set_property(TARGET ${name} PROPERTY POSITION_INDEPENDENT_CODE ON)
    set_property(TARGET ${name} PROPERTY ISPC_INSTRUCTION_SETS "${ISPC_TARGETS}")
    target_compile_options(${name} PRIVATE $<$<COMPILE_LANGUAGE:ISPC>:${example_ISPC_FLAGS}>)
    target_compile_options(${name} PRIVATE $<$<COMPILE_LANGUAGE:ISPC>:--arch=${ISPC_ARCH}>)
    if (${full_lto})
        target_compile_options(${name} PRIVATE $<$<COMPILE_LANGUAGE:C,CXX>:-flto=full>)
        target_compile_options(${name} PRIVATE $<$<COMPILE_LANGUAGE:ISPC>:--lto=full>)
    endif()
    if (${thin_lto})
        target_compile_options(${name} PRIVATE $<$<COMPILE_LANGUAGE:C,CXX>:-flto=thin>)
        target_compile_options(${name} PRIVATE $<$<COMPILE_LANGUAGE:ISPC>:--lto=thin>)
    endif()

    if (UNIX)
        if ("${ISPC_ARCH}" MATCHES "x86")
            set(arch_flag "-m${ISPC_ARCH_BIT}")
            target_compile_options(${name} PRIVATE $<$<COMPILE_LANGUAGE:C,CXX>:${arch_flag}>)
        endif()
    elseif (WIN32 AND MSVC)
        target_compile_options(${name} PRIVATE  $<$<COMPILE_LANGUAGE:C,CXX>:/fp:fast /Oi>)
    endif()

    if (example_USE_COMMON_SETTINGS)
        find_package(Threads)
        target_sources(${name} PRIVATE ${EXAMPLES_ROOT}/common/tasksys.cpp)
        target_sources(${name} PRIVATE ${EXAMPLES_ROOT}/common/timing.h)
        target_link_libraries(${name} PRIVATE Threads::Threads)
    endif()

    # Link libraries
    if (example_LIBRARIES)
        target_link_libraries(${name} ${example_LIBRARIES})
    endif()

    set_target_properties(${name} PROPERTIES FOLDER "Examples")
    if(MSVC)
        # Group ISPC files inside Visual Studio
        source_group("ISPC" FILES "${CMAKE_CURRENT_SOURCE_DIR}/${ISPC_SRC_NAME}.ispc")
    endif()


    # Add ctest test for this example
    if(example_RUN_ARGS)
        add_test(NAME ${name}
                 COMMAND $<TARGET_FILE:${name}> ${example_RUN_ARGS}
                 WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR})
    else()
        add_test(NAME ${name}
                 COMMAND $<TARGET_FILE:${name}>
                 WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR})
    endif()

    # Set test properties
    set_tests_properties(${name} PROPERTIES
        TIMEOUT 300  # 5 minute timeout
        LABELS "cpu_example"
    )

    # Install example
    # We do not need to include examples binaries to the package
    if (NOT ISPC_PREPARE_PACKAGE)
        install(TARGETS ${name} RUNTIME DESTINATION examples/${name})
        if (example_DATA_FILES)
            install(FILES ${example_DATA_FILES}
                    DESTINATION examples/${name})
        endif()

        if (example_DATA_DIR)
            install(DIRECTORY ${example_DATA_DIR}
                    DESTINATION examples/${name})
        endif()
    endif()
endfunction()

function(add_ispc_example)
    set(options USE_COMMON_SETTINGS USE_FULL_LTO USE_THIN_LTO)
    set(oneValueArgs NAME ISPC_SRC_NAME DATA_DIR)
    set(multiValueArgs ISPC_IA_TARGETS ISPC_ARM_TARGETS ISPC_PPC64LE_TARGETS ISPC_FLAGS TARGET_SOURCES LIBRARIES DATA_FILES RUN_ARGS)
    cmake_parse_arguments("example" "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN} )

    if ("${ISPC_ARCH}" MATCHES "x86")
        string(REPLACE "," ";" ISPC_TARGETS ${example_ISPC_IA_TARGETS})
    elseif ("${ISPC_ARCH}" STREQUAL "arm" OR "${ISPC_ARCH}" STREQUAL "aarch64")
        string(REPLACE "," ";" ISPC_TARGETS ${example_ISPC_ARM_TARGETS})
    elseif ("${ISPC_ARCH}" STREQUAL "ppc64le")
        if (example_ISPC_PPC64LE_TARGETS)
            string(REPLACE "," ";" ISPC_TARGETS ${example_ISPC_PPC64LE_TARGETS})
        else()
            set(ISPC_TARGETS "generic-i32x4")
        endif()
    else()
        message(FATAL_ERROR "Unknown architecture ${ISPC_ARCH}")
    endif()

    add_single_ispc_example(${example_NAME} false false)
    if (example_USE_FULL_LTO)
        add_single_ispc_example(${example_NAME}_flto true false)
    endif()
    if (example_USE_THIN_LTO)
        add_single_ispc_example(${example_NAME}_tlto false true)
    endif()
endfunction()
