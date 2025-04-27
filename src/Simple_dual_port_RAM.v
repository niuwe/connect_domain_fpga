module Simple_dual_port_RAM #(
    parameter WIDTH = 'd8 ,
    parameter DEPTH = 'd8
)(
    input clk,

    input wea,                  //enable write signal of channel a
    input enb,                  //enable signal of channel b

    input [DEPTH-1:0] addra,          //address of channel a
    input [DEPTH-1:0] addrb,          //address of channle b

    input [WIDTH-1:0] data_i_a,      //data input of channel a
    output reg [WIDTH-1:0] data_o_b //data output of channel b
);
(*ram_style = "block" *) reg [WIDTH-1:0] RAM [2**DEPTH-1:0];         //DATAWIDTH = 16, DEPTH = 256 = 2^8
integer i;

initial begin

    for (i = 0; i < 2**DEPTH; i = i + 1) begin
        RAM[i] = 0;  
    end
end

always @(posedge clk) begin     //write channel
    if(wea) begin
        RAM[addra] <= data_i_a;
    end
end

always @(posedge clk) begin    //read channel
    if(enb) begin
        data_o_b <= RAM[addrb];
    end
end
endmodule