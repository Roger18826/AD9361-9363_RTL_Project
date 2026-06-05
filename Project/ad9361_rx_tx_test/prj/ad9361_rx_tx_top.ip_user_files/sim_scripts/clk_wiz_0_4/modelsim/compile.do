vlib modelsim_lib/work
vlib modelsim_lib/msim

vlib modelsim_lib/msim/xil_defaultlib

vmap xil_defaultlib modelsim_lib/msim/xil_defaultlib

vlog -work xil_defaultlib  -incr "+incdir+../../../ipstatic" \
"../../../../ad9361_rx_tx_top.gen/sources_1/ip/clk_wiz_0_4/clk_wiz_0_clk_wiz.v" \
"../../../../ad9361_rx_tx_top.gen/sources_1/ip/clk_wiz_0_4/clk_wiz_0.v" \


vlog -work xil_defaultlib \
"glbl.v"

