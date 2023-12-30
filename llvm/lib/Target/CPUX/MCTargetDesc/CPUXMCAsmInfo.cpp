#include "CPUXMCAsmInfo.h"

#include "llvm/TargetParser/Triple.h"

using namespace llvm;

void CPUXMCAsmInfo::anchor() {}

CPUXMCAsmInfo::CPUXMCAsmInfo(const Triple &TheTriple) {
  AlignmentIsInBytes = true;
  Data16bitsDirective = "  .2byte  ";
  Data32bitsDirective = "  .4byte  ";
  Data64bitsDirective = "  .8byte  ";
  PrivateGlobalPrefix = ".";
  PrivateLabelPrefix = ".";
  CommentString = "#";
  ZeroDirective = "  .space  ";
  GPRel32Directive = "  .gpword  ";
  GPRel64Directive = "  .gpdword  ";
  WeakRefDirective = "  .weak  ";
  UseAssignmentForEHBegin = true;

  SupportsDebugInformation = true;
  DwarfRegNumForCFI = true;
}
