# ephemeral (iOS LLDB helper)

## Overview
Flutter-tool-generated debugger support for iOS. `flutter_lldb_helper.py` is headed "Generated file, do not edit." The directory also holds `flutter_lldbinit`, which is not a source file.

## Interface
- `flutter_lldb_helper.py`: `handle_new_rx_page(frame, bp_loc, extra_args, intern_dict)` and `__lldb_init_module(debugger, _)`.
- `__lldb_init_module` sets a regex breakpoint on `^NOTIFY_DEBUGGER_ABOUT_RX_PAGES$` on the dummy target, attaches `handle_new_rx_page` as its script callback, and enables auto-continue.

## Invariants
- The breakpoint must be created with `BreakpointCreateByRegex`; the in-code comment says `BreakpointCreateByName` loses the callback when carried over from the dummy target.
- `handle_new_rx_page` reads `x0` (page base) and `x1` (length), and writes `b'IHELPED!'` into the first 8 bytes of the page buffer.

## Side Effects
- Writes process memory in the debugged process (`SBProcess.WriteMemory`) and prints a failure message on error.
- Prints `-- LLDB integration loaded --` on module load.

## Verification
- None: no test command exists for this generated helper.
