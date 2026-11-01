// RAWR_MASM_X64_ASSEMBLER - Standalone MASM x64 assembler driver
// Uses RawrXD's own X64Assembler to assemble MASM-style source into COFF objects.
//
// Build (stage-0 MSVC bootstrap only):
//   cl.exe /nologo /EHsc /O2 /I"F:\rawrxd\compilers\native_compiler\src" ^
//          /I"F:\rawrxd\compilers\native_compiler\rawrstd\include" ^
//          /Fe"G:\~dev\rawrxd\rawrxd_asm.exe" ^
//          masm_driver.cpp ^
//          F:\rawrxd\compilers\native_compiler\src\asm\X64Assembler.cpp ^
//          F:\rawrxd\compilers\native_compiler\src\object\CoffWriter.cpp ^
//          F:\rawrxd\compilers\native_compiler\src\common\Diagnostics.cpp ^
//          F:\rawrxd\compilers\native_compiler\src\common\SourceManager.cpp ^
//          F:\rawrxd\compilers\native_compiler\src\frontend\Token.cpp ^
//          F:\rawrxd\compilers\native_compiler\rawrstd\src\sha256.cpp ^
//          F:\rawrxd\compilers\native_compiler\rawrstd\src\string.cpp ^
//          F:\rawrxd\compilers\native_compiler\rawrstd\src\sys.cpp

#include "asm/X64Assembler.h"
#include "common/Diagnostics.h"
#include "common/SourceManager.h"

#include <cstdio>
#include <cstdlib>

using namespace rawr;

int main(int argc, char **argv) {
    if (argc < 3) {
        fprintf(stderr, "Usage: rawrxd_asm <input.asm> <output.obj>\n");
        return 1;
    }

    const char *asmPath = argv[1];
    const char *objPath = argv[2];

    String error;
    if (!assembleX64File(asmPath, objPath, error)) {
        fprintf(stderr, "ASSEMBLY FAILED: %s\n", error.data());
        return 1;
    }

    fprintf(stderr, "ASSEMBLED OK: %s -> %s\n", asmPath, objPath);
    return 0;
}
