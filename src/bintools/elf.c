#include <bintools/elf.h>
#include <stdio.h>

enum elf_error elf_init(struct elf *elf_data, const void *const data) {
    const auto magic = (unsigned char *)data;
    if (magic[EI_MAG0] != ELFMAG0 || magic[EI_MAG1] != ELFMAG1 ||
        magic[EI_MAG2] != ELFMAG2 || magic[EI_MAG3] != ELFMAG3)
        return invalid_magic;

    elf_data->executable_header = *(Elf64_Ehdr *)data;
    printf("header size: %d\n", elf_data->executable_header.e_ehsize);

    return ok;
}

void elf_deinit([[maybe_unused]] struct elf *elf_file) {}
