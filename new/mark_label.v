`timescale 1ns / 1ps


module mark_label#(
    parameter WIDTH = 720 ,
    parameter HEIGH = 576
)(
    input       clk  ,
    //  Image data prepared to be processed
    input       per_img_vsync  ,   //  Prepared Image data vsync valid signal
    input       per_img_href   ,   //  Prepared Image data href vaild  signal
    input [7:0] per_img_gray   ,   //  Prepared Image brightness input
//DeBug

//End DeBug
    output        post_img_vsync  ,
    output        post_img_href   ,
    output [7:0]  post_img_gray   ,
    output reg [3:0]  ccl_index   ,
    output reg [18:0]   area     ,
    output reg [15:0]   x        , 
    output reg [15:0]   y        ,
    output reg          ready_output = 0 
);


reg [06:00]   per_img_vsync_r  = 0 ;
reg [05:00]   per_img_href_r   = 0 ;
reg [07:00]   per_img_gray_r1  = 0 ;
reg [07:00]   per_img_gray_r2  = 0 ;
reg [07:00]   per_img_gray_r3  = 0 ;
reg [07:00]   per_img_gray_r4  = 0 ;
reg [07:00]   per_img_gray_r5  = 0 ;
reg           per_img_href_dly = 0 ;

wire      per_img_href_3dly    ;
wire      per_img_vsync_3dly   ;
wire      per_img_href_5dly    ;
wire      per_img_vsync_5dly   ; 
wire      per_img_vsync_4dly   ; 
wire      per_img_href_4dly    ;
wire      per_img_href_6dly    ;
wire      per_img_vsync_6dly   ; 
wire      per_img_vsync_7dly   ; 
wire[7:0] per_img_gray_4dly    ;
wire[7:0] per_img_gray_5dly    ;

reg [10:0]  hcnt          = 0 ;
reg [10:0]  hcnt_4dly     = 0 ;
reg [10:0]  vcnt          = 0 ;
reg [10:0]  vcnt_4dly     = 0 ;
reg [10:0]  hcnt_3dly     = 0 ;
reg [10:0]  vcnt_3dly     = 0 ;
reg [10:0]  hcnt_5dly     = 0 ;
reg [10:0]  hcnt_6dly     = 0 ;
reg [10:0]  vcnt_5dly     = 0 ;
reg [10:0]  vcnt_6dly     = 0 ;

reg  [7:0] left_r         = 0 ;
reg  [7:0] up             = 0 ;
reg  [7:0] right_up       = 0 ;
reg  [7:0] left_up        = 0 ;

wire [7:0] rdata_label    ;
wire [7:0] left           ;

//lebel buffer
reg [9:0]  w_addr    = 0 ;
reg [9:0]  r_addr    = 0 ;
reg [7:0]  cnt_label = 1 ;
reg [7:0]  cur_label = 0 ;
reg        wen_label = 0 ;
reg        ren_label = 0 ;

reg [07:00] cur_label_1dly = 0 ;
reg [07:00] cur_label_2dly = 0 ;
reg [07:00] cur_label_3dly = 0 ;
reg [07:00] cur_label_4dly = 0 ;

//denominator parameters
reg    [03:00]    wen_den_r   = 0 ;
reg    [18:00]    w_den_value = 0 ;
wire              ren_den     ; 
wire              wen_den     ;
wire   [18:00]    r_den_value ;
wire   [07:00]    r_addr_den  ; 
wire   [07:00]    w_addr_den  ;

reg [07:00] cache_den_addr_1 = 0;   //new
reg [18:00] cache_den_data_1 = 0;
reg [07:00] cache_den_addr_2 = 0;   //old
reg [18:00] cache_den_data_2 = 0;

//X molecule parameters
reg    [03:00]    wen_mol_x_r   = 0 ;
reg    [28:00]    w_mol_x_value = 0 ;

wire              ren_mol_x     ; 
wire              wen_mol_x     ;
wire   [28:00]    r_mol_x_value ;
wire   [07:00]    r_addr_mol_x  ; 
wire   [07:00]    w_addr_mol_x  ;

reg [07:00] cache_mol_addr_1 = 0 ;   //new
reg [28:00] cache_mol_data_1 = 0 ;
reg [07:00] cache_mol_addr_2 = 0 ;   //old
reg [28:00] cache_mol_data_2 = 0 ;

reg [04:00] cnt_den_addr     = 0 ; //Addresses with the same root label
//y molecule parameters

//Molecule Part
reg    [03:00]    wen_mol_y_r   = 0 ;
reg    [28:00]    w_mol_y_value = 0 ;
 
wire              ren_mol_y     ; 
wire              wen_mol_y     ;
wire   [28:00]    r_mol_y_value ;
wire   [07:00]    r_addr_mol_y  ; 
wire   [07:00]    w_addr_mol_y  ;

reg [07:00] cache_mol_addry_1 = 0;   //new
reg [28:00] cache_mol_datay_1 = 0;
reg [07:00] cache_mol_addry_2 = 0;   //old
reg [28:00] cache_mol_datay_2 = 0;

//Equivalence table parameters
reg [7:0] label1    = 0 ;
reg [7:0] label2    = 0 ;
reg [7:0] label3    = 0 ;
reg [7:0] label4    = 0 ;
reg [7:0] label5    = 0 ;
reg       union_req = 0 ;
reg [07:00] root_out_1dly = 0 ;
reg [07:00] find_root_cnt = 1 ;
reg [07:00] root_out_2dly = 0 ;

wire        find_req    ;
wire [7:0]  root_label  ;
wire        root_valid  ;

//Centroid calculation
reg [28:00] mol_y_acc [31:00] ;
reg [28:00] mol_x_acc [31:00] ;
reg [18:00] den_acc   [31:00] ;
reg         acc_process      = 0 ;
reg         acc_process_1dly = 0 ;
reg         acc_process_2dly = 0 ;
reg         acc_process_3dly = 0 ;

wire        acc_process_2dly_nege;  
reg  [07:00]  addr_den_acc   = 0 ;
reg  [07:00]  addr_mol_x_acc = 0 ;
reg  [07:00]  addr_mol_y_acc = 0 ;
reg  [33:00]  temp_x_acc = 0 ;
reg  [33:00]  temp_y_acc = 0 ;
reg  [18:00]  temp_d_acc = 0 ;

//Indirect parameters of the output
reg [05:00] ready_out_cnt = 0 ;
reg [03:00] ccl_index_cnt = 1 ;


//RAM initilize parameters
reg [05:00] init_add    = 0 ;
reg         init_ram    = 0 ;

wire acc_process_1dly_nege ;
wire img_href_neg = ~per_img_href & per_img_href_dly;       //  falling edge of per_img_href
wire img_href_neg_4dly = ~per_img_href_4dly & per_img_href_5dly;
wire img_href_neg_3dly = ~per_img_href_3dly & per_img_href_4dly;
wire img_vsync_nge_6dly = ~per_img_vsync_6dly & per_img_vsync_7dly;
wire img_vsync_pos = per_img_vsync && (!per_img_vsync_r[0]);



//The control signal and  addr of denominator's RAM
assign wen_den = wen_den_r[1] || init_ram ;
assign ren_den = (wen_label || acc_process)?1:0 ; 
assign w_addr_den = wen_den ? ((wen_den && init_ram)?(init_add-1):cur_label_2dly):0 ;
assign r_addr_den = ren_den ? ((ren_den&&acc_process)?cnt_den_addr:cur_label):0; 

//The control signal and  addr of molecuer's RAM
assign w_addr_mol_x = wen_mol_x ? ((wen_mol_x && init_ram)?(init_add-1):cur_label_2dly):0 ;
assign r_addr_mol_x = ren_mol_x ? ((ren_mol_x&&acc_process)?cnt_den_addr:cur_label):0 ; 
assign wen_mol_y = wen_mol_y_r[1] || init_ram;
assign ren_mol_y = wen_label || acc_process ;

assign wen_mol_x = wen_mol_x_r[1] || init_ram ;
assign ren_mol_x = wen_label || acc_process ;
assign w_addr_mol_y = wen_mol_y ? ((wen_mol_y && init_ram)?(init_add-1):cur_label_2dly):0 ;
assign r_addr_mol_y = ren_mol_y ? ((ren_mol_y&&acc_process)?cnt_den_addr:cur_label):0 ; 


assign per_img_vsync_3dly = per_img_vsync_r[2] ;
assign per_img_href_3dly  = per_img_href_r [2] ;
assign per_img_vsync_4dly = per_img_vsync_r[3] ;
assign per_img_href_4dly  = per_img_href_r [3] ;
assign per_img_href_5dly  = per_img_href_r [4] ;
assign per_img_vsync_5dly = per_img_vsync_r[4] ;
assign per_img_href_6dly  = per_img_href_r [5] ;
assign per_img_vsync_6dly = per_img_vsync_r[5] ;
assign per_img_vsync_7dly = per_img_vsync_r[6] ;
assign per_img_gray_4dly  = per_img_gray_r4    ;
assign per_img_gray_5dly  = per_img_gray_r5    ;
assign post_img_gray  = per_img_gray_5dly   ;
assign post_img_href  = per_img_href_5dly   ;
assign post_img_vsync = per_img_vsync_5dly  ;

assign acc_process_2dly_nege = !acc_process_2dly && acc_process_3dly ;

always @(posedge clk ) begin
    per_img_vsync_r <= {per_img_vsync_r[5:0],per_img_vsync} ; 
    per_img_href_r  <= {per_img_href_r [4:0],per_img_href } ; 
    per_img_gray_r1 <= per_img_gray    ;
    per_img_gray_r2 <= per_img_gray_r1 ;
    per_img_gray_r3 <= per_img_gray_r2 ;
    per_img_gray_r4 <= per_img_gray_r3 ;
    per_img_gray_r5 <= per_img_gray_r4 ;
end

always @(posedge clk )begin
    per_img_href_dly <= per_img_href ;
end



//pixel counter
always @(posedge clk )begin
    if(per_img_href == 1'b1)
        hcnt <= hcnt + 1'b1;
    else
        hcnt <= 11'b0;
end

//line counter
always @(posedge clk )begin
    if(per_img_vsync == 1'b0)
        vcnt <= 11'b0;
    else if(img_href_neg == 1'b1)
        vcnt <= vcnt + 1'b1;
    else
        vcnt <= vcnt;
end

//delay 4 clock pixel counter
always @(posedge clk )begin
    if(per_img_href_4dly == 1'b1)
        hcnt_4dly <= hcnt_4dly + 1'b1;
    else
        hcnt_4dly <= 11'b0;
end

//delay 4 clock line counter
always @(posedge clk )begin
    if(per_img_vsync_4dly == 1'b0)
        vcnt_4dly <= 11'b0;
    else if(img_href_neg_4dly == 1'b1)
        vcnt_4dly <= vcnt_4dly + 1'b1;
    else
        vcnt_4dly <= vcnt_4dly;
end

always @(posedge clk )begin
    if(per_img_href_3dly == 1'b1)
        hcnt_3dly <= hcnt_3dly + 1'b1;
    else
        hcnt_3dly <= 11'b0;
end

always @(posedge clk )begin
    if(per_img_vsync_3dly == 1'b0)
        vcnt_3dly <= 11'b0;
    else if(img_href_neg_3dly == 1'b1)
        vcnt_3dly <= vcnt_3dly + 1'b1;
    else
        vcnt_3dly <= vcnt_3dly;
end

always @(posedge clk )begin
    hcnt_5dly <= hcnt_4dly ;
    hcnt_6dly <= hcnt_5dly ;
    vcnt_5dly <= vcnt_4dly ;
    vcnt_6dly <= vcnt_5dly ;
end



//Set read enable and this signal must enable at second line
always @(posedge clk ) begin
    if (per_img_href && vcnt >= 1) begin
        r_addr <= r_addr + 1 ;
        ren_label <= 1 ;
    end
    else begin
        ren_label <= 0 ;
        r_addr    <= 0 ;
    end
end

//Set write enable and this signal must 4 clock cycles ahead
always @(posedge clk ) begin
    if (per_img_href_4dly ) begin
        w_addr <= w_addr + 1 ;
        wen_label <= 1 ;
    end
    else begin
        wen_label <= 0 ;
        w_addr    <= 0 ;
    end
end


//Neighborhood label generation
assign left = cur_label ;
always @(posedge clk ) begin
    left_r    <= cur_label   ;
    right_up <= rdata_label ;
    up       <= right_up    ;
    left_up  <= up          ;
end

//Generate cur_label
always @(posedge clk) begin
    if(!per_img_vsync_4dly)begin
        cnt_label <= 1 ;
    end
    //first line
    else if (per_img_vsync_4dly && vcnt_4dly == 0) begin
        if (per_img_href_4dly) begin
            if (per_img_gray_4dly == 255) begin
                if (cur_label != 0) begin
                    cur_label <= cur_label; 
                end
                else begin
                    cur_label <= cnt_label; 
                    cnt_label <= cnt_label + 1;
                end
            end
            else begin
                cur_label <= 0; 
            end
        end
    end
    //left edge
    else if (per_img_vsync_4dly) begin
        if (per_img_href_4dly && hcnt_4dly == 0 ) begin
            if (per_img_gray_4dly == 255) begin
                if (up || right_up) begin
                    if(!right_up )
                        cur_label <= up ; 
                    else
                        cur_label <= right_up ;
                end
                else begin
                    cur_label <= cnt_label; 
                    cnt_label <= cnt_label + 1;
                end
            end
            else begin
                cur_label <= 0; 
            end
        end
        //Right edge
        else if (per_img_href_4dly && hcnt_4dly == WIDTH-1) begin
            if (per_img_gray_4dly == 255) begin
                if ((up != 0) || (left_up != 0) || (left != 0)) begin
                    cur_label <= (up != 0 && (up <= left_up || left_up == 0) && (up <= left || left == 0)) ? up :
                                (left_up != 0 && (left_up <= up || up == 0) && (left_up <= left || left == 0)) ? left_up :
                                left; 
                end
                else begin
                    cur_label <= cnt_label;
                    cnt_label <= cnt_label + 1;
                end
            end
            else begin
                cur_label <= 0;
            end   
        end
        //normal data
        else if (per_img_href_4dly) begin
            if (per_img_gray_4dly == 255) begin
                if ((up != 0) || (left_up != 0) || (right_up != 0) || (left != 0)) begin
                    cur_label <= (up != 0 && (up <= left_up || left_up == 0) && (up <= right_up || right_up == 0) && (up <= left || left == 0)) ? up :
                                (left_up != 0 && (left_up <= up || up == 0) && (left_up <= right_up || right_up == 0) && (left_up <= left || left == 0)) ? left_up :
                                (right_up != 0 && (right_up <= up || up == 0) && (right_up <= left_up || left_up == 0) && (right_up <= left || left == 0)) ? right_up :
                                left; 
                end
                else begin
                    cur_label <= cnt_label; 
                    cnt_label <= cnt_label + 1;
                end
            end
            else begin
                cur_label <= 0; 
            end   
        end
    end
end


always @(posedge clk ) begin
    cur_label_1dly <= cur_label ;
    cur_label_2dly <= cur_label_1dly ;
    cur_label_3dly <= cur_label_2dly ;
    cur_label_4dly <= cur_label_3dly ;
end


always @(posedge clk)begin
    wen_den_r[0] <= wen_label    ;
    wen_den_r[1] <= wen_den_r[0] ;
    wen_den_r[2] <= wen_den_r[1] ;
    wen_den_r[3] <= wen_den_r[2] ;
end


always @(posedge clk )begin
    cache_den_addr_2 <= cache_den_addr_1 ;
    cache_den_data_2 <= cache_den_data_1 ;
    if(init_ram)begin
        w_den_value <= 0 ;
        cache_den_addr_1 <= 0 ;
        cache_den_data_1 <= 0 ;
    end
    else if (per_img_vsync_4dly || wen_den) begin   
        //normal data
        if(wen_den_r[0] )begin
            if(cache_den_addr_1 == cur_label_1dly)begin
                cache_den_addr_1 <= cur_label_1dly ;
                w_den_value <= cache_den_data_1 + 1 ;
                cache_den_data_1 <= cache_den_data_1 + 1 ;
            end
            else if(cache_den_addr_2 == cur_label_1dly)begin
                cache_den_addr_1 <= cache_den_addr_2 ;
                cache_den_data_1 <= cache_den_data_2 + 1 ;
                w_den_value <= cache_den_data_2 + 1 ;
            end
            else begin
                cache_den_data_1 <= r_den_value + 1 ;
                w_den_value <= r_den_value + 1 ;
                cache_den_addr_1 <= cur_label_1dly;
            end
        end
    end
end

//Molecule Part

always @(posedge clk)begin
    wen_mol_x_r[0] <= wen_label    ;
    wen_mol_x_r[1] <= wen_mol_x_r[0] ;
    wen_mol_x_r[2] <= wen_mol_x_r[1] ;
    wen_mol_x_r[3] <= wen_mol_x_r[2] ;
end

//Read, change, and write to RAM; define two registers to save the value of modified
always @(posedge clk )begin
    cache_mol_addr_2 <= cache_mol_addr_1 ;
    cache_mol_data_2 <= cache_mol_data_1 ;
    if(init_ram)begin
        w_mol_x_value <= 0 ; 
        cache_mol_addr_1 <= 0;
        cache_mol_data_1 <= 0;
    end
    else if (per_img_vsync_4dly || wen_mol_x) begin   
        //normal data
        if(wen_mol_x_r[0])begin
            if(cache_mol_addr_1 == cur_label_1dly)begin
                cache_mol_addr_1 <= cur_label_1dly ;
                w_mol_x_value <= cache_mol_data_1 + hcnt_5dly ;
                cache_mol_data_1 <= cache_mol_data_1 + hcnt_5dly ;
            end
            else if(cache_mol_addr_2 == cur_label_1dly)begin
                cache_mol_addr_1 <= cache_mol_addr_2 ;
                cache_mol_data_1 <= cache_mol_data_2 + hcnt_5dly ;
                w_mol_x_value <= cache_mol_data_2 + hcnt_5dly ;
            end
            else begin
                cache_mol_data_1 <= r_mol_x_value + hcnt_5dly ;
                w_mol_x_value <= r_mol_x_value + hcnt_5dly ;
                cache_mol_addr_1 <= cur_label_1dly;
            end
        end
    end
end

always @(posedge clk)begin
    wen_mol_y_r[0] <= wen_label    ;
    wen_mol_y_r[1] <= wen_mol_y_r[0] ;
    wen_mol_y_r[2] <= wen_mol_y_r[1] ;
    wen_mol_y_r[3] <= wen_mol_y_r[2] ;
end


always @(posedge clk )begin
    cache_mol_addry_2 <= cache_mol_addry_1 ;
    cache_mol_datay_2 <= cache_mol_datay_1 ;
    if(init_ram)begin
        w_mol_y_value <= 0 ; 
        cache_mol_addry_1 <= 0;
        cache_mol_datay_1 <= 0;
    end
    else if (per_img_vsync_4dly || wen_mol_y) begin   
        //normal data
        if(wen_mol_x_r[0])begin
            if(cache_mol_addry_1 == cur_label_1dly)begin
                cache_mol_addry_1 <= cur_label_1dly ;
                w_mol_y_value <= cache_mol_datay_1 + vcnt_5dly+1 ;
                cache_mol_datay_1 <= cache_mol_datay_1 + vcnt_5dly+1 ;
            end
            else if(cache_mol_addry_2 == cur_label_1dly)begin
                cache_mol_addry_1 <= cache_mol_addry_2 ;
                cache_mol_datay_1 <= cache_mol_datay_2 + vcnt_5dly+1 ;
                w_mol_y_value <= cache_mol_datay_2 + vcnt_5dly+1 ;
            end
            else begin
                cache_mol_datay_1 <= r_mol_y_value + vcnt_5dly+1 ;
                w_mol_y_value <= r_mol_y_value + vcnt_5dly+1 ;
                cache_mol_addry_1 <= cur_label_1dly;
            end
        end
    end
end


//label union and find

//union label 
always @(posedge clk ) begin
    //left edge
    if (per_img_vsync_5dly && vcnt_5dly > 0 ) begin
        if (per_img_href_5dly && hcnt_4dly == 1 ) begin
            if (per_img_gray_5dly == 255) begin
                label1 <= 0             ;
                label2 <= up            ;
                label3 <= right_up      ;
                label4 <= 0             ;
                label5 <= cur_label     ;
                union_req <= 1 ;    //enable union request
            end
            else begin
                union_req <= 0; 
            end
        end

        //Right edge
        else if (per_img_href_5dly && hcnt_4dly == WIDTH) begin
            if (per_img_gray_5dly == 255) begin
                label1 <= left_up       ;
                label2 <= up            ;
                label3 <= 0             ;
                label4 <= left_r        ;
                label5 <= cur_label     ;
                union_req <= 1 ;    //enable union request
            end
            else begin
                union_req <= 0; 
            end
        end
        //normal data
        else if (per_img_href_5dly) begin
            if (per_img_gray_5dly == 255) begin
                label1 <= left_up       ;
                label2 <= up            ;
                label3 <= right_up      ;
                label4 <= left_r        ;
                label5 <= cur_label     ;
                union_req <= 1 ;    //enable union request                    
            end
            else begin
                union_req <= 0; 
            end             
        end
    end 
    else if (img_vsync_nge_6dly) begin
        label1 <= 1 ;
    end
    else if (acc_process) begin
        if (root_label == label1 ) begin
            label1 <= label1 + 1 ;        
        end
        else begin
            label1 <= label1 ;
        end        
    end
    else begin
        union_req <= 0 ;
    end  
end



always @(posedge clk ) begin
    root_out_1dly <= root_label ;
    acc_process_1dly <= acc_process ;
    acc_process_2dly <= acc_process_1dly ;
    acc_process_3dly <= acc_process_2dly ;
    root_out_2dly <= root_out_1dly ;
end

assign find_req = acc_process ;
always @(posedge clk ) begin
    if (img_vsync_nge_6dly) begin
        acc_process <= 1 ; 
        find_root_cnt <= 1 ;
    end
    else if (find_root_cnt >= 255) begin
        acc_process <= 0 ;
    end
    else if (acc_process) begin
        if (find_root_cnt < 255) begin
            find_root_cnt <= find_root_cnt + 1 ;          
        end     
    end
    else begin  
        acc_process <= acc_process ;
    end
end

//denomintor accumuolate

always @(posedge clk)begin
    if(img_vsync_nge_6dly)begin
        cnt_den_addr <= 1 ;
    end
    else if(root_valid)begin
        cnt_den_addr <= cnt_den_addr + 1 ;
    end
    else begin
        
    end
end
always @(posedge clk ) begin
    if(root_valid)begin
        den_acc[root_label] <= den_acc[root_label] + r_den_value ;  
    end
    else if (init_ram) begin
        den_acc[init_add-1] <= 0 ;
    end
    else begin
        addr_den_acc <= 0 ;
    end
end

//molucule x accumuolate

always @(posedge clk ) begin
    if(root_valid)begin
        mol_x_acc[root_label] <= mol_x_acc[root_label] + r_mol_x_value ;  
    end
    else if (init_ram) begin
        mol_x_acc[init_add-1] <= 0 ;
    end
    else begin
        addr_mol_x_acc <= 0 ;
    end
end

//molucule x accumuolate

always @(posedge clk ) begin
    if(root_valid)begin
        mol_y_acc[root_label] <= mol_y_acc[root_label] + r_mol_y_value ;  
    end
    else if (init_ram) begin
        mol_y_acc[init_add-1] <= 0 ;
    end
    else begin
        addr_mol_y_acc <= 0 ;
    end
end

//calculate centroid

always @(posedge clk ) begin
    if (acc_process_2dly_nege) begin
        ready_output  <= 1 ; 
        ready_out_cnt <= 1 ;
    end
    else if (ready_out_cnt >= 63) begin
        ready_output <= 0 ;
    end
    else if (ready_output) begin
        if (ready_out_cnt < 63) begin
            ready_out_cnt <= ready_out_cnt + 1 ;          
        end     
    end
    else begin  
        ready_output <= ready_output ;
    end
end

//Register intermediate data
always @(posedge clk ) begin
    if (ready_output) begin
        temp_x_acc <= mol_x_acc[ready_out_cnt]<<5 ;
        temp_y_acc <= mol_y_acc[ready_out_cnt]<<5 ;
        temp_d_acc <= den_acc[ready_out_cnt]       ;
    end
    else begin
        temp_x_acc <= 0 ;
        temp_y_acc <= 0 ;
        temp_d_acc <= 0 ;
    end
end

//Calculate the coordinates and area
always @(posedge clk ) begin
    if (ready_output) begin   
        if(!temp_d_acc) begin
            area <= 0 ;
            x    <= 0 ;
            y    <= 0 ;   
        end  
        else begin
            area <= temp_d_acc ;
            x    <= (temp_x_acc / temp_d_acc) ;
            y    <= (temp_y_acc / temp_d_acc) ;   
        end
    end
    else begin
        area <= 0 ;
        x    <= 0 ;
        y    <= 0 ;   
    end
end

//Set the index of each connected domain
always @(posedge clk) begin
    if(ready_output) begin
        if(temp_d_acc)begin
            ccl_index_cnt <= ccl_index_cnt + 1 ;
            ccl_index <= ccl_index_cnt ;
        end
        else begin
            ccl_index <= 0 ;
        end
    end
    else begin
        ccl_index <= 0 ;
        ccl_index_cnt <= 1 ;
    end   
end


//Setting RAM initialize signal
always @(posedge clk)begin
    if(acc_process_2dly_nege)
        init_ram <= 1 ;
    else if(init_add == 63 ) begin
        init_ram <= 0 ;
    end
end

//Setting index of RAM
always @(posedge clk ) begin
    if (init_ram) begin
        init_add <= init_add + 1 ;
    end
    else
        init_add <= 0 ;
end

Simple_dual_port_RAM#(
    .WIDTH (8      ) ,
    .DEPTH (10     )
)line_label_buffer(
    .clk        (clk    ),
    .wea        (1    ),      //enable write signal of channel a
    .enb        (1    ),      //enable signal of channel b

    .addra      (w_addr ),          //address of channel a
    .addrb      (r_addr ),          //address of channle b

    .data_i_a   (cur_label   ),      //data input of channel a
    .data_o_b   (rdata_label )       //data output of channel b
);

Simple_dual_port_RAM#(
    .WIDTH (19     ) ,
    .DEPTH (5      )
)pixel_Denominator(
    .clk        (clk    ),
    .wea        (wen_den    ),      //enable write signal of channel a
    .enb        (ren_den    ),      //enable signal of channel b

    .addra      (w_addr_den[4:0]    ),          //address of channel a
    .addrb      (r_addr_den[4:0]    ),          //address of channle b

    .data_i_a   (w_den_value   ),      //data input of channel a
    .data_o_b   (r_den_value   )       //data output of channel b
);

Simple_dual_port_RAM#(
    .WIDTH (29      ) ,
    .DEPTH (5      )
)pixel_Molecule_X(
    .clk        (clk    ),
    .wea        (wen_mol_x    ),      //enable write signal of channel a
    .enb        (ren_mol_x    ),      //enable signal of channel b

    .addra      (w_addr_mol_x[4:0]    ),          //address of channel a
    .addrb      (r_addr_mol_x[4:0]    ),          //address of channle b

    .data_i_a   (w_mol_x_value   ),      //data input of channel a
    .data_o_b   (r_mol_x_value   )       //data output of channel b
);

Simple_dual_port_RAM#(
    .WIDTH (29      ) ,
    .DEPTH (5      )
)pixel_Molecule_Y(
    .clk        (clk    ),
    .wea        (wen_mol_y    ),      //enable write signal of channel a
    .enb        (ren_mol_y    ),      //enable signal of channel b

    .addra      (w_addr_mol_y[4:0]    ),          //address of channel a
    .addrb      (r_addr_mol_y[4:0]    ),          //address of channle b

    .data_i_a   (w_mol_y_value   ),      //data input of channel a
    .data_o_b   (r_mol_y_value   )       //data output of channel b
);

// Instantiate the equivalence_table module
equivalence_table #(
    .MAX_LABELS(32),
    .LABEL_WIDTH(8)
) u_equivalence_table (
    .clk        (clk),
    
    .label1     (label1     ),
    .label2     (label2     ),
    .label3     (label3     ),
    .label4     (label4     ),
    .label5     (label5     ),
    .find_req   (find_req   ),
    .union_req  (union_req  ),
    .init_flag  (init_ram   ),
    .root_label (root_label ),
    .root_valid (root_valid )
);

endmodule
