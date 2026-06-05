vlib modelsim_lib/work
vlib modelsim_lib/msim

vlib modelsim_lib/msim/xil_defaultlib

vmap xil_defaultlib modelsim_lib/msim/xil_defaultlib

vlog -work xil_defaultlib  -incr "+incdir+../../../../ad9361_rx_tx_top.gen/sources_1/ip/ila_1_2/hdl/verilog" \
"../../../../ad9361_rx_tx_top.gen/sources_1/ip/ila_1_2/sim/ila_1.v" \


vlog -work xil_defaultlib \
"glbl.v"

