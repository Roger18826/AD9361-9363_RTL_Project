'''
@author:Roger8826<zhangluojie@foxmail.com>
'''
import tkinter as tk
from tkinter import filedialog,messagebox
import re

def process_file(input_file_1, output_file_1, condition_func):
    with open(input_file_1, 'r', encoding='utf-8') as infile:
        with open(output_file_1, 'w', encoding='utf-8') as outfile:
            count = 0
            write_header(outfile)
            for line in infile:
                if condition_func(line):
                    stripped_line = line.strip()
                    first_two_chars = stripped_line[:2]
                    first_SPI_W_R_chars = stripped_line[:4]
                    reg_locate_w = stripped_line[9:12]
                    reg_locate_r = stripped_line[8:11]
                    reg_data = stripped_line[13:15]
                    wait_time = stripped_line[:5]

                    if first_two_chars == "//":
                        outfile.write(line)
                    elif first_SPI_W_R_chars in {"SPIW", "SPIR"}:
                        process_spi(outfile, first_SPI_W_R_chars, reg_locate_w, reg_locate_r, reg_data, count)
                        count += 1
                    elif wait_time.startswith("WAIT"):
                        process_wait(outfile, line, wait_time, count)
                        count += 1
                    elif stripped_line.startswith("Read"):
                        outfile.write(f" " * 10 + f"13'd{count}:ad9361_lut_t <={{1'b0,10'h037,8'h08}};\n")
                        count += 1
                else:
                    print(f"跳过时钟: {line.strip()}")
            write_footer(outfile, count)

def write_header(outfile):
    header = (
        "module ad9361_lut(\n"
        "  input               clk,\n"
        "  input       [12:0]  index,\n"
        "  output reg  [18:0]  ad9361_lut_t\n"
        ");\n"
        "always @(posedge clk) begin\n"
        "  case(index)\n"
    )
    outfile.write(header)

def write_footer(outfile, count):
    footer = (
        f"          13'd{count}:ad9361_lut_t <={{1'b0,10'h3FF,8'h14}};	//delay\n"
        f"          13'd{count + 1}:ad9361_lut_t <={{1'b1,10'h03B,8'h44}};	////增强DATA_CLK\n"
        f"          13'd{count + 2}:ad9361_lut_t <={{1'b1,10'h014,8'h23}};	// Set FDD\n"
        f"          13'd{count + 3}:ad9361_lut_t <={{1'b0,10'h017,8'h0F}};	//读ENSM 4位状态机\n"
        f"          //13'd{count + 3}:ad9361_lut_t <={{1'b1,10'h3F4,8'h5B}};	//产生一个正弦波\n"
        f"          //13'd{count + 3}:ad9361_lut_t <={{1'b1,10'h3F5,8'h01}};	//回环\n"
        f"          13'd{count + 4}:ad9361_lut_t <={{1'b0,10'h3FF,8'hFF}};\n"
        "        default:;\n"
        "    endcase\n"
        "end\n"
        "endmodule\n"
    )
    outfile.write(footer)

def process_spi(outfile, find_w_r, reg_locate_w, reg_locate_r, reg_data, count):
    reg_rl_wh = 1 if find_w_r == "SPIW" else 0
    if find_w_r == "SPIW":
        outfile.write(f"          13'd{count}:ad9361_lut_t <={{1'b{reg_rl_wh},10'h{reg_locate_w},8'h{reg_data}}};\n")
    elif reg_locate_r in {"05E", "247", "287"}:
        data_map = {"05E": "80", "247": "02", "287": "02"}
        outfile.write(f"          13'd{count}:ad9361_lut_t <={{1'b{reg_rl_wh},10'h{reg_locate_r},8'h{data_map[reg_locate_r]}}};\n")
    else:
        outfile.write(f"          13'd{count}:ad9361_lut_t <={{1'b{reg_rl_wh},10'h{reg_locate_r},8'h00}};\n")

def process_wait(outfile, line, wait_time, count):
    reg_rl_wh = 0
    if wait_time == "WAIT_":
        catch_str = extract_str(line)
        str_map = {
            'BBPLL': "05E", 'RXCP': "244", 'TXCP': "284",
            'RXFILTER': "016", 'TXFILTER': "016",
            'BBDC': "016", 'RFDC': "016",
            'TXQUAD': "016", 'RXQUAD': "016"
        }
        data_map = {
            'BBPLL': "80", 'RXCP': "80", 'TXCP': "80",
            'RXFILTER': "80", 'TXFILTER': "40",
            'BBDC': "01", 'RFDC': "02",
            'TXQUAD': "10", 'RXQUAD': "20"
        }
        if catch_str in str_map:
            outfile.write(f"          13'd{count}:ad9361_lut_t <={{1'b{reg_rl_wh},10'h{str_map[catch_str]},8'h{data_map[catch_str]}}};\n")
    else:
        number_first = extract_numbers(line)[0]
        number_to_hex = hex(int(number_first))[2:]
        number_to_hex = number_to_hex if number_to_hex != '1' else '01'
        outfile.write(f"          13'd{count}:ad9361_lut_t <={{1'b{reg_rl_wh},10'h3FF,8'h{number_to_hex}}};\n")

def extract_numbers(line):
    return re.findall(r'\d+', line)

def extract_str(line):
    for keyword in ['BBPLL', 'RXCP', 'TXCP', 'RXFILTER', 'TXFILTER', 'BBDC', 'RFDC', 'TXQUAD', 'RXQUAD']:
        if re.search(keyword, line, re.IGNORECASE):
            return keyword
    return None

def condition(line):
    return bool(line.strip())

def upload_file():
    file_path = filedialog.askopenfilename(filetypes=[("Text files", "*.txt")])
    if file_path:
        if file_path.endswith('.txt'):
            output_file = "ad9361_lut.v"
            process_file(file_path, output_file, condition)
            messagebox.showinfo("完成", "处理完成，选中的数据已写入 ad9361_lut.v")
        else:
            messagebox.showerror("错误", "只支持TXT文件格式!")
# 创建Tkinter应用程序
root = tk.Tk()
root.title("文件处理器")

# 设置窗口大小, 格式为"宽x高"
root.geometry("600x200")  # 这里设置窗口为400宽，200高

# 创建上传按钮
upload_button = tk.Button(root, text="上传文件", command=upload_file, width=40, height=10)
upload_button.pack(pady=60)  # 添加上下间距
# 运行主循环
root.mainloop()