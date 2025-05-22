`timescale 1ns / 1ps
// Module definition for the Traffic Light Controller using an FPGA
module Traffic_Light_Controller(
    input clk, rst,                  // Inputs: Clock signal (clk) and Reset signal (rst)
    output reg [2:0] light_M1,       // Output: 3-bit signal controlling lights for Main road 1 (M1: Green, Yellow, Red)
    output reg [2:0] light_S,        // Output: 3-bit signal controlling lights for Side road (S: Green, Yellow, Red)
    output reg [2:0] light_MT,       // Output: 3-bit signal controlling lights for Main Through road (MT: Green, Yellow, Red)
    output reg [2:0] light_M2        // Output: 3-bit signal controlling lights for Main road 2 (M2: Green, Yellow, Red)
);

// State parameters for the Finite State Machine (FSM), matching the 6 states in the diagram
parameter S1=0, S2=1, S3=2, S4=3, S5=4, S6=5;

// Internal registers
reg [3:0] count;    // 4-bit counter to track time in each state
reg [2:0] ps;       // 3-bit register to store the present state of the FSM

// Timer parameters for state durations (in clock cycles, assuming 1 cycle = 1 second for simplicity)
parameter sec7=7, sec5=5, sec2=2, sec3=3;  // Durations: 7s (Main Green), 5s (Through Green), 2s (Yellow), 3s (Side Green)

// Sequential logic block: Handles state transitions and counter updates on clock or reset
always @(posedge clk or posedge rst) begin
    if (rst == 1) begin
        ps <= S1;       // On reset, go to initial state S1 (M1 Green)
        count <= 0;     // Reset the counter
    end
    else begin
        // State machine transitions based on the current state (ps) and counter
        case (ps)
            // State S1: M1 Green, M2 Green, MT Red, S Red (TMG phase)
            S1: if (count < sec7) begin
                    ps <= S1;       // Stay in S1 until the 7-second timer expires
                    count <= count + 1;
                end
                else begin
                    ps <= S2;       // Move to S2 (M1 Green, M2 Yellow) after 7 seconds
                    count <= 0;     // Reset counter for the next state
                end

            // State S2: M1 Green, M2 Yellow, MT Red, S Red (TY phase)
            S2: if (count < sec2) begin
                    ps <= S2;       // Stay in S2 for 2 seconds (Yellow duration)
                    count <= count + 1;
                end
                else begin
                    ps <= S3;       // Move to S3 (M1 Green, MT Green) after 2 seconds
                    count <= 0;
                end

            // State S3: M1 Green, M2 Red, MT Green, S Red (TTG phase)
            S3: if (count < sec5) begin
                    ps <= S3;       // Stay in S3 for 5 seconds
                    count <= count + 1;
                end
                else begin
                    ps <= S4;       // Move to S4 (M1 Yellow, MT Yellow) after 5 seconds
                    count <= 0;
                end

            // State S4: M1 Yellow, M2 Red, MT Yellow, S Red (TY phase)
            S4: if (count < sec2) begin
                    ps <= S4;       // Stay in S4 for 2 seconds
                    count <= count + 1;
                end
                else begin
                    ps <= S5;       // Move to S5 (S Green) after 2 seconds
                    count <= 0;
                end

            // State S5: M1 Red, M2 Red, MT Red, S Green (TSG phase)
            S5: if (count < sec3) begin
                    ps <= S5;       // Stay in S5 for 3 seconds
                    count <= count + 1;
                end
                else begin
                    ps <= S6;       // Move to S6 (S Yellow) after 3 seconds
                    count <= 0;
                end

            // State S6: M1 Red, M2 Red, MT Red, S Yellow (TY phase)
            S6: if (count < sec2) begin
                    ps <= S6;       // Stay in S6 for 2 seconds
                    count <= count + 1;
                end
                else begin
                    ps <= S1;       // Loop back to S1 (M1 Green) after 2 seconds
                    count <= 0;
                end

            // Default case: If an invalid state is reached, go back to S1
            default: ps <= S1;
        endcase
    end
end

// Combinational logic block: Sets the traffic light outputs based on the current state
always @(ps) begin
    case (ps)
        // State S1: M1 and M2 Green, MT and S Red (Main roads prioritized)
        S1: begin
            light_M1 <= 3'b001;  // M1 Green (001 = Green, 010 = Yellow, 100 = Red)
            light_M2 <= 3'b001;  // M2 Green
            light_MT <= 3'b100;  // MT Red
            light_S  <= 3'b100;  // S Red
        end

        // State S2: M1 Green, M2 Yellow (transition), MT Red, S Red
        S2: begin
            light_M1 <= 3'b001;  // M1 Green
            light_M2 <= 3'b010;  // M2 Yellow
            light_MT <= 3'b100;  // MT Red
            light_S  <= 3'b100;  // S Red
        end

        // State S3: M1 Green, M2 Red, MT Green, S Red
        S3: begin
            light_M1 <= 3'b001;  // M1 Green
            light_M2 <= 3'b100;  // M2 Red
            light_MT <= 3'b001;  // MT Green
            light_S  <= 3'b100;  // S Red
        end

        // State S4: M1 Yellow (transition), M2 Red, MT Yellow, S Red
        S4: begin
            light_M1 <= 3'b010;  // M1 Yellow
            light_M2 <= 3'b100;  // M2 Red
            light_MT <= 3'b010;  // MT Yellow
            light_S  <= 3'b100;  // S Red
        end

        // State S5: M1 Red, M2 Red, MT Red, S Green (Side road prioritized)
        S5: begin
            light_M1 <= 3'b100;  // M1 Red
            light_M2 <= 3'b100;  // M2 Red
            light_MT <= 3'b100;  // MT Red
            light_S  <= 3'b001;  // S Green
        end

        // State S6: M1 Red, M2 Red, MT Red, S Yellow (transition)
        S6: begin
            light_M1 <= 3'b100;  // M1 Red
            light_M2 <= 3'b100;  // M2 Red
            light_MT <= 3'b100;  // MT Red
            light_S  <= 3'b010;  // S Yellow
        end

        // Default case: Turn off all lights (safety state)
        default: begin
            light_M1 <= 3'b000;  // All lights off
            light_M2 <= 3'b000;
            light_MT <= 3'b000;
            light_S  <= 3'b000;
        end
    endcase
end

endmodule
