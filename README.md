This project is entirely written in Verilog,The single-tone signal is transmitted from TX and received at RX.

1. If your board is different from mine, the code cannot be directly burned and the constraints need to be changed according to the board you are using
2. If your board has hardware reset, you can delete the software reset in the code
3. The configuration mode is LVDS single transmit single receive
4. The VS Code used for code editing, if the comments are garbled, please change the characters to GBK national standard 2312 display (Chinese)
   
You first need to install the official register configuration software: AD936x Evaluation Software. After the configuration is completed, it will generate a. txt file containing the configuration details of the AD9361/9363 registers. The. txt file cannot be directly used in FPGA. Then, in the Tool/s folder, there is a Python script file that I wrote for converting register configurations. The code is relatively simple, and you can modify it according to your own needs. If the configuration is the same as mine with a 1T1R 40M system clock, LVDS, Spi read, 2G RF transceiver, please follow the correct process to operate.

## Experimental Results
![ILA actual measurement effect diagram](./img/2.jpg)

![baseband receiving waveform](./img/1.jpg)

