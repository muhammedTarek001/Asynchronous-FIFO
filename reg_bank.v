module reg_bank #(
    parameter WIDTH=8,
    DEPTH = 8,
    PTR_WIDTH=3
) (
    input [PTR_WIDTH : 0] r_ptr, w_ptr,
    input [WIDTH-1:0] w_data,
    input write_en, read_en, 

    input w_clk,r_clk,reset,
    
    output reg [WIDTH-1:0] r_data
);
integer i;

reg [WIDTH-1:0] reg_file [DEPTH-1:0];



always @(posedge r_clk or negedge reset) 
begin
    if(!reset)
    begin
        r_data <= 0;
    end

    else
    begin
        if(read_en)
        begin
            r_data <= reg_file [ r_ptr[PTR_WIDTH-1 : 0] ]; 
        end
    end
end

always @(posedge w_clk or negedge reset) 
begin
    if(!reset)
    begin
        for ( i=0 ;i < DEPTH ;i = i+1 ) 
        begin
            reg_file[i] <= 0;
        end
    end

    else
    begin
        if (write_en) 
        begin
            reg_file[w_ptr [PTR_WIDTH-1 : 0]] <= w_data;

        end
    end
    
end
    
endmodule