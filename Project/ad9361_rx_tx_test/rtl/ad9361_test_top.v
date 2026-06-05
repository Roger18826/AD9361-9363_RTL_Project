module ad9361_test_top(
    input                sys_clk, //40m
    //接收数据部分
    input                rx_clk_in_p,
    input                rx_clk_in_n,
    input  [5:0]         rx_data_in_p,
    input  [5:0]         rx_data_in_n,
    input                rx_frame_in_p,
    input                rx_frame_in_n,
     //发送数据部分
    output  [5:0]        tx_data_out_p,
    output  [5:0]        tx_data_out_n,
    output               tx_clk_out_p,
    output               tx_clk_out_n,
    output               tx_frame_out_p, //fb
    output               tx_frame_out_n, //fb
    //SPI接口部分
    input                spi_sdi,
    output               spi_clk,
    output               spi_csn,
    output               spi_sdo,
    //收发控制部分
    output               en_agc,
    output  reg          enable,
    output  reg          txnrx,
    output               reset,
    output               sync_in,
    output      [3:0]    ctrl_in,
    input       [7:0]    ctrl_out,

    output   reg  [1:0]       led
);

//wire define  
wire              init_done           ;
wire              read                ;           
wire              write               ;   
wire    [9:0]     address             ;       
wire    [7:0]     writedata           ;          
wire    [7:0]     readdata            ;       
wire              waitrequest         ;            
wire              chip_rst_n          ;
wire    [12:0]    init_index          ;

wire   [11:0]     adc_data_out_i1      ;
wire   [11:0]     adc_data_out_q1      ;
wire              adc_out_valid        ;
wire              adc_status           ;
wire   [11:0]     dac_data_in_i1       ;
wire   [11:0]     dac_data_in_q1       ;
reg               dac_in_valid         ;

reg    [7:0]      cnt_clk              ;


wire              data_clk             ;  
reg     [24:0]cnt = 25'd0              ;  
reg               rst_reg              ;
reg    [7:0]      cnt_resetn           ;

wire    [3:0]   rx_frame_s_reg      ;
wire    [3:0]   tx_data_sel_s_reg   ;
wire            tx_frame_reg        ;




wire    [7:0]   readreg             ;
wire    [31:0]  delay_cnt_index     ;
wire    [2:0]   state_reg           ;
wire    [18:0]  command_reg         ;
wire    [18:0]  ad9361_lut_t        ;

wire [11:0]   dac_i_data ;   // I路数据
wire [11:0]   dac_q_data ;   // Q路数据

wire   clk_100m;
wire   clk_200m;
wire   clk_40m;

initial begin
    led = 2'b01             ;
   // txnrx <= 1'b0           ;
    dac_in_valid <= 1'b0    ;
end
/*---------------------------一、时钟处理------------------------------*/
/*倍频，数据手册说spi协议有最小的时钟周期限制20ns 50M*/
clk_wiz_0 u_clk_wiz_0
(
 // Clock out ports
 .clk_out1(clk_100m),     // output clk_out1
 .clk_out2(clk_200m),     // output clk_out2
 .clk_out3(clk_40m),     // output clk_out3
// Clock in ports
 .clk_in1(sys_clk));      // input clk_in1
assign gclk_div = cnt_clk[0];               //50Mhz  
/*---------------------------二、小灯显示------------------------------*/
always @ (posedge clk_100m)begin
   cnt_clk <= cnt_clk + 1;
end
/*计数功能*/
always @(posedge gclk_div) begin
    if (cnt < (25'd25000000-25'd1)) //最大值-1 //小于最大值进行累加
        cnt <= cnt + 24'd1;
    else
        cnt <= 25'd0;
end
/*移位功能*/
always @(posedge gclk_div) begin
    if (cnt == (25'd25000000-25'd1))   //最大值-1 //小于最大值进行累加
        led <= {led[0],led[1]};   //将高位拼到低位  位拼接的方式进行移位
    else ;
end
/*---------------------------三、复位功能（如果有硬件复位则不需要这段）------------------------------*/
//cnt_resetn(延迟255周期)
always @ (posedge clk_40m)
begin
  if (cnt_resetn == 8'hfe) begin
      cnt_resetn <= 8'hff;
  end
  else if( cnt_resetn < 8'hfe) begin
      cnt_resetn <= cnt_resetn + 1;
  end
end

//255个计数，拉高复位rstr
always @ (posedge clk_40m)
begin
  if (cnt_resetn == 8'hff) begin
    rst_reg <= 1'b1;
  end
  else  begin
    rst_reg <= 1'b0;
  end
end


/*---------------------------四、assign define------------------------------*/
assign      dac_r1_mode = 1'b1        ;     
assign      adc_r1_mode = 1'b1        ;    
// AD9361 control signal.
assign      en_agc      = 1'b0        ;
assign      sync_in     = 1'b1        ;
assign      ctrl_in     = 4'b0000     ;
assign      dac_data_in_i1 = dac_i_data;
assign      dac_data_in_q1 = dac_q_data;


/*---------------------------五、模块例化------------------------------*/
ad9361_dev_if u_ad9361_dev_if(
    .data_clk          (data_clk),
    //接收数据端 input           
    .rx_data_in_p      (rx_data_in_p),     
    .rx_data_in_n      (rx_data_in_n),     
    .rx_clk_in_p       (rx_clk_in_p),  
    .rx_clk_in_n       (rx_clk_in_n),  
    .rx_frame_in_p     (rx_frame_in_p),      
    .rx_frame_in_n     (rx_frame_in_n), 
    //output 采集到的数据数据合并6转12位     
    .adc_data_out_i1   (adc_data_out_i1),      
    .adc_data_out_q1   (adc_data_out_q1),      
    .adc_out_valid     (adc_out_valid),      
    .adc_status        (adc_status),  
    //需要发送的数据
    .dac_data_in_i1    (dac_data_in_i1),      
    .dac_data_in_q1    (dac_data_in_q1),      
    .dac_in_valid      (dac_in_valid), 
    //发送前处理 12位转6位 
    .tx_data_out_p     (tx_data_out_p),      
    .tx_data_out_n     (tx_data_out_n),      
    .tx_clk_out_p      (tx_clk_out_p),      
    .tx_clk_out_n      (tx_clk_out_n),      
    .tx_frame_out_p    (tx_frame_out_p),      
    .tx_frame_out_n    (tx_frame_out_n),      
    .dac_r1_mode       (dac_r1_mode),  
    .adc_r1_mode       (adc_r1_mode),
    
    .rx_frame_s_reg    (rx_frame_s_reg),
    .tx_data_sel_s_reg (tx_data_sel_s_reg),
    .tx_frame_reg      (tx_frame_reg)
);

ad9361_spi  u_ad9361_spi(
   .clk               (gclk_div),      
   .rst_n             (rst_reg),
   //input
   .read              (read),
   .write             (write),
   .address           (address),
   .writedata         (writedata),  
   .spi_sdi           (spi_sdi),
   //output
   .readdata          (readdata),  
   .waitrequest       (waitrequest),  
   .spi_clk           (spi_clk),
   .spi_csn           (spi_csn),
   .spi_sdo           (spi_sdo)
);

ad9361_init u_ad9361_init(
    .clk               (gclk_div),              
    .rst_n             (rst_reg),  
    //input
    .readdata          (readdata),      
    .waitrequest       (waitrequest),  
    //output        
    .read              (read),  
    .write             (write),  
    .address           (address),  
    .writedata         (writedata),      
    .chip_rst_n        (reset),      
    .init_done         (init_done),   
    .init_index        (init_index),
    .delay_cnt_index   (delay_cnt_index),
    .state_reg         (state_reg),
    .command_reg       (command_reg),
    .ad9361_lut_t      (ad9361_lut_t  )
);

ad9361_lut u_ad9361_lut(
    .clk        (gclk_div),
    .index      (init_index),
    .ad9361_lut_t (ad9361_lut_t)
);

/*---------------------------六、初始化成功后处理------------------------------*/
always @(posedge gclk_div) begin
    if(init_done == 1'b1) begin
        dac_in_valid <= 1'b1;
    end
    else;
end

always @(posedge gclk_div or negedge rst_reg)
begin
    if(!rst_reg)begin
       txnrx <= 1'b0;
       enable<= 1'b0;
    end
    else begin 
       if (init_done == 1'b1)begin
             txnrx <= 1'b1; 
             enable<= 1'b0;
       end
       else;
   end
end
/*---------------------------七、发送正弦波------------------------------*/
sin_gen u_sin_gen(
    .clk        (clk_40m),
    .rst_n      (rst_reg),
    .dac_valid  (dac_in_valid),
    .dac_i_data (dac_i_data),
    .dac_q_data (dac_q_data)   
);
/*---------------------------八、观察信号------------------------------*/
ila_0 u_ila_0 (
	.clk(clk_40m), // input wire clk

	.probe0(adc_data_out_i1), // input wire [11:0]  probe0    观察接收i路信号
	.probe1(adc_data_out_q1), // input wire [11:0]  probe1    观察接收q路信号
	.probe2(dac_data_in_i1), // input wire [11:0]  probe2     观察接发i路信号
	.probe3(dac_data_in_q1), // input wire [11:0]  probe3     观察接发q路信号
	.probe4(tx_data_sel_s_reg), // input wire [3:0]  probe4   观察接tx_frame4位路信号
	.probe5(tx_frame_reg), // input wire [0:0]  probe5        观察接tx_frame1位路信号
	.probe6(dac_in_valid), // input wire [0:0]  probe6        观察发送有效信号路信号
    .probe7(init_index), // input wire [31:0]  probe7         观察初始化到哪个寄存器信号
    .probe8(rx_frame_s_reg), // input wire [3:0]  probe8      观察接rx_frame路信号
	.probe9(adc_out_valid) // input wire [0:0]  probe9        观察接收有效信号路信号
);

endmodule