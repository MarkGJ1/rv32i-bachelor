# rv32i-bachelor
A scan-testable RISC-V core implementation (instruction decoder and register file) using SystemVerilog. 
Meets the criteria for full scan injections with ATPG capable software such as Cadence's.
Uses one clock and one reset signal throughout the design.

## Project Structure
- docs: documentation and bachelor thesis.
- sim:  simulation files to be run with gtkwave.
- src:  directory for all rv32i modules and TAP.
- tb:   testbenches for those modules.

## Block Diagram of the Architecture
![Block-Diagram](https://www.bit-spinner.com/static/images/RV32I-Single-Cycle-Archv2.svg)
