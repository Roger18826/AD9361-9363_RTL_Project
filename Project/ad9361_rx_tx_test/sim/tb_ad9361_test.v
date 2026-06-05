`timescale  1ns/1ns                     //定义仿真时间单位1ns和仿真时间精度为1ns
module tb_ad9361_test;

  // Parameters
parameter  T = 10;             

  reg sys_clk;
  reg rst_n;
  wire [7:0] readdata;
  wire waitrequest;
  wire read;
  wire write;
  wire [9:0] address;
  wire [7:0] writedata;
  wire chip_rst_n;
  wire init_done;
  wire [12:0] init_index;
  //Ports
  reg  spi_sdi;
  wire spi_clk;
  wire spi_csn;
  wire spi_sdo;
  reg  [2:0]spi_cnt;
  //系统时钟40Mhz 即为25ns，所以12.5ns反转一次 不取小数，取50Mhz
  initial begin
    sys_clk        = 1'b0;
    rst_n          = 1'b0;     //复位
    #(T+1)  rst_n  = 1'b1;     //在第(T+1)ns的时候复位信号信号拉高
    spi_cnt        = 3'd0;
end

always #(T/2) sys_clk = ~sys_clk;

always @(posedge sys_clk) begin
      spi_cnt <= spi_cnt+ 1'b1;
      if(spi_cnt <= 3'd3)
        spi_sdi <= 1'b0;
      else begin
        spi_sdi <= 1'b1;
        if(spi_cnt == 3'd7)
         spi_cnt <= 3'd0;
        else;
      end
end
ad9361_init  ad9361_init_inst (
  .clk(sys_clk),
  .rst_n(rst_n),
  .readdata(readdata),
  .waitrequest(waitrequest),
  .read(read),
  .write(write),
  .address(address),
  .writedata(writedata),
  .chip_rst_n(chip_rst_n),
  .init_done(init_done),
  .init_index(init_index)
);

  ad9361_spi  ad9361_spi_inst (
    .clk(sys_clk),
    .rst_n(rst_n),
    .read(read),
    .write(write),
    .address(address),
    .writedata(writedata),
    .spi_sdi(spi_sdi),
    .readdata(readdata),
    .waitrequest(waitrequest),
    .spi_clk(spi_clk),
    .spi_csn(spi_csn),
    .spi_sdo(spi_sdo)
  );

endmodule