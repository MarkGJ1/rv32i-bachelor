# rv32i-bachelor
A scan-testable RISC-V core implementation (instruction decoder and register file) using SystemVerilog

The TAP module implementation is guided through: L.-T. Wang, C.-W. Wu, and X. Wen, VLSI Test Principles and Architectures: Design for Testability.
San Francisco, CA, USA: Morgan Kaufmann Publishers Inc., 2006, ISBN: 9780080474793.

## Project Structure
- src: directory for all rv32i modules and TAP.
- tb: testbenches for those modules.
- sim: simulation files to be run with gtkwave.

## Block Diagram of the Architecture
![Block-Diagram](https://www.bit-spinner.com/static/images/RV32I-Single-Cycle-Archv2.svg)
