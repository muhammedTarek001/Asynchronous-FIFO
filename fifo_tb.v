module fifo_tb #(
    parameter WIDTH=8,
    DEPTH = 8,
    PTR_WIDTH=3
);

integer i, j;

integer r_data_old_value;

reg [WIDTH-1:0] w_data_tb;
reg source_w_en_tb, destination_r_en_tb;
reg w_clk_tb , r_clk_tb , reset_tb;

wire [WIDTH-1:0] r_data_tb;
wire w_full_tb, r_empty_tb;

always #5  w_clk_tb = ~w_clk_tb;
always #13 r_clk_tb = ~r_clk_tb;

fifo U0_fifo(
    .w_data(w_data_tb),
    .source_w_en(source_w_en_tb), .destination_r_en(destination_r_en_tb),
    .w_clk(w_clk_tb), .r_clk(r_clk_tb), .reset(reset_tb),
    .r_data(r_data_tb),
    .w_full(w_full_tb), .r_empty(r_empty_tb)
);

initial 
begin
    w_clk_tb =0;
    r_clk_tb =0;
    reset_tb=0;            //reseting fifo
    source_w_en_tb =1;
    destination_r_en_tb =1;
    w_data_tb =0;

end

initial 
begin
  
    #2
    #39
    r_data_old_value= 0;
    for(j=0; j < 100 ; j= j+1)
    begin
        #26
        wait( !r_empty_tb)
        if(r_data_old_value != r_data_tb)
        $display("Error!! data loss reported. old_value=%d, recent value=%d, @time= %d",r_data_old_value , r_data_tb,$time);

        else
        $display("NO error!!,old_value=%d, recent value=%d, @time= %d",r_data_old_value , r_data_tb,$time);

        r_data_old_value= r_data_old_value+1;


    end
end


initial 
begin
    $dumpfile("fifo_tb.vcd");
    $dumpvars;
    
    reset();
    
    //writing @ 8 addresses and waiting for destination to read all what is written
    for(i=0; i < DEPTH ; i= i+1)
    begin
        #10
        
        if( !w_full_tb )
        begin
            source_writes(i+1);
        end
        
        else
        begin
            i= i-1;
            wait( !w_full_tb ) source_writes(i+1); //stop @ full signal =1
        end

    end
    source_w_en_tb =0;

    #16
    source_w_en_tb =1;
    
    //writing continously
    for(i=8; i < DEPTH *10 ; i= i+1)
    begin
        #10
        
        if( !w_full_tb )
        begin
            source_writes(i+1);
        end
        
        else
        begin
            i= i-1;
            wait( !w_full_tb ) source_writes(i+1);
        end

    end
    source_w_en_tb =0;


    
end


task reset();
begin
    reset_tb =0;
    $display("system reseted !!!");
    #3
    reset_tb =1;
end
endtask

task source_writes(input [DEPTH-1 :0] data);
begin
    source_w_en_tb =1;
    w_data_tb = data;
end
endtask


endmodule