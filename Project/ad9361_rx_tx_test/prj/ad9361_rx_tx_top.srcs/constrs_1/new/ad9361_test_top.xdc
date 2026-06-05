#时序约束
create_clock -period 25.000 -name sys_clk [get_ports sys_clk]
set_property -dict {PACKAGE_PIN J20 IOSTANDARD LVCMOS33} [get_ports {led[1]}]
set_property -dict {PACKAGE_PIN H20 IOSTANDARD LVCMOS33} [get_ports {led[0]}]
#IO引脚约束
#----------------------系统时钟---------------------------40mHZ 25ns
set_property -dict {PACKAGE_PIN H16 IOSTANDARD LVCMOS33} [get_ports sys_clk]
#----------------------SPI接口---------------------------
set_property -dict {PACKAGE_PIN R19 IOSTANDARD LVCMOS25} [get_ports spi_sdi]
set_property -dict {PACKAGE_PIN R14 IOSTANDARD LVCMOS25} [get_ports spi_clk]
set_property -dict {PACKAGE_PIN P18 IOSTANDARD LVCMOS25} [get_ports spi_csn]
#set_property PACKAGE_PIN P18 [get_ports spi_csn]
#set_property IOSTANDARD LVCMOS25 [get_ports spi_csn]
#set_property PULLUP true [get_ports spi_csn]
set_property -dict {PACKAGE_PIN P15 IOSTANDARD LVCMOS25} [get_ports spi_sdo]
#----------------------收发控制---------------------------
set_property -dict {PACKAGE_PIN P16 IOSTANDARD LVCMOS25} [get_ports en_agc]
set_property -dict {PACKAGE_PIN R18 IOSTANDARD LVCMOS25} [get_ports enable]
set_property -dict {PACKAGE_PIN P14 IOSTANDARD LVCMOS25} [get_ports txnrx]
set_property -dict {PACKAGE_PIN N17 IOSTANDARD LVCMOS25} [get_ports reset]
set_property -dict {PACKAGE_PIN U20 IOSTANDARD LVCMOS25} [get_ports sync_in]

set_property -dict {PACKAGE_PIN T10 IOSTANDARD LVCMOS25} [get_ports {ctrl_in[0]}]
set_property -dict {PACKAGE_PIN Y11 IOSTANDARD LVCMOS25} [get_ports {ctrl_in[1]}]
set_property -dict {PACKAGE_PIN V10 IOSTANDARD LVCMOS25} [get_ports {ctrl_in[2]}]
set_property -dict {PACKAGE_PIN U9 IOSTANDARD LVCMOS25} [get_ports {ctrl_in[3]}]

set_property -dict {PACKAGE_PIN T11 IOSTANDARD LVCMOS25} [get_ports {ctrl_out[0]}]
set_property -dict {PACKAGE_PIN T14 IOSTANDARD LVCMOS25} [get_ports {ctrl_out[1]}]
set_property -dict {PACKAGE_PIN T15 IOSTANDARD LVCMOS25} [get_ports {ctrl_out[2]}]
set_property -dict {PACKAGE_PIN T17 IOSTANDARD LVCMOS25} [get_ports {ctrl_out[3]}]
set_property -dict {PACKAGE_PIN T19 IOSTANDARD LVCMOS25} [get_ports {ctrl_out[4]}]
set_property -dict {PACKAGE_PIN T20 IOSTANDARD LVCMOS25} [get_ports {ctrl_out[5]}]
set_property -dict {PACKAGE_PIN U13 IOSTANDARD LVCMOS25} [get_ports {ctrl_out[6]}]
set_property -dict {PACKAGE_PIN V13 IOSTANDARD LVCMOS25} [get_ports {ctrl_out[7]}]

#----------------------接收数据---------------------------

set_property -dict {PACKAGE_PIN N20 IOSTANDARD LVDS_25 } [get_ports rx_clk_in_p]
set_property -dict {PACKAGE_PIN P20 IOSTANDARD LVDS_25 } [get_ports rx_clk_in_n]
set_property -dict {PACKAGE_PIN U18 IOSTANDARD LVDS_25 } [get_ports rx_frame_in_p]
set_property -dict {PACKAGE_PIN U19 IOSTANDARD LVDS_25 } [get_ports rx_frame_in_n]

set_property -dict {PACKAGE_PIN Y18 IOSTANDARD LVDS_25} [get_ports {rx_data_in_p[0]}]
set_property -dict {PACKAGE_PIN V17 IOSTANDARD LVDS_25} [get_ports {rx_data_in_p[1]}]
set_property -dict {PACKAGE_PIN V20 IOSTANDARD LVDS_25} [get_ports {rx_data_in_p[2]}]
set_property -dict {PACKAGE_PIN R16 IOSTANDARD LVDS_25} [get_ports {rx_data_in_p[3]}]
set_property -dict {PACKAGE_PIN W18 IOSTANDARD LVDS_25} [get_ports {rx_data_in_p[4]}]
set_property -dict {PACKAGE_PIN V16 IOSTANDARD LVDS_25} [get_ports {rx_data_in_p[5]}]

set_property -dict {PACKAGE_PIN Y19 IOSTANDARD LVDS_25} [get_ports {rx_data_in_n[0]}]
set_property -dict {PACKAGE_PIN V18 IOSTANDARD LVDS_25} [get_ports {rx_data_in_n[1]}]
set_property -dict {PACKAGE_PIN W20 IOSTANDARD LVDS_25} [get_ports {rx_data_in_n[2]}]
set_property -dict {PACKAGE_PIN R17 IOSTANDARD LVDS_25} [get_ports {rx_data_in_n[3]}]
set_property -dict {PACKAGE_PIN W19 IOSTANDARD LVDS_25} [get_ports {rx_data_in_n[4]}]
set_property -dict {PACKAGE_PIN W16 IOSTANDARD LVDS_25} [get_ports {rx_data_in_n[5]}]
#----------------------发送数据---------------------------
set_property -dict {PACKAGE_PIN N18 IOSTANDARD LVDS_25} [get_ports tx_clk_out_p]
set_property -dict {PACKAGE_PIN P19 IOSTANDARD LVDS_25} [get_ports tx_clk_out_n]
set_property -dict {PACKAGE_PIN Y16 IOSTANDARD LVDS_25} [get_ports tx_frame_out_p]
set_property -dict {PACKAGE_PIN Y17 IOSTANDARD LVDS_25} [get_ports tx_frame_out_n]

set_property -dict {PACKAGE_PIN W14 IOSTANDARD LVDS_25} [get_ports {tx_data_out_p[0]}]
set_property -dict {PACKAGE_PIN T12 IOSTANDARD LVDS_25} [get_ports {tx_data_out_p[1]}]
set_property -dict {PACKAGE_PIN U14 IOSTANDARD LVDS_25} [get_ports {tx_data_out_p[2]}]
set_property -dict {PACKAGE_PIN T16 IOSTANDARD LVDS_25} [get_ports {tx_data_out_p[3]}]
set_property -dict {PACKAGE_PIN V12 IOSTANDARD LVDS_25} [get_ports {tx_data_out_p[4]}]
set_property -dict {PACKAGE_PIN V15 IOSTANDARD LVDS_25} [get_ports {tx_data_out_p[5]}]

set_property -dict {PACKAGE_PIN Y14 IOSTANDARD LVDS_25} [get_ports {tx_data_out_n[0]}]
set_property -dict {PACKAGE_PIN U12 IOSTANDARD LVDS_25} [get_ports {tx_data_out_n[1]}]
set_property -dict {PACKAGE_PIN U15 IOSTANDARD LVDS_25} [get_ports {tx_data_out_n[2]}]
set_property -dict {PACKAGE_PIN U17 IOSTANDARD LVDS_25} [get_ports {tx_data_out_n[3]}]
set_property -dict {PACKAGE_PIN W13 IOSTANDARD LVDS_25} [get_ports {tx_data_out_n[4]}]
set_property -dict {PACKAGE_PIN W15 IOSTANDARD LVDS_25} [get_ports {tx_data_out_n[5]}]

