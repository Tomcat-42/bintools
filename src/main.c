#include <binz/binz.h>
#include <stdio.h>

static const unsigned char embed_main[] = {
#embed "src/main.c"
};

int main([[maybe_unused]] int argc, [[maybe_unused]] char **argv) {
    [[maybe_unused]] auto a = embed_main[10];
    printf("add(1, 2) = %d\n", binz_add(1, 2));
    printf("I am:\n %s\n", embed_main);
    return 0;
}
