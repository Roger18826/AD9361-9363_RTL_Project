module ad9361_spi (
    input               clk,
    input               rst_n,

    input               read,
    input               write,
    input   [9:0]       address,
    input   [7:0]       writedata,
    input               spi_sdi,

    output  reg  [7:0]  readdata,
    output  reg         waitrequest,
    output              spi_clk,
    output  reg         spi_csn,
    output  reg         spi_sdo
);

/*reg define*/
reg     [4:0]       bit_cnt ;
reg     [23:0]      command ;
reg     [1:0]       state   ;
/*wire define*/
wire    wr_or_rd;
/*assign define*/
assign      spi_clk = clk               ;   
assign      wr_or_rd = write && !read   ;

/*状态机定义*/
localparam      ST_IDLE     = 2'b00      ;
localparam      ST_TX_OR_RD = 2'b01     ;
localparam      ST_DONE     = 2'b10    ;

/*initial begin
    state <=  ST_IDLE ;
    waitrequest     <= 'b1  ;
    spi_csn         <= 'b1  ;
    spi_sdo         <= 'b0  ;
    bit_cnt         <= 'b0  ;
end
*/
/*---------------------------------功能区---------------------------------*/
always @(posedge clk or negedge rst_n) begin
    if(!rst_n)begin
        state <=  ST_IDLE ;
        waitrequest     <= 'b1  ; 
        spi_csn         <= 'b1  ;    
        spi_sdo         <= 'b0  ; 
        bit_cnt         <= 'b0  ;   
    end
    else begin
        case(state)
            ST_IDLE:begin
                if((write|read))begin
                    state   <= ST_TX_OR_RD;
                    bit_cnt <= 5'd0;
                    command <= {wr_or_rd,3'b000,2'b00,address,writedata};
                end
                else ;
            end
            ST_TX_OR_RD:begin
                if(bit_cnt <= 5'd23)begin
                    spi_csn <= 1'b0;
                    spi_sdo <= command[23];
                    command <= command << 1;
                    bit_cnt <= bit_cnt + 1'b1;
                end
                else begin
                    spi_csn <= 1'b1;
                    spi_sdo <= 1'b0;
                    bit_cnt <= 1'b0;
                    state   <= ST_DONE;
                    waitrequest <= 0;
                end
            end
            ST_DONE:begin
                waitrequest <= 1'b1;
                state       <= ST_IDLE;
            end
            default: state <= ST_IDLE;
        endcase
    end
end

//spi_sdi
reg [7:0] readdata_shift = 8'd0;//数据寄存
always @(posedge clk ) begin
    readdata_shift <= {readdata_shift[6:0],spi_sdi};
end

always @(posedge clk ) begin
    if((bit_cnt == 5'd24) && read) //要数到24，撑满一整帧的长度，readdata才开始发送
        readdata <={readdata_shift[6:0],spi_sdi}; //
    else;
end




endmodule