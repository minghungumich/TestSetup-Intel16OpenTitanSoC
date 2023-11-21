module spi_master(
    // Control Signals
    input       clk_i,      // FPGA Clock
    input       rst_i,      // FPGA Reset
    input       sw_start,   // Start Switch
    input       sw_fetch,   // Fetch Switch
    output      start,      // Start Signal
    output      done,       // Done Signal
    output      reset,      // Reset Signal
    output      fetch,      // Fetch Signal

    // SPI Interface
    output      spi_sclk,   // SPI Clock (Frequency will be half of clk_i)
    output      spi_sdo,    // SPI Data Out
    output      spi_cs      // SPI Enable
);

    localparam TRANSACTION_SIZE = 2;
    localparam IDLE  = 3'd0;
    localparam CMD   = 3'd1; //  8 cycles
    localparam ADDR  = 3'd2; // 32 cycles
    localparam DUMMY = 3'd3; // 34 cycles
    localparam DATA  = 3'd4; // 32 cycles
    localparam DONE  = 3'd5;

    // cmd = 2 (write mem) or 11 (read mem), 8 bits
    // addr = 128, 132, 136 ..., 32 bits
    // data = instruction memory load, 32 bits
    reg [ 3:0]  cmd[TRANSACTION_SIZE-1:0];
    reg [ 7:0] addr[TRANSACTION_SIZE-1:0];
    reg [31:0] data[TRANSACTION_SIZE-1:0];

    reg [3:0] count_w, count_r;
    reg [2:0] state_w, state_r;
    reg [5:0] cycle_w, cycle_r;
    reg start_w, start_r;
    reg done_w, done_r;
    reg fetch_w, fetch_r;
    reg on_w, on_r; // used for only one cycle fetch
    reg spi_sclk_w, spi_sclk_r;
    reg spi_sdo_w, spi_sdo_r;
    reg spi_cs_w, spi_cs_r;

    assign start = start_r;
    assign done = done_r;
    assign reset = rst_i;
    assign fetch = fetch_r;
    assign spi_sclk = spi_sclk_r;
    assign spi_sdo = spi_sdo_r;
    assign spi_cs = spi_cs_r;

    // Stimuli ROM
    initial begin
        // command
        cmd[0] <= 2;
        cmd[1] <= 11;

        // address
        addr[0] <= 100;
        addr[1] <= 100;

        // data
        data[0] <= 100;
        data[1] <= 0;
    end

    always@(*) begin
        count_w = count_r;
        state_w = state_r;
        cycle_w = cycle_r;
        start_w = 0;
        done_w = 0;
        fetch_w = 0;
        on_w = on_r;
        spi_sclk_w = spi_sclk_r;
        spi_sdo_w = spi_sdo_r;
        spi_cs_w = spi_cs_r;

        case (state_r)
            IDLE: begin
                if (sw_start) begin
                    state_w = CMD;
                    cycle_w = 7;
                    start_w = 1;
                    spi_cs_w = 0;
                end
            end
            CMD: begin
                spi_sclk_w = ~spi_sclk_r;
                if (spi_sclk_r) begin
                    cycle_w = cycle_r - 1;
                    if (cycle_r > 4)
                        spi_sdo_w = 0;
                    else if (cycle_r == 0) begin
                        spi_sdo_w = 0; // addr[count_r][31]
                        state_w = ADDR;
                        cycle_w = 31;
                    end else
                        spi_sdo_w = cmd[count_r][cycle_r - 1];
                end
            end
            ADDR: begin
                spi_sclk_w = ~spi_sclk_r;
                if (spi_sclk_r) begin
                    cycle_w = cycle_r - 1;
                    if (cycle_r > 8)
                        spi_sdo_w = 0;
                    else if (cycle_r == 0) begin
                        if (cmd[count_r] == 11) begin
                            spi_sdo_w = 0;
                            state_w = DUMMY;
                            cycle_w = 33;
                        end else begin
                            spi_sdo_w = data[count_r][31];
                            state_w = DATA;
                            cycle_w = 31;
                        end
                    end else
                        spi_sdo_w = addr[count_r][cycle_r - 1];
                end
            end
            DUMMY: begin
                spi_sclk_w = ~spi_sclk_r;
                if (spi_sclk_r) begin
                    cycle_w = cycle_r - 1;
                    spi_sdo_w = 0;
                    if (cycle_r == 0) begin
                        state_w = DATA; // Read Data
                        cycle_w = 31;
                    end
                end
            end
            DATA: begin
                spi_sclk_w = ~spi_sclk_r;
                if (spi_sclk_r) begin
                    cycle_w = cycle_r - 1;
                    spi_sdo_w = data[count_r][cycle_r - 1];
                    if (cycle_r == 0) begin
                        spi_sdo_w = 0; // cmd[count_r][7]
                        if (count_r == TRANSACTION_SIZE-1) begin
                            state_w = DONE;
                        end else begin
                            state_w = CMD;
                            cycle_w = 7;
                            count_w = count_r + 1;
                        end
                    end
                end
            end
            DONE: begin
                state_w = DONE;
                done_w = 1;
                spi_cs_w = 1;
                if (sw_fetch && ~on_r) begin
                    fetch_w = 1;
                    on_w = 1;
                end
            end
        endcase
    end

    always@(posedge clk_i or posedge rst_i) begin
        if (rst_i) begin
            count_r     <= 0;
            state_r     <= 0;
            cycle_r     <= 0;
            start_r     <= 0;
            done_r      <= 0;
            fetch_r     <= 0;
            on_r        <= 0;
            spi_sclk_r  <= 0;
            spi_sdo_r   <= 0;
            spi_cs_r    <= 1;
        end else begin
            count_r     <= count_w;
            state_r     <= state_w;
            cycle_r     <= cycle_w;
            start_r     <= start_w;
            done_r      <= done_w;
            fetch_r     <= fetch_w;
            on_r        <= on_w;
            spi_sclk_r  <= spi_sclk_w;
            spi_sdo_r   <= spi_sdo_w;
            spi_cs_r    <= spi_cs_w;
        end
    end

endmodule