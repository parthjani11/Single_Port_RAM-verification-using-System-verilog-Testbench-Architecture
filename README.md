# Single-Port RAM — Functional Verification

A SystemVerilog testbench built to verify an 8-bit wide, 32-location deep Single-Port RAM, simulated using Mentor Questa.

## What This Project Does

- Implements a layered, transaction-based verification environment (generator, driver, monitor, reference model, scoreboard)
- Applies constrained-random and directed stimulus to the RAM design
- Automatically compares actual vs. expected results using a scoreboard
- Achieved 100% functional coverage and 100% code coverage on the design
- Found 2 functional bugs in the DUT during verification

## Project Structure

```
.
├── Design/          # RAM design (DUT)
├── Testbench Codes/           # Testbench files
└── report/         # Verification report
```

## Running the Simulation

```bash
vlog -sv +acc +cover +fcover ram_rtl.sv ram_if.sv ram_package.sv top.sv
vsim -vopt work.top -coverage -c -do "run -all; exit"
vcover report -html a.ucdb -htmldir covReport -details
```

## Author

Parth Jani — 6916 — Mirafra Software Technologies
