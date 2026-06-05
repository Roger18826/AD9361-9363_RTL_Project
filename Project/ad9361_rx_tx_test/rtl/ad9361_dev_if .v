
module ad9361_dev_if(
    //input                rst_n,//这款芯片没有复位按键
    //差分时钟转为单端时钟data_clk
    output               data_clk,
    //AD芯片信号接收 需要6位转12位
    input  [5:0]         rx_data_in_p,
    input  [5:0]         rx_data_in_n,
    input                rx_clk_in_p,
    input                rx_clk_in_n,
    input                rx_frame_in_p,
    input                rx_frame_in_n,
    //6位转换12数据
    output reg  [11:0]   adc_data_out_i1,
    output reg  [11:0]   adc_data_out_q1,
    output reg           adc_out_valid,
    output reg           adc_status,
    //需要 数 模 转换的数据 12位转6位
    input  [11:0]        dac_data_in_i1,
    input  [11:0]        dac_data_in_q1,
    input                dac_in_valid,
    //12位以及转换为6位的数据
    output  [5:0]        tx_data_out_p,
    output  [5:0]        tx_data_out_n,
    output               tx_clk_out_p,
    output               tx_clk_out_n,
    output               tx_frame_out_p,
    output               tx_frame_out_n,       
    //adc和dac模式
    input                dac_r1_mode,
    input                adc_r1_mode,
    /*观察信号*/
    output      [3:0]    rx_frame_s_reg,
    output      [3:0]    tx_data_sel_s_reg,
    output               tx_frame_reg

);
/*----------------------------reg define----------------------------*/
//rx部分
reg        [11:0]     rx_data        = 'd0 ;
reg        [1:0]      rx_frame       = 'd0 ;//低2位frame
reg        [5:0]      rx_data_n      = 'd0 ;
reg                   rx_frame_n     = 'd0 ;//单位frame
reg        [11:0]     rx_data_d      = 'd0 ;
reg        [1:0]      rx_frame_d     = 'd0 ;//高2位frame
reg                   rx_error       = 'd0 ;//接收错误信号
reg                   rx_valid       = 'd0 ;//接收有效
reg        [11:0]     rx_data_i      = 'd0 ;//12位实部数据
reg        [11:0]     rx_data_q      = 'd0 ;//12位虚部数据

//tx部分
reg                   tx_frame       = 'd0 ;//转换成2位frame pn输出出去
reg        [5:0]      tx_data_p      = 'd0 ;
reg        [5:0]      tx_data_n      = 'd0 ;
reg        [11:0]     tx_data_i_d    = 'd0 ;
reg        [11:0]     tx_data_q_d    = 'd0 ;
reg        [2:0]      tx_data_cnt    = 'd0 ;


/*----------------------------wire define----------------------------*/
//时钟部分
wire                  data_clk_ibuff  ;  
//rx部分
wire       [3:0]      rx_frame_s      ;//共同拼成4位frame_clk
wire       [5:0]      rx_data_p_s     ;
wire       [5:0]      rx_data_n_s     ;
wire                  rx_frame_p_s    ;
wire                  rx_frame_n_s    ;

wire                  rx_frame_ibuf_s ;
wire       [5:0]      rx_data_ibuf_s  ;

//tx部分
wire       [3:0]      tx_data_sel_s   ;

wire       [5:0]      tx_data_obuf_s  ;
wire                  tx_frame_obuf_s ;
wire                  tx_clk_obuf_s   ;
 
//generate
genvar           cnt             ;  

/*----------------------------原语区----------------------------*/
/*-----------------------接收部分-----------------------*/
//输入进来的差分时钟变成单端时钟（其他模块都用这个单端时钟来同步）
/*******1、时钟处理*******/
IBUFDS  #(
    .DIFF_TERM("TRUE"),       // Differential Termination
    .IBUF_LOW_PWR("TRUE"),     // Low power="TRUE", Highest performance="FALSE" 
    .IOSTANDARD("LVDS_25")     // Specify the input I/O standard
 ) 
  IBUFDS_data_clk_inst (
    .O(data_clk_ibuff),  // Buffer output  //输出的只是到缓存
    .I(rx_clk_in_p),  // Diff_p buffer input (connect directly to top-level port)
    .IB(rx_clk_in_n) // Diff_n buffer input (connect directly to top-level port)
 );
 //转换成正常时钟
/* BUFGCE BUFGCE_data_clk_inst (
    .O(data_clk),   // 1-bit output: Clock output
    .CE(1'b1), // 1-bit input: Clock enable input for I0
    .I(data_clk_ibuff)   // 1-bit input: Primary clock 
 );*/

 BUFG BUFG0 (
     .O     (data_clk),
     .I     (data_clk_ibuff)
); 
 
/*******2、rx_frame_clk处理*******/

IBUFDS #(
   .DIFF_TERM("TRUE"),       // Differential Termination
   .IBUF_LOW_PWR("TRUE"),     // Low power="TRUE", Highest performance="FALSE" 
   .IOSTANDARD("LVDS_25")     // Specify the input I/O standard
 )IBUFDS_rx_frame_clk_inst (
    .O(rx_frame_ibuf_s),  // Buffer output
    .I(rx_frame_in_p),  // Diff_p buffer input (connect directly to top-level port)
    .IB(rx_frame_in_n) // Diff_n buffer input (connect directly to top-level port)
 ); 
 //IDDR上下升沿采样
 IDDR #(
      .DDR_CLK_EDGE("SAME_EDGE"),// "OPPOSITE_EDGE", "SAME_EDGE" 
                                      //    or "SAME_EDGE_PIPELINED" 
      .INIT_Q1(1'b0), // Initial value of Q1: 1'b0 or 1'b1
      .INIT_Q2(1'b0), // Initial value of Q2: 1'b0 or 1'b1
      .SRTYPE("SYNC") // Set/Reset type: "SYNC" or "ASYNC" 
   ) IDDR_rx_frame_inst (
      .Q1(rx_frame_p_s), // 1-bit output for positive edge of clock
      .Q2(rx_frame_n_s), // 1-bit output for negative edge of clock
      .C(data_clk),   // 1-bit clock input
      .CE(1'b1), // 1-bit clock enable input
      .D(rx_frame_ibuf_s),   // 1-bit DDR data input
      .R(1'b0),   // 1-bit reset
      .S(1'b0)    // 1-bit set
   );

/*******3、数据处理*******/
   generate  for(cnt = 0; cnt <= 5;cnt = cnt + 1)
    begin:g_rx_data
   IBUFDS #(
    .DIFF_TERM("TRUE"),       // Differential Termination
    .IBUF_LOW_PWR("TRUE"),     // Low power="TRUE", Highest performance="FALSE" 
    .IOSTANDARD("LVDS_25")     // Specify the input I/O standard
 )
  IBUFDS_rx_frame_data_inst (
    .O(rx_data_ibuf_s[cnt]),  // Buffer output
    .I(rx_data_in_p[cnt]),  // Diff_p buffer input (connect directly to top-level port)
    .IB(rx_data_in_n[cnt]) // Diff_n buffer input (connect directly to top-level port)
 ); 
 //IDDR上下升沿采样
 IDDR #(
      .DDR_CLK_EDGE("SAME_EDGE"),// "OPPOSITE_EDGE", "SAME_EDGE" 
                                      //    or "SAME_EDGE_PIPELINED" 
      .INIT_Q1(1'b0), // Initial value of Q1: 1'b0 or 1'b1
      .INIT_Q2(1'b0)// Initial value of Q2: 1'b0 or 1'b1
     // .SRTYPE("SYNC") // Set/Reset type: "SYNC" or "ASYNC" 
 ) IDDR_rx_frame_data_p_n_inst (
      .Q1(rx_data_p_s[cnt]), // 1-bit output for positive edge of clock
      .Q2(rx_data_n_s[cnt]), // 1-bit output for negative edge of clock
      .C(data_clk),   // 1-bit clock input
      .CE(1'b1), // 1-bit clock enable input
      .D(rx_data_ibuf_s[cnt]),   // 1-bit DDR data input
      .R(1'b0),   // 1-bit reset
      .S(1'b0)    // 1-bit set
   );
    end
   endgenerate

/*---------------------发送部分部分---------------------*/
/*******1、时钟处理*******/
   OBUFDS OBUFDS_tx_clk_inst (
    .O(tx_clk_out_p),   // 1-bit output: Diff_p output (connect directly to top-level port)
    .OB(tx_clk_out_n), // 1-bit output: Diff_n output (connect directly to top-level port)
    .I(tx_clk_obuf_s)    // 1-bit input: Buffer input
 );
 ODDR #(
      .DDR_CLK_EDGE("SAME_EDGE"), // "OPPOSITE_EDGE" or "SAME_EDGE" 
      .INIT(1'b0),    // Initial value of Q: 1'b0 or 1'b1
      .SRTYPE("SYNC") // Set/Reset type: "SYNC" or "ASYNC" 
      ) ODDR_tx_clk_inst (
      .Q(tx_clk_obuf_s),   // 1-bit DDR output
      .C(data_clk),   // 1-bit clock input
      .CE(1'b1), // 1-bit clock enable input
      .D1(1'b0), // 1-bit data input (positive edge)
      .D2(1'b1), // 1-bit data input (negative edge)
      .R(1'b0),   // 1-bit reset
      .S(1'b0)    // 1-bit set
 );   
/*******2、tx_frame_clk处理*******/
   OBUFDS OBUFDS_tx_frame_inst (
    .O(tx_frame_out_p),   // 1-bit output: Diff_p output (connect directly to top-level port)
    .OB(tx_frame_out_n), // 1-bit output: Diff_n output (connect directly to top-level port)
    .I(tx_frame_obuf_s)    // 1-bit input: Buffer input
 );
 ODDR #(
    .DDR_CLK_EDGE("SAME_EDGE"), // "OPPOSITE_EDGE" or "SAME_EDGE" 
    .INIT(1'b0),    // Initial value of Q: 1'b0 or 1'b1
    .SRTYPE("SYNC") // Set/Reset type: "SYNC" or "ASYNC" 
    ) ODDR_tx_frame_inst (
    .Q(tx_frame_obuf_s),   // 1-bit DDR output
    .C(data_clk),   // 1-bit clock input
    .CE(1'b1), // 1-bit clock enable input
    .D1(tx_frame), // 1-bit data input (positive edge)
    .D2(tx_frame), // 1-bit data input (negative edge)
    .R(1'b0),   // 1-bit reset
    .S(1'b0)    // 1-bit set
 );

/*******3、数据部分*******/
   generate  for(cnt = 0; cnt <= 5;cnt = cnt + 1)
    begin:g_tx_data
   OBUFDS OBUFDS_tx_data_inst (
       .O(tx_data_out_p[cnt]),   // 1-bit output: Diff_p output (connect directly to top-level port)
       .OB(tx_data_out_n[cnt]), // 1-bit output: Diff_n output (connect directly to top-level port)
       .I(tx_data_obuf_s[cnt])    // 1-bit input: Buffer input
    );
   ODDR #(
    .DDR_CLK_EDGE("SAME_EDGE"), // "OPPOSITE_EDGE" or "SAME_EDGE" 
    .INIT(1'b0),    // Initial value of Q: 1'b0 or 1'b1
    .SRTYPE("SYNC") // Set/Reset type: "SYNC" or "ASYNC" 
   ) ODDR_tx_data_inst (
    .Q(tx_data_obuf_s[cnt]),   // 1-bit DDR output
    .C(data_clk),   // 1-bit clock input
    .CE(1'b1), // 1-bit clock enable input
    .D1(tx_data_p[cnt]), // 1-bit data input (positive edge)
    .D2(tx_data_n[cnt]), // 1-bit data input (negative edge)
    .R(1'b0),   // 1-bit reset
    .S(1'b0)    // 1-bit set
 );
    end
   endgenerate

/*----------------------------功能区----------------------------*/
//接收流程处理
 //1、根据data_clk还原出frame_clk 且还原数据
/*原理：根据1R1T时序图，一个data_clk完整周期(↑↓) = 半个frame_clk(↑) 周期，故要做类似打拍的动作接收
        
                             rx_frame_n  rx_frame_p_s
        +---------+---------+---------+---------+
        |         |         |         |         |
        |         |         |         |         |       rx_frame_s
        |         |         |         |         |
        +---------+---------+---------+---------+
        
        +-----rx_frame_d----+------rx_frame-------+
                            +
            x-3       x-2        x-1         x
        
             0         0          1          1
        
             1         1          0          0                */

assign  rx_frame_s = {rx_frame_d, rx_frame} ; //拼成4位，构成一个完整的frame_clk
always @(posedge data_clk) begin
    rx_frame_n <= rx_frame_n_s              ;//输出的单个frame延迟一个单位 从x变成x-1   
    rx_frame   <= {rx_frame_n,rx_frame_p_s} ;//将x和x-1拼成2个frame //IBUFDS先合并然后再拆分，rx_frame_p_s实际就是1234拆分出来的2
    rx_frame_d <= rx_frame                  ; //拼成的两个frame再延迟
    //数据同理
    rx_data_n  <= rx_data_n_s               ;
    rx_data    <= {rx_data_n,rx_data_p_s}   ;
    rx_data_d  <= rx_data                   ;
end
//rx_data是由pn共同构成，这里是将实部和虚部的数据拆开6位转换12位置后给到FPGA处理
always @(posedge data_clk) begin
    rx_error <= ((rx_frame_s == 4'b1100) || (rx_frame_s == 4'b0011)) ? 1'b0 : 1'b1;
    rx_valid <= (rx_frame_s == 4'b1100) ? 1'b1 : 1'b0; //1100是下一个data_clk  1         1          0          0
    if(rx_frame_s == 4'b1100)begin
        rx_data_i <= {rx_data_d[11:6],rx_data[11:6]};//pn的高6位
        rx_data_q <= {rx_data_d[5:0],rx_data[5:0]};  //pn的低6位
    end
    else; 
end

//有效输出
reg signed [11:0]  adc_data_out_q1_qufan ; //工程经验处理
always @(posedge data_clk ) begin
    if(adc_r1_mode == 1'b1)begin
        adc_out_valid <= rx_valid          ;  
        adc_data_out_i1 <= rx_data_i       ;
        //adc_data_out_q1 <= rx_data_q       ;
        adc_data_out_q1_qufan <= rx_data_q ;
        adc_status <= ~rx_error            ;
    end
    else ;
    adc_data_out_q1 <= -adc_data_out_q1_qufan;//工程经验处理
end


 /*
  tx_data_sel_s：	1100	1101	1110	1111	 
  tx_data_cnt：   000   1 01  1 10	1 11	    000
  */
//发送流程处理
assign tx_data_sel_s = {1'b1,dac_r1_mode,tx_data_cnt[1:0]};
always @(posedge data_clk ) begin
   if (dac_in_valid)begin
        tx_data_cnt   <= 3'b100           ;
        tx_data_i_d   <=   dac_data_in_i1 ;
        tx_data_q_d   <=   dac_data_in_q1 ;
        tx_data_cnt[0]  <= !tx_data_cnt[0];
   end
   else;
  // else if(tx_data_cnt[2] == 1'b1)begin
        
  // end
   case(tx_data_sel_s)
       4'b1100:begin
           tx_frame <= 1'b1               ;
           tx_data_p <= tx_data_i_d[11:6] ;
           tx_data_n <= tx_data_q_d[11:6] ;
       end
       4'b1101:begin
           tx_frame <= 1'b0               ;
           tx_data_p <= tx_data_i_d[5:0] ;
           tx_data_n <= tx_data_q_d[5:0] ;
       end
   default :begin
           tx_frame  <=1'b0;
           tx_data_p <=6'd0;
           tx_data_n <=6'd0;
   end
   endcase
end


assign rx_frame_s_reg = rx_frame_s;
assign tx_data_sel_s_reg = tx_data_sel_s;
assign tx_frame_reg =  tx_frame;


endmodule