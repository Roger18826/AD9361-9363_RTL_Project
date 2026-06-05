module sin_gen (
    input               clk,            // DAC时钟
    input               rst_n,          // 复位信号
    input               dac_valid,      // DAC有效信号
    output reg [11:0]   dac_i_data,    // I路数据
    output reg [11:0]   dac_q_data     // Q路数据
);
reg [31:0] i;  // 循环计数器，用于初始化正弦查找表
// 定义正弦查找表的大小和数据宽度
parameter ADDR_WIDTH = 8; // 地址宽度
parameter DATA_WIDTH = 12;  // 数据宽度
parameter PHASE_INC = 1;   // 相位增量，控制频率的增量

// 存储正弦波采样点的查找表
reg  signed  [DATA_WIDTH-1:0]   sine_table [0:(2**ADDR_WIDTH)-1];  // 有符号正弦值查找表
reg          [ADDR_WIDTH-1:0]   addr_cnt;  // 地址计数器，用于访问查找表

// 初始化正弦查找表
initial begin
    for (i = 0; i < 2**ADDR_WIDTH; i = i + 1) begin   //** 是指数的意思,如果地址为8位,则为2^8
        // 计算正弦值并缩放到有符号范围 [-2047, 2047]
        sine_table[i] = $rtoi(2047 * $sin(2.0 * 3.14159 * i / (2**ADDR_WIDTH)));  //$rtoi 实数转化成整数 //$sin 是一个系统函数，用于计算给定角度的正弦值 
        //可以使用 $sin(3.14159/2)，这将返回 1。
    end
end

// 地址计数器
always @(posedge clk or negedge rst_n) begin
    if (!rst_n)
        addr_cnt <= 0;
    else if (dac_valid)
        addr_cnt <= addr_cnt + PHASE_INC; // 如果DAC有效，增加地址计数器
end

// 输出正弦波数据
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        dac_i_data <= 12'd0;  // DAC中点值  // 复位时I路输出为0
        dac_q_data <= 12'd0;
    end
    else if (dac_valid) begin
        dac_i_data <= sine_table[addr_cnt];  // 从查找表中获取I路数据
        // Q路数据相对于I路数据相差90度，相应地从查找表中获取
        dac_q_data <= sine_table[addr_cnt + (2**(ADDR_WIDTH-2))];
    end
end

endmodule