Components:
	FPGA Nexys-A7, Part: xc7a100tcsg324-3
	Pmod OLEDrgb: 96 x 64 RGB OLED Display with 16-bit Color Resolution (SPI)
	Pmod COLOR: Color Sensor Module (I2C)
	Pmod KYPD: 16-button Keypad
	Pmod ENC: Rotary Encoder

Placement of the componets on the board is specified in the pins.xdc

Software used for development: Xilinx vivado 2014

Quick Steps:
1> Programm the FPGA
2> Press the CPU_RESET button to initialize the design
3> The memory module already contains hard-coded instructions, if you wish you can modify it (referance: IS.txt file).
4> Compile the script (sw[2:1] = 01 and BTNL = press)
5> Run a command at a time (sw[2:1] = 10 and BTNR = press), it first runs the command located at MEM[7]
