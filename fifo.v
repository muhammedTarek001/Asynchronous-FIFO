module fifo #(
    parameter WIDTH=8,
    DEPTH = 8,
    PTR_WIDTH=3
) (
    input [WIDTH-1:0] w_data,
    input source_w_en, destination_r_en,
    input w_clk, r_clk,reset,

    output [WIDTH-1:0] r_data,
    output w_full, r_empty
);

wire write_en, read_en;

reg [PTR_WIDTH : 0] r_ptr, w_ptr; //write and read addresses
wire [PTR_WIDTH : 0] r_ptr_gray, w_ptr_gray; 

reg [PTR_WIDTH : 0] r_ptr_sync1_g, r_ptr_sync2_g; // with clk = w_clk 
reg [PTR_WIDTH : 0] w_ptr_sync1_g, w_ptr_sync2_g; // with clk = r_clk 

wire [PTR_WIDTH : 0] r_ptr_sync2; //r_ptr_sync2_g after gray code decoding
wire [PTR_WIDTH : 0] w_ptr_sync2; //w_ptr_sync2_g after gray code decoding

//edited
// wire w_full_wire, r_empty_wire;

//gray code encoding
assign w_ptr_gray = w_ptr ^ (w_ptr >> 1);
assign r_ptr_gray = r_ptr ^ (r_ptr >> 1);

//gray code decoding
assign r_ptr_sync2 = r_ptr_sync2_g ^ (r_ptr_sync2_g >>1) ^ (r_ptr_sync2_g >>2) ^ (r_ptr_sync2_g >>3);
assign w_ptr_sync2 = w_ptr_sync2_g ^ (w_ptr_sync2_g >>1) ^ (w_ptr_sync2_g >>2) ^ (w_ptr_sync2_g >>3);

//the place at which we point, we will write at (it is still empty)

always @(posedge w_clk or negedge reset) 
begin
    if(!reset)
    begin
        r_ptr_sync1_g <=0;
        r_ptr_sync2_g <=0;
    end
    else
    begin
        r_ptr_sync1_g <=r_ptr_gray;
        r_ptr_sync2_g <=r_ptr_sync1_g;
    end
end

always @(posedge r_clk or negedge reset) 
begin
    if(!reset)
    begin
        w_ptr_sync1_g <=0;
        w_ptr_sync2_g <=0;
    end
    else
    begin
        w_ptr_sync1_g <=w_ptr_gray;
        w_ptr_sync2_g <=w_ptr_sync1_g;
    end
end
/// needs edit ???
assign w_full = (w_ptr[PTR_WIDTH-1 : 0] == r_ptr_sync2[PTR_WIDTH-1 : 0] &&
w_ptr[PTR_WIDTH] != r_ptr_sync2[PTR_WIDTH]) ? 1:0;  //one place in fifo will be wasted

assign r_empty =(r_ptr[PTR_WIDTH-1 : 0] == w_ptr_sync2[PTR_WIDTH-1 : 0] &&
r_ptr[PTR_WIDTH] == w_ptr_sync2[PTR_WIDTH]) ? 1:0;  //one place in fifo will be wasted

//continue from here

//synchronizers           ---> done
//gray encoding           ---> done
//gray decoding           ---> done
//full & empty conditions ---> pending
//code management         ---> pending

//edited 
// always @(posedge w_clk or negedge reset) 
// begin
//     if(!reset)
//     begin
//         w_full <= 0;
//     end
//     else
//     begin
//         w_full <= w_full_wire;
//     end
// end

// always @(posedge r_clk or negedge reset) 
// begin
//     if(!reset)
//     begin
//         r_empty <= 1;
//     end
//     else
//     begin
//         r_empty <= r_empty_wire;
//     end
// end

assign write_en = source_w_en & (~w_full) ;
assign read_en = destination_r_en & (~r_empty);



always @(posedge w_clk or negedge reset) 
begin
    if(!reset)
    begin
        w_ptr <= 0;
    end

    else
    begin
        if(write_en)
        begin
            if(w_ptr < 2*DEPTH) 
            begin
                w_ptr <= w_ptr + 1;
            end
               
            else
               w_ptr <= 0;
        end

    end

end


always @(posedge r_clk or negedge reset) 
begin
    if(!reset)
    r_ptr <= 0;

    else
    begin
        if (read_en)  //will cause problems due to sync section
        begin
            if(r_ptr < 2*DEPTH)
               r_ptr <= r_ptr + 1;
            else
               r_ptr <= 0;
        end
    end
end



reg_bank U0_reg_bank (
    .r_ptr(r_ptr), .w_ptr(w_ptr),
    .w_data(w_data),
    .write_en(write_en), .read_en(read_en),
    .w_clk(w_clk), .r_clk(r_clk), .reset(reset),
    .r_data(r_data)
);



endmodule