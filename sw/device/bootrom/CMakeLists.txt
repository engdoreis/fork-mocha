# Copyright lowRISC contributors.
# Licensed under the Apache License, Version 2.0, see LICENSE for details.
# SPDX-License-Identifier: Apache-2.0

set(NAME bootrom)
add_executable(${NAME} bootrom.c)
target_link_libraries(${NAME} hal_vanilla runtime_vanilla startup_vanilla)
target_compile_options(${NAME} PUBLIC ${VANILLA_FLAGS})
target_link_options(${NAME} PUBLIC 
  "-nodefaultlibs"
  "-T${CMAKE_CURRENT_SOURCE_DIR}/rom.ld"
  "-L${LDS_DIR}"
)

add_custom_command(
    TARGET ${NAME} POST_BUILD
    COMMAND ${CMAKE_OBJDUMP} ${OBJDUMP_FLAGS} "$<TARGET_FILE:${NAME}>"
            > "$<TARGET_FILE:${NAME}>.dump"

    COMMAND ${CMAKE_OBJCOPY} -O binary
      -R .bss -R .stack  # already excluded (NOBITS), but for clarity
      --only-section=.init_vectors
      --only-section=.text
      --only-section=.rodata
      --only-section=__cap_relocs
      --only-section=.data   # LMA is in ROM, objcopy uses LMA when --only-section forces i
      --only-section=.got
      "$<TARGET_FILE:${NAME}>"
      "$<TARGET_FILE:${NAME}>.bin"

    COMMAND srec_cat "$<TARGET_FILE:${NAME}>.bin" -binary -byte-swap 4
      -o "$<TARGET_FILE:${NAME}>.vmem" -vmem 32

    VERBATIM
)

install(TARGETS ${NAME})
