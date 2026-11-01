// RAWR_NATIVE_AGENT_BUILD_001 - Minimal certification driver v2
// Uses RawrXD's own CoffWriter to emit a COFF object that returns 42 directly
// (no external imports needed), then rawrxd_link.exe produces a PE executable.
//
// Build (stage-0 MSVC bootstrap only):
//   cl.exe /nologo /EHsc /O2 /I"F:\rawrxd\compilers\native_compiler\src" ^
//          /I"F:\rawrxd\compilers\native_compiler\rawrstd\include" ^
//          cert_driver.cpp CoffWriter.cpp SourceManager.cpp Diagnostics.cpp ^
//          Token.cpp rawrstd\src\sha256.cpp rawrstd\src\string.cpp rawrstd\src\sys.cpp

#include "common/Diagnostics.h"
#include "common/SourceManager.h"
#include "object/CoffWriter.h"

#include <cstdio>

using namespace rawr;

int main(int argc, char **argv) {
    SourceManager sources;
    DiagnosticEngine diags(&sources);

    // Create a minimal COFF object that returns 42 directly (no imports)
    CoffWriter writer;

    // .text section: x64 machine code: mov eax, 42; ret
    uint8_t code[] = { 0xB8, 0x2A, 0x00, 0x00, 0x00,  // mov eax, 42
                       0xC3 };                         // ret

    const uint32 kAlign16 = 0x00500000;
    int text_sec = writer.add_section(".text",
        kScnCntCode | kScnMemExecute | kScnMemRead,
        kAlign16);
    writer.append_data(text_sec, code, sizeof(code));

    // Symbols: .file, entry
    writer.add_symbol(CoffSymbol::file("cert_driver.c"));
    writer.add_symbol(CoffSymbol::external("entry", 1, 0, true));

    // Write the object
    const char *out_path = argc > 1 ? argv[1] : "cert_ret42.obj";
    if (!writer.write(out_path)) {
        fprintf(stderr, "Failed to write COFF object: %s\n", out_path);
        return 1;
    }

    fprintf(stderr, "COFF object written: %s\n", out_path);
    return 0;
}
