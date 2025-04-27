module equivalence_table #(
    parameter MAX_LABELS = 1024,
    parameter LABEL_WIDTH = 16
)(
    input wire                   clk       , 
    input wire [LABEL_WIDTH-1:0] label1    ,  
    input wire [LABEL_WIDTH-1:0] label2    ,  
    input wire [LABEL_WIDTH-1:0] label3    ,  
    input wire [LABEL_WIDTH-1:0] label4    ,  
    input wire [LABEL_WIDTH-1:0] label5    ,  
    input wire                   find_req  ,                  
    input wire                   union_req ,   
    input wire                   init_flag ,
    
    output reg                   root_out_ready = 0 ,        
    output reg [LABEL_WIDTH-1:0] root_label = 0 ,
    output wire                  root_valid                    
);

(*ram_style = "block" *) reg [LABEL_WIDTH-1:0] label_table [0:MAX_LABELS-1];
//reg [LABEL_WIDTH-1:0] lab_tab_sec [0:MAX_LABELS-1];

reg [LABEL_WIDTH-1:0] label1_r1 = 0 ;
reg [LABEL_WIDTH-1:0] label2_r1 = 0 ;
reg [LABEL_WIDTH-1:0] label3_r1 = 0 ;
reg [LABEL_WIDTH-1:0] label4_r1 = 0 ;
reg [LABEL_WIDTH-1:0] label5_r1 = 0 ;

reg union_req_r1 = 0 ;
reg find_req_r1  = 0 ;
reg union_req_r2 = 0 ;
reg find_req_r2  = 0 ;

reg [LABEL_WIDTH-1:0] main_label_r2;
reg [LABEL_WIDTH-1:0] label2_r2 = 0 ;
reg [LABEL_WIDTH-1:0] label3_r2 = 0 ;
reg [LABEL_WIDTH-1:0] label4_r2 = 0 ;
reg [LABEL_WIDTH-1:0] label5_r2 = 0 ;

reg [07:00] index = 0   ; // index of initializing RAM

wire [LABEL_WIDTH-1:0] min_label ;

assign min_label = compute_min(label1, label2,label3, label4, label5);
function [LABEL_WIDTH-1:0] compute_min;
    input [LABEL_WIDTH-1:0] l1, l2, l3, l4, l5;
    reg [LABEL_WIDTH-1:0] min_val;
    begin
        min_val = {LABEL_WIDTH{1'b1}}; 
        if (l1 != 0 && l1 < min_val) min_val = l1;
        if (l2 != 0 && l2 < min_val) min_val = l2;
        if (l3 != 0 && l3 < min_val) min_val = l3;
        if (l4 != 0 && l4 < min_val) min_val = l4;
        if (l5 != 0 && l5 < min_val) min_val = l5;
        if (min_val == {LABEL_WIDTH{1'b1}}) min_val = 0;
        compute_min = min_val;
    end
endfunction

//The first stage
always @(posedge clk ) begin
    if(init_flag)begin
        label1_r1 <= 0;
        label2_r1 <= 0;
        label3_r1 <= 0;
        label4_r1 <= 0;
        label5_r1 <= 0;
        union_req_r1 <= 0;
        find_req_r1 <= 0;
    end
    if ( union_req) begin
        if (label1 == min_label) begin
            label1_r1 <= min_label; 
            label2_r1 <= label2;
            label3_r1 <= label3;
            label4_r1 <= label4;
            label5_r1 <= label5;
            union_req_r1 <= union_req;
            
        end
        else if (label2 == min_label) begin
            label1_r1 <= min_label; 
            label2_r1 <= label1;
            label3_r1 <= label3;
            label4_r1 <= label4;
            label5_r1 <= label5;
            union_req_r1 <= union_req;
            
        end
        else if (label3 == min_label) begin
            label1_r1 <= min_label; 
            label2_r1 <= label2;
            label3_r1 <= label1;
            label4_r1 <= label4;
            label5_r1 <= label5;
            union_req_r1 <= union_req;
            
        end
        else if (label4 == min_label) begin
            label1_r1 <= min_label; 
            label2_r1 <= label2;
            label3_r1 <= label3;
            label4_r1 <= label1;
            label5_r1 <= label5;
            union_req_r1 <= union_req;
            
        end 
        else if (label5 == min_label) begin
            label1_r1 <= min_label; 
            label2_r1 <= label2;
            label3_r1 <= label3;
            label4_r1 <= label4;
            label5_r1 <= label1;
            union_req_r1 <= union_req;
            
        end       
    end 

    else begin
        union_req_r1 <= 0;     
    end
end

//The second stage
always @(posedge clk ) begin    
    if(init_flag)begin
        main_label_r2 <= 0;
        label2_r2 <= 0;
        label3_r2 <= 0;
        label4_r2 <= 0;
        label5_r2 <= 0;
    end
    if (union_req_r1) begin
        if (!label2_r1 ||!label3_r1 ||!label4_r1 ||!label5_r1 ) begin   //other labels have 0?
            union_req_r2 <= union_req_r1 ;
            main_label_r2 <= label1_r1;
            label2_r2 <= label2_r1?label2_r1:label1_r1; 
            label3_r2 <= label3_r1?label3_r1:label1_r1; 
            label4_r2 <= label4_r1?label4_r1:label1_r1; 
            label5_r2 <= label5_r1?label5_r1:label1_r1;  
        end
        else begin
            union_req_r2  <= union_req_r1 ;
            main_label_r2 <= label1_r1    ;
            label2_r2     <= label2_r1    ;
            label3_r2     <= label3_r1    ;
            label4_r2     <= label4_r1    ;
            label5_r2     <= label5_r1    ;
        end
    end
    else begin
        union_req_r2 <= 0 ;
          
    end
end

always @(posedge clk)begin
    find_req_r1 <= find_req    ;
    find_req_r2 <= find_req_r1 ;
end

// The third stage
always @(posedge clk ) begin

    if(init_flag)begin
        for(index = 0;index < MAX_LABELS;index = index+1)begin
            label_table[index] <= index ;
        end
    end
    else begin
        index <= 0 ;
    end
    if (union_req_r2) begin
        if (label1_r1 != label2_r1) begin
            label_table[label2_r2] <= main_label_r2;
        end
        if (label1_r1 != label3_r1) begin
            label_table[label3_r2] <= main_label_r2;
        end
        if (label1_r1 != label4_r2) begin
            label_table[label4_r2] <= main_label_r2;
        end
        if (label1_r1 != label5_r2) begin
            label_table[label5_r2] <= main_label_r2;
        end
    end
end

//The finding root label stage
//localparam MAX_NUM_OF_CYC  = 256 ; //Find the maximum number of cycles of the root label
integer i ;
always @(posedge clk)begin
    if(find_req)begin
        root_label <= label1 ;
        for(i = 1 ; i < MAX_LABELS ; i = i + 1) begin
            if(root_label == label_table[root_label])begin 

                i <= 1 ;
            end
            else begin
                root_label <= label_table[root_label] ;  
         
            end
        end

    end
    else begin
        root_label <= 0 ;
    end
end

assign root_valid = (root_label == label_table[root_label])
                    &&(root_label != label1) && root_label ? 1 : 0 ;
//always @(posedge clk)begin
//    if(find_req_r1)begin
//        root_label <= root_out ;
//        for(i=1;i<10;i=i+1)begin
//            if(label_table[root_label] == root_label)begin
//                i <= 1 ;
//                root_out_ready <= 1 ;
//            end
//            else begin
//                root_label <= label_table[root_label] ;  
//                root_out_ready <= 0 ;
//            end
//        end
//    end
//    else begin
//        root_label <= 0 ;
//        i <= 1 ;
//        root_out_ready <= 0  ;
//    end
//end
endmodule
