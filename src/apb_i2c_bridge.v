`timescale 1ns / 1ps

module apb_i2c_bridge (
    // AMBA APB Interface
    input  wire        pclk,      // System clock
    input  wire        presetn,   // Active-low reset
    input  wire        psel,      // Peripheral select
    input  wire        penable,   // Enable signal (Access phase)
    input  wire        pwrite,    // Direction (1=Write, 0=Read)
    input  wire [7:0]  paddr,     // Register Address
    input  wire [7:0]  pwdata,    // Write data
    output reg  [7:0]  prdata,    // Read data
    output reg         pready,    // Ready signal (stall the bus if busy)

    // I2C Physical Interface
    output reg         scl,       // I2C Clock
    input  wire        sda_in,    // I2C Data Input
    output reg         sda_out,   // I2C Data Output
    output reg         sda_oe     // I2C Data Output Enable (1 = Drive, 0 = High-Z)
);

    // FSM State Encodings (Using localparam for clean synthesis)
    localparam IDLE       = 3'b000;
    localparam START      = 3'b001;
    localparam DATA_SHIFT = 3'b010;
    localparam ACK_PHASE  = 3'b011;
    localparam STOP       = 3'b100;

    reg [2:0] state;
    reg [7:0] shift_reg;
    reg [2:0] bit_cnt;    // Counts 0 to 7 (8 bits)

    // Main FSM Sequential Logic
    always @(posedge pclk or negedge presetn) begin
        if (!presetn) begin
            state    <= IDLE;
            pready   <= 1'b1;
            scl      <= 1'b1;
            sda_out  <= 1'b1;
            sda_oe   <= 1'b1; // Drive high by default
            bit_cnt  <= 3'd7;
            prdata   <= 8'h00;
        end else begin
            case (state)
                IDLE: begin
                    pready  <= 1'b1;  // Bus is free
                    scl     <= 1'b1;
                    sda_out <= 1'b1;
                    sda_oe  <= 1'b1;
                    
                    // Detect APB Access Phase (Valid request)
                    if (psel && penable) begin
                        pready    <= 1'b0; // STALL THE APB BUS IMMEDIATELY
                        shift_reg <= pwdata; 
                        state     <= START;
                    end
                end

                START: begin
                    sda_out <= 1'b0; // I2C Start Condition: SDA goes low while SCL is high
                    state   <= DATA_SHIFT;
                    bit_cnt <= 3'd7; // Reset bit counter for MSB first
                end

                DATA_SHIFT: begin
                    scl <= ~scl; // Toggle I2C Clock
                    
                    if (!scl) begin
                        // When SCL is LOW: Change Data
                        sda_out <= shift_reg[bit_cnt];
                    end else begin
                        // When SCL is HIGH: Data is stable, slave reads it
                        if (bit_cnt == 0) begin
                            state <= ACK_PHASE;
                        end else begin
                            bit_cnt <= bit_cnt - 1;
                        end
                    end
                end

                ACK_PHASE: begin
                    scl <= ~scl; // Continue clocking
                    
                    if (!scl) begin
                        // Release SDA line (High-Z) so slave can pull it low to ACK
                        sda_oe <= 1'b0; 
                    end else begin
                        // Sample the ACK here in a full implementation
                        // For this bridge, we transition to STOP
                        state <= STOP;
                    end
                end

                STOP: begin
                    scl     <= 1'b1;
                    sda_oe  <= 1'b1; // Take control of SDA back
                    sda_out <= 1'b1; // I2C Stop Condition: SDA goes high while SCL is high
                    
                    pready  <= 1'b1; // UNSTALL THE APB BUS
                    state   <= IDLE;
                end
                
                default: state <= IDLE;
            endcase
        end
    end

endmodule
