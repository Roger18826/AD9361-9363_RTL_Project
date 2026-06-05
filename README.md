This project is entirely written in Verilog,The single-tone signal is transmitted from TX and received at RX.

1. If your board is different from mine, the code cannot be directly burned and the constraints need to be changed according to the board you are using
2. If your board has hardware reset, you can delete the software reset in the code
3. The configuration mode is LVDS single transmit single receive
4. The VS Code used for code editing, if the comments are garbled, please change the characters to GBK national standard 2312 display (Chinese)
   
To configure the AD9361/9363, first install the official AD936x Evaluation Software, which generates a register configuration .txt file. This file cannot be directly used in FPGA.

I have provided a Python conversion script in the Tool/ directory to translate the register configuration into an FPGA-compatible format. You can modify the script for your own needs.

For the reference design (1T1R, 40MHz clock, LVDS, SPI read, 2GHz RF), you may follow the standard operation flow directly.

## Experimental Results
![ILA actual measurement effect diagram](./img/2.jpg)

![baseband receiving waveform](./img/1.jpg)

