#include "pelf.h"

#include <elf.h>
#include <errno.h>
#include <fcntl.h>
#include <stddef.h>
#include <stdio.h>
#include <stdlib.h>
#include <sys/mman.h>
#include <sys/stat.h>
#include <unistd.h>

#include "bintools/elf.h"
int main([[maybe_unused]] int argc, [[maybe_unused]] char **argv) {
    int fd = {};
    struct stat file_stats = {};
    const void *bytes = {};
    int ret = {};
    struct elf elf_file = {};

    if (argc < 2) usage(argv[0]);

    if ((fd = open(argv[1], O_RDONLY)) == -1) {
        ret = errno;
        perror("open");
        goto cleanup;
    }

    if (fstat(fd, &file_stats) == -1) {
        ret = errno;
        perror("fstat");
        goto cleanup;
    }

    if ((bytes = mmap(nullptr, file_stats.st_size, PROT_READ, MAP_PRIVATE, fd,
                      0)) == MAP_FAILED) {
        ret = errno;
        perror("mmap");
        goto cleanup;
    }

    if (elf_init(&elf_file, bytes) != ok) {
        [[maybe_unused]] auto bytes = fprintf(stderr, "Invalid ELF file\n");
        goto cleanup;
    }

    ret = EXIT_SUCCESS;
cleanup:
    close(fd);
    munmap((void *)bytes, 0);
    elf_deinit(&elf_file);
    return ret;
}

[[noreturn]] void usage(const char *progname) {
    [[maybe_unused]] auto bytes_written =
        fprintf(stderr, "Usage: %s <path>\n", progname);
    exit(EXIT_FAILURE);
}
