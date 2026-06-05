// Copyright 1986-2020 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2020.2 (win64) Build 3064766 Wed Nov 18 09:12:45 MST 2020
// Date        : Thu Nov 21 12:20:51 2024
// Host        : DESKTOP-RF1VT5Q running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode synth_stub
//               c:/Users/ASUS/Desktop/SDR/ad9361_rx_tx_test/prj/ad9361_rx_tx_top.gen/sources_1/ip/ila_0_12/ila_0_stub.v
// Design      : ila_0
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7z020clg400-2
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
(* X_CORE_INFO = "ila,Vivado 2020.2" *)
module ila_0(clk, probe0, probe1, probe2, probe3, probe4, probe5, 
  probe6, probe7, probe8, probe9)
/* synthesis syn_black_box black_box_pad_pin="clk,probe0[11:0],probe1[11:0],probe2[11:0],probe3[11:0],probe4[3:0],probe5[0:0],probe6[0:0],probe7[31:0],probe8[3:0],probe9[0:0]" */;
  input clk;
  input [11:0]probe0;
  input [11:0]probe1;
  input [11:0]probe2;
  input [11:0]probe3;
  input [3:0]probe4;
  input [0:0]probe5;
  input [0:0]probe6;
  input [31:0]probe7;
  input [3:0]probe8;
  input [0:0]probe9;
endmodule
