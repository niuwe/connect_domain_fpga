`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/12/05 14:01:09
// Design Name: 
// Module Name: tb
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module testbench();

localparam image_width  = 10;
localparam image_height = 10;
reg       per_img_vsync  ;
reg       per_img_href   ;
reg       per_img_bit    ;
reg       clk            ;
initial
begin
    clk = 1'b0;
    forever #5 clk = ~clk;
end

//  task and function
task image_input;
    bit             [31:0]      row_cnt;
    bit             [31:0]      col_cnt;
    bit             [7:0]       mem     [image_width*image_height-1:0];
    $readmemh("img_Bin.dat",mem);
    //$readmemh("img_Gray2.dat",mem);
    for(row_cnt = 0;row_cnt < image_height;row_cnt++)
    begin
        repeat(5) @(posedge clk);
        per_img_vsync <= 1'b1;
        repeat(5) @(posedge clk);
        for(col_cnt = 0;col_cnt < image_width;col_cnt++)
        begin
            per_img_href  <= 1'b1;
            per_img_bit  <= mem[row_cnt*image_width+col_cnt];
            //per_img_gray  <= 8'd255 ;
            @(posedge clk);
        end
        per_img_href  <= 1'b0;
    end
    per_img_vsync <= 1'b0;
    @(posedge clk);
    
endtask : image_input

//  task and function
task image_input1;
    bit             [31:0]      row_cnt;
    bit             [31:0]      col_cnt;
    bit             [7:0]       mem     [image_width*image_height-1:0];
    //$readmemh("img_Gray1.dat",mem);
    $readmemh("img_Gray2.dat",mem);
    for(row_cnt = 0;row_cnt < image_height;row_cnt++)
    begin
        repeat(5) @(posedge clk);
        per_img_vsync <= 1'b1;
        repeat(5) @(posedge clk);
        for(col_cnt = 0;col_cnt < image_width;col_cnt++)
        begin
            per_img_href  <= 1'b1;
            per_img_bit  <= mem[row_cnt*image_width+col_cnt];
            //per_img_gray  <= 8'd255 ;
            @(posedge clk);
        end
        per_img_href  <= 1'b0;
    end
    per_img_vsync <= 1'b0;
    @(posedge clk);
    
endtask : image_input1

//  task and function
task image_input2;
    bit             [31:0]      row_cnt;
    bit             [31:0]      col_cnt;
    bit             [7:0]       mem     [image_width*image_height-1:0];
    //$readmemh("img_Gray1.dat",mem);
    $readmemh("img_Gray3.dat",mem);
    for(row_cnt = 0;row_cnt < image_height;row_cnt++)
    begin
        repeat(5) @(posedge clk);
        per_img_vsync <= 1'b1;
        repeat(5) @(posedge clk);
        for(col_cnt = 0;col_cnt < image_width;col_cnt++)
        begin
            per_img_href  <= 1'b1;
            per_img_bit   <= mem[row_cnt*image_width+col_cnt];
            //per_img_gray  <= 8'd255 ;
            @(posedge clk);
        end
        per_img_href  <= 1'b0;
    end
    per_img_vsync <= 1'b0;
    @(posedge clk);
    
endtask : image_input2

initial
begin
    per_img_vsync <= 0;
    per_img_href  <= 0;
    per_img_bit   <= 0;
end

initial 
begin
    #2000;
    fork
        begin 
            repeat(5) @(posedge clk); 
            image_input;
            #9000;
            image_input;
            #9000;
            image_input;
            #9000;
            image_input;
        end 
    join
end 

CCL u_CCL(
    .clk             (clk   ),

    //  Image data prepared to be processed
    .per_img_vsync  (per_img_vsync   ),   //  Prepared Image data vsync valid signal
    .per_img_href   (per_img_href    ),   //  Prepared Image data href vaild  signal
    .per_img_bit    (per_img_bit     )    //  Prepared Image brightness input
);
endmodule
