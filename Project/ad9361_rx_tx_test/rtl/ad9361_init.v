module ad9361_init(
    input                clk,
    input                rst_n,

    input        [7:0]   readdata,
    input                waitrequest,
    output  reg          read,
    output  reg          write,
    output  reg  [9:0]   address,
    output  reg  [7:0]   writedata,
    output  reg          chip_rst_n,
    output  reg          init_done,
    output       [12:0]  init_index,
    output       [31:0]  delay_cnt_index,
    output       [2:0]   state_reg,
    output       [18:0]  command_reg,
    input        [18:0]  ad9361_lut_t        
);
/*define*/
`define    SPI_CLK_FREQ   50  //时钟频率100M
//`include  "C:/Users/ASUS/Desktop/SDR/ad9361_rx_tx_test/rtl/ad9361_lut.v" 
/*reg define*/
reg      [12:0]     index       ;
reg      [2:0]      state       ;
reg      [31:0]     delay_cnt   ;
reg      [18:0]     command     ;

assign   init_index = index     ;
assign   delay_cnt_index  = delay_cnt;
assign   state_reg        = state;
assign   command_reg      = command;
/*---------------------------------功能区----------------------------------*/
always @(posedge clk or negedge rst_n) begin
    if(!rst_n)begin
        read         <= 'b0    ;           
        write        <= 'b0    ;   
        address      <= 'b0    ;   
        writedata    <= 'b0    ;       
        init_done    <= 'b0    ;       
        index        <= 'b0    ;       
        state        <= 'b0    ;       
        delay_cnt    <= 'b0    ;
        chip_rst_n   <= 'b0    ;     
    end     
    else begin
        //command是遍历AD9361寄存器的结果 一共18位
        case(state)
            3'd0:begin 
                if(delay_cnt < (`SPI_CLK_FREQ * 1000)) //等待1ms //时钟100M 周期就是10ns   100*1000*10 = 1000000ns = 1000us = 1ms
                    delay_cnt <= delay_cnt + 1'b1;
                else begin
                    chip_rst_n <= 1'b1; //复位低电平有效，没数到就高电平
                    delay_cnt  <= 1'b0;
                    state      <= 3'd1;
                end
            end
            3'd1:begin
                read    <= ~command[18]; //第一个读取{1'1,10'h3DF,8'h01} 最后一位1'1  将读置为低电平
                //{write,address,writedata} <= command;
                write <= command[18];
                address <= command[17:8];
                writedata <= command[7:0];
                state   <= 3'd2;
            end
            3'd2:begin
                if(~waitrequest)
                    state  <= read ? 3'd3 : 3'd4; //如果是读就进三，如果不是读就进4
                else;
            end
            3'd3:begin
                case(command)
                    {1'b0,10'h037,8'h08}:begin
                        if(readdata[3])
                            state <= state + 1'b1;  //读到的确实是8'h08
                        else
                            state <= 1'b1; //回到判断读写
                    end
                    {1'b0,10'h05E,8'h80}:begin
                        if(readdata[7])
                            state <= state + 1'b1;  //读到的确实是8'h80
                        else
                            state <= 1'b1; //回到判断读写
                    end
                    {1'b0,10'h244,8'h80}:begin
                        if(readdata[7])
                            state <= state + 1'b1;  //读到的确实是8'h80
                        else
                            state <= 1'b1; //回到判断读写
                    end
                    {1'b0,10'h284,8'h80}:begin
                        if(readdata[7])
                            state <= state + 1'b1;  //读到的确实是8'h80
                        else
                            state <= 1'b1; //回到判断读写
                    end
                    {1'b0,10'h247,8'h02}:begin
                        if(readdata[1])
                            state <= state + 1'b1;  //读到的确实是8'h02
                        else
                            state <= 1'b1; //回到判断读写   
                    end
                    {1'b0,10'h287,8'h02}:begin
                        if(readdata[1])
                            state <= state + 1'b1;  //读到的确实是8'h02
                        else
                            state <= 1'b1; //回到判断读写   
                    end
                    {1'b0,10'h016,8'h80}:begin
                        if(!readdata[7])
                            state <= state + 1'b1;  //读到的确实是8'h80
                        else
                            state <= 1'b1; //回到判断读写   
                    end
                    {1'b0,10'h016,8'h40}:begin
                        if(!readdata[6])
                            state <= state + 1'b1;  //读到的确实是8'h40
                        else
                            state <= 1'b1; //回到判断读写  
                    end
                    {1'b0,10'h016,8'h01}:begin
                        if(!readdata[0])
                            state <= state + 1'b1;  //读到的确实是8'h01
                        else
                            state <= 1'b1; //回到判断读写
                    end
                    {1'b0,10'h016,8'h02}:begin
                        if(!readdata[1])
                            state <= state + 1'b1;  //读到的确实是8'h02
                        else
                            state <= 1'b1; //回到判断读写   
                    end
                    {1'b0,10'h016,8'h10}:begin
                        if(!readdata[4])
                            state <= state + 1'b1;  //读到的确实是8'h10
                        else
                            state <= 1'b1; //回到判断读写   
                    end
                    {1'b0,10'h3FF,8'h01}:begin //等待1ms
                        if(delay_cnt < (`SPI_CLK_FREQ * 1000))begin//等待1ms
                            delay_cnt <= delay_cnt + 1'b1;
                        end 
                        else begin
                            delay_cnt <= 1'b0;
                            state <= state + 1'b1;
                        end
                        end
                    {1'b0,10'h017,8'h1A}:begin
                        if(readdata[3:0] == 4'd10) 
                            state <= state + 1'b1 ;
                        else 
                            state <= 1'b1;
                    end
                    {1'b0,10'h3FF,8'h14}:begin 
                        if(delay_cnt < (`SPI_CLK_FREQ *20000))begin//等待20ms
                            delay_cnt <= delay_cnt + 1'b1; 
                        end
                        else begin
                            delay_cnt <= 1'b0;
                            state <= state + 1'b1;
                        end
                    end
                    {1'b0,10'h3FF,8'hFF}:begin
                        state <= 3'd7;// 状态机结束，最后一位是读{1'b0,10'h3FF,8'hFF}
                    end             
                default:state <= state + 1'b1;//读完就下一个状态
                endcase
            end
            3'd4:begin //写
                            index <= index + 1'b1;
                            state <= state + 1'b1;
                 end
            3'd5:begin
                state <= state + 1'b1;
            end
            3'd6:begin
                state <= 1'b1;
            end
            3'd7:begin
                init_done <= 1'b1;
            end
        default: state <= 3'd0;
        endcase
    end
end

//遍历ad9361_lut
always @(posedge clk) begin
    command <= ad9361_lut_t;//ad9361_lut(index) ;//遍历整个ad9361_lut
end

endmodule