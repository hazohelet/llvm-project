//===-- CPUX.td - Describe the CPUX Target Machine ------*- tablegen -*-===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//


//===----------------------------------------------------------------------===//
// This is the top level entry point for the CPUX target.
//===----------------------------------------------------------------------===//

include "llvm/Target/Target.td"

def : ProcessorModel<"cpux-rv32", NoSchedModel, []>;

//===----------------------------------------------------------------------===//
// Target-dependent interfaces
//===----------------------------------------------------------------------===//

include "CPUXRegisterInfo.td"
include "CPUXSchedule.td"
include "CPUXInstrInfo.td"
include "CPUXCallingConv.td"

def CPUXInstrInfo : InstrInfo;

def CPUX: Target {
  let InstructionSet = CPUXInstrInfo;
}
