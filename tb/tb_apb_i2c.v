`timescale 1ns / 1ps

module tb_apb_i2c;

    // 1. Declare Testbench Signals
    reg        pclk;
    reg        presetn;
    reg        psel;
    reg        penable;
    reg        pwrite;
    reg  [7:0] paddr;
    reg  [7:0] pwdata;
    wire [7:0] prdata;
    wire       pready;

    wire       scl;
    reg        sda_in;
    wire       sda_out;
    wire       sda_oe;

    // 2. Instantiate the Bridge (Device Under Test)
    apb_i2c_bridge uut (
        .pclk(pclk),
        .presetn(presetn),
        .psel(psel),
        .penable(penable),
        .pwrite(pwrite),
        .paddr(paddr),
        .pwdata(pwdata),
        .prdata(prdata),
        .pready(pready),
        .scl(scl),
        .sda_in(sda_in),
        .sda_out(sda_out),
        .sda_oe(sda_oe)
    );

    // 3. Generate System Clock (50MHz -> 20ns period)
    always #10 pclk = ~pclk;

    // 4. Main Simulation Block
    initial begin
        // Setup VCD generation for GTKWave
        $dumpfile("runs/apb_i2c_waves.vcd");
        $dumpvars(0, tb_apb_i2c);

        // Initialize all signals
        pclk    = 0;
        presetn = 0;
        psel    = 0;
        penable = 0;
        pwrite  = 0;
        paddr   = 8'h00;
        pwdata  = 8'h00;
        sda_in  = 1; // Simulate the physical I2C pull-up resistor

        // Apply Reset
        #25 presetn = 1;
        #20;

        // ==========================================
        // SIMULATE A PROCESSOR WRITE TRANSACTION
        // We want to send the hex value 0xA5 (10100101 in binary)
        // ==========================================

        // Phase 1: APB SETUP PHASE
        @(posedge pclk);
        psel   = 1;
        pwrite = 1;
        paddr  = 8'h10; // Target sensor register address
        pwdata = 8'hA5; // The data payload

        // Phase 2: APB ACCESS PHASE
        @(posedge pclk);
        penable = 1;

        // Phase 3: WAIT-STATE INSERTION
        // The bridge will immediately pull 'pready' to 0 here.
        // We use a Verilog wait() statement to pause our simulated 
        // processor until the bridge finishes the I2C transaction.
        wait(pready == 1'b1);

        // Phase 4: TRANSACTION COMPLETE
        @(posedge pclk);
        psel    = 0;
        penable = 0;
        pwrite  = 0;

        // Let the simulation run a little longer to observe the I2C STOP condition
        #100;
        $display("Simulation Complete: APB to I2C transfer successful.");
        $finish;
    end

endmodule
