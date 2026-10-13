<div align="center">

# 📡 FPGA IR Remote to LCD Decoder
**Terasic DE2-115 (Altera Cyclone IV)**

[![Verilog](https://img.shields.io/badge/Language-Verilog-blue.svg)](https://en.wikipedia.org/wiki/Verilog)
[![Hardware](https://img.shields.io/badge/Board-DE2--115-orange.svg)]()
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](https://opensource.org/licenses/MIT)

> A complete hardware-level implementation of an NEC Infrared Protocol decoder and an HD44780 16x2 LCD controller—written entirely in Verilog without external microcontrollers.

</div>

<br />

## 📑 Table of Contents
- [Overview](#-overview)
- [Features](#-features)
- [Hardware Requirements](#-hardware-requirements)
- [System Architecture](#-system-architecture)
- [Mapping Custom Remotes](#-mapping-custom-remotes)
- [Pin Configuration](#-pin-configuration)
- [Getting Started](#-getting-started)

---

## 📖 Overview
This project allows a user to point a standard IR remote at a Terasic DE2-115 FPGA board, decode the invisible light pulses into hexadecimal commands, and display the corresponding characters on the built-in LCD screen. It handles its own strict timing requirements, custom character generation (CGRAM), and dynamic memory addressing (DDRAM).

---

## ✨ Features

* ⏱️ **True Hardware Decoding:** Accurately decodes 32-bit pulse-distance IR signals using a custom stopwatch logic block.
* 🖥️ **Standalone LCD Controller:** Initializes the screen, enables the blinking cursor, and manages read/write timing seamlessly.
* 🔄 **Dynamic Row Switching:** Toggles the LCD cursor between Row 1 (`8'h80`) and Row 2 (`8'hC0`) using a dedicated remote button.
* 👾 **Custom Pixel Art:** Writes custom 5x8 characters (e.g., smiley faces) directly into the LCD's CGRAM memory during boot.
* 🐛 **Live Hardware Debugging:** Routes the raw 8-bit IR command to the onboard Green LEDs for instant third-party remote mapping.

---

## 🛠 Hardware Requirements

| Component | Specification |
| :--- | :--- |
| **FPGA Board** | Terasic DE2-115 (Altera Cyclone IV `EP4CE115F29C7`) |
| **Clock** | 50 MHz Onboard Oscillator |
| **Input** | Built-in 38kHz IR Receiver |
| **Output** | Built-in HD44780-compatible 16x2 LCD & 8x Green LEDs |
| **Remote** | Stock Terasic IR Remote (or any NEC-protocol remote) |

---

## 🧩 System Architecture

The project is split into two primary Verilog modules, both synchronized to the 50 MHz system clock:

1. `ir_decode.v` **(The Stopwatch)**
   * Measures the microsecond gaps between infrared pulses.
   * Identifies the 9ms NEC lead code.
   * Extracts data bits based on pulse distance (short gap = `0`, long gap = `1`).
   * Outputs an 8-bit hex command when a valid 32-bit packet is received.

2. `remote.v` **(The Master State Machine)**
   * **States 0-3:** LCD Hardware Configuration (8-bit mode, display ON, clear screen).
   * **States 4-13:** CGRAM Custom Character Generation.
   * **State 14:** The Event Loop. Waits for the `ir_ready` flag, decodes the hex command, and pushes ASCII characters to the display.

---

## 🎮 Mapping Custom Remotes

Every remote uses different internal hexadecimal codes. This project includes a built-in LED debugger so you can easily map **any** NEC remote to the LCD.

**Step-by-step:**
1. Upload the project to your FPGA.
2. Press a button on your remote (e.g., the `1` button).
3. Read the **8 Green LEDs** on the board (e.g., `01001000`).
4. Convert that binary sequence to Hexadecimal (e.g., `48`).
5. Open `remote.v`, locate the `case(ir_cmd)` block, and update your mapping:

```verilog
case(ir_cmd)
    // Add your custom hex mappings here:
    8'h48: begin led_rs <= 1; data <= "1"; end 
    8'h49: begin led_rs <= 1; data <= "2"; end
    // ...
endcase
```

---

## 📌 Pin Configuration

Use the following TCL assignments in Intel Quartus Prime to map the hardware correctly:

```tcl
# System Clock (50 MHz)
set_location_assignment PIN_Y2 -to clk

# IR Receiver
set_location_assignment PIN_Y15 -to ir

# LCD Pins
set_location_assignment PIN_M5 -to data[7]
set_location_assignment PIN_M3 -to data[6]
set_location_assignment PIN_K2 -to data[5]
set_location_assignment PIN_K1 -to data[4]
set_location_assignment PIN_K7 -to data[3]
set_location_assignment PIN_L2 -to data[2]
set_location_assignment PIN_L1 -to data[1]
set_location_assignment PIN_L3 -to data[0]
set_location_assignment PIN_L4 -to en
set_location_assignment PIN_M1 -to rw
set_location_assignment PIN_M2 -to rs
set_location_assignment PIN_L5 -to onn
set_location_assignment PIN_L6 -to blon

# Debugging Green LEDs
set_location_assignment PIN_E21 -to LEDG[0]
set_location_assignment PIN_E22 -to LEDG[1]
set_location_assignment PIN_E25 -to LEDG[2]
set_location_assignment PIN_E24 -to LEDG[3]
set_location_assignment PIN_H21 -to LEDG[4]
set_location_assignment PIN_G20 -to LEDG[5]
set_location_assignment PIN_G22 -to LEDG[6]
set_location_assignment PIN_G21 -to LEDG[7]
```

---

## 🏁 Getting Started

1. **Clone the repository:**
   ```bash
   git clone https://github.com/YourUsername/FPGA-IR-LCD.git
   ```
2. Open **Intel Quartus Prime** and create a new project targeting `EP4CE115F29C7`.
3. Add `remote.v` and `ir_decode.v` to your project files.
4. Navigate to **Tools > Tcl Scripts...** and run your pin assignment script.
5. Compile the design (`Ctrl + L`).
6. Open the **Programmer**, connect your DE2-115 via USB Blaster, and upload the `.sof` file.