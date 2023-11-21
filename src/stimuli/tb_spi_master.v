module tb;

    localparam CLK_PERIOD       = 100;

    reg     clk_i;
    reg     rst_i;
    reg     push;
    wire    start;
    wire    done;
    wire    reset;
    wire    fetch;
    wire    spi_sclk;
    wire    spi_sdo;
    wire    spi_cs;

    spi_master u_spi_master (
        .*
    );

    initial clk_i = 0;
    initial rst_i = 1;
    always #(CLK_PERIOD/2.0) clk_i = ~clk_i;

    initial begin
        push  = 0;
        
        @(negedge clk_i)
        rst_i = 0;
        push  = 1;

        @(negedge clk_i)
        push  = 0;

        wait (done);
        #(CLK_PERIOD);

        @(negedge clk_i)
        push  = 1;

        @(negedge clk_i)
        push  = 0;

        wait (fetch)
        #(CLK_PERIOD);

        $display("%c[1;32m",27);
        $display("SUCCESS\n");
        $display("%c[0m",27);

	    $finish;
    end

endmodule