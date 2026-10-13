FPGA IR Remote to LCD Decoder (Terasic DE2-115)
A complete hardware-level implementation of an NEC Infrared Protocol decoder and an HD44780 16x2 LCD controller written in Verilog.
This project allows a user to point a standard IR remote at the Terasic DE2-115 FPGA board, decode the invisible light pulses into hexadecimal commands, and display the corresponding characters on the built-in LCD screen. It features a custom state machine that manages LCD initialization, memory addressing (DDRAM), custom pixel-art character generation (CGRAM), and real-time hardware debugging using the onboard LEDs.
Features
NEC Protocol Decoding: Accurately decodes 32-bit pulse-distance IR signals using a custom hardware stopwatch logic block.
HD44780 LCD Controller: A multi-state event manager that initializes the LCD, enables the blinking cursor, and manages read/write timing without relying on external microcontrollers or Nios II processors.
Dynamic Row Switching: Uses DDRAM addressing (`8'h80` and `8'hC0`) to toggle the cursor between the top and bottom rows via a dedicated remote button.
Custom Character Generation: Writes custom 5x8 pixel art (like a smiley face) directly into the LCD's CGRAM memory during the boot sequence.
Live Hardware Debugging: Routes the raw 8-bit IR command directly to the 8 Green LEDs (`LEDG`), allowing you to instantly map any third-party NEC remote by reading the binary output.
Hardware Requirements
Board: Terasic DE2-115 (Altera Cyclone IV)
Input: Onboard IR Receiver (or compatible 38kHz IR module)
Output: Built-in 16x2 Character LCD
Remote: Stock Terasic IR Remote (or any NEC-protocol remote)
Project Architecture
The project is split into two primary Verilog modules running on a 50 MHz clock:
1. `ir_decode.v`
Acts as a continuous hardware stopwatch. It measures the microsecond gaps between infrared light pulses, identifying the 9ms lead code, extracting the 1s and 0s based on pulse distance, and outputting an 8-bit hex command once a full 32-bit packet is verified.
2. `remote.v` (Top-Level)
The master state machine. It handles the strict timing requirements of the LCD (waiting 2ms between commands, pulsing the `EN` pin).
States 0-3: Configures the LCD hardware (8-bit mode, display/cursor ON, clear screen).
States 4-13: Loads custom pixel-art characters into CGRAM.
State 14: The event loop. It waits for the `ir_ready` flag from the decoder, translates the hex code using a `case` statement, and pushes the ASCII character to the screen.
How to Map Your Own Remote
Every remote control manufacturer uses different internal hex codes. This project includes a built-in hardware debugger to map any NEC-compatible remote:
Upload the code to your FPGA.
Press a button on your remote (e.g., the "1" button).
Look at the 8 Green LEDs on the DE2-115 board. They will light up in a binary pattern (e.g., `01001000`).
Convert that binary pattern to Hexadecimal (e.g., `48`).
Open `remote.v`, find the `case(ir_cmd)` block, and update the mapping:
```verilog
   8'h48: begin led_rs <= 1; data <= "1"; end
   ```
Pin Assignments (Quartus TCL)
To run this project, assign the following pins in Intel Quartus Prime for the DE2-115 board:
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
Getting Started
Clone this repository.
Open Intel Quartus Prime and create a new project targeting the Cyclone IV E (EP4CE115F29C7).
Add the `.v` files to your project.
Go to Tools > Tcl Scripts... and run the pin assignment script.
Compile the design (`Ctrl + L`).
Open the Programmer, connect your DE2-115 via USB Blaster, and upload the `.sof` file.
