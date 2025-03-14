# rv32i-bachelor
A scan-testable RISC-V core implementation (instruction decoder and register file) using SystemVerilog
Implementation directly inspired from the [bit-spinner](https://www.bit-spinner.com/rv32i/rv32i-introduction) website.
This project aims to improve upon the implementation with SystemVerilog syntax + add scan-testability.

## Project Structure
- src: directory for all rv32i modules.
- tb: testbenches for those modules.
- sim: simulation files to be run with gtkwave.

## Block Diagram of the Architecture
![Block-Diagram](https://www.bit-spinner.com/static/images/RV32I-Single-Cycle-Archv2.svg)
