#pragma once

#include <elf.h>

enum elf_error : int { ok, invalid_magic };

struct elf {
    Elf64_Ehdr executable_header;
};

[[nodiscard("elf header")]] enum elf_error elf_init(struct elf *, const void *);
void elf_deinit(struct elf *);
