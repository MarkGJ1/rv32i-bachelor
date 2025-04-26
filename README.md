# rv32i-bachelor
A scan-testable RISC-V core implementation (instruction decoder and register file) using SystemVerilog

Implementation takes directly from the [bit-spinner](https://www.bit-spinner.com/rv32i/rv32i-introduction) website.
This project aims to improve upon the implementation with SystemVerilog syntax, address issues with the design and
add scan testability.

The TAP module implementation is guided through: L.-T. Wang, C.-W. Wu, and X. Wen, VLSI Test Principles and Architectures: Design for Testability.
San Francisco, CA, USA: Morgan Kaufmann Publishers Inc., 2006, ISBN: 9780080474793.

## Project Structure
- docs: documentation and bachelor thesis.
- sim:  simulation files to be run with gtkwave.
- src:  directory for all rv32i modules and TAP.
- tb:   testbenches for those modules.

## Block Diagram of the Architecture
![Block-Diagram](https://www.bit-spinner.com/static/images/RV32I-Single-Cycle-Archv2.svg)
