# Traffic Light Controller
A **traffic light controller using FPGA** is a digital system implemented on a Field-Programmable Gate Array (FPGA) to manage the operation of traffic lights at an intersection. It controls the sequence and timing of traffic signals (red, yellow, green) to ensure smooth and safe traffic flow. FPGAs are used because they offer flexibility, high-speed processing, and the ability to implement custom logic for real-time control.

### Key Components and Functionality
1. **FPGA**: A programmable hardware device that allows designers to implement custom digital circuits using hardware description languages (HDL) like VHDL or Verilog.
2. **State Machine**: The controller typically uses a finite state machine (FSM) to define the sequence of light changes (e.g., Green → Yellow → Red → Green for each direction).
3. **Timing Control**: Timers are implemented to manage the duration of each light phase (e.g., 30 seconds for green, 5 seconds for yellow).
4. **Inputs**:
   - Clock signal for timing.
   - Sensors (e.g., vehicle or pedestrian detectors) to adapt to traffic conditions.
   - Manual inputs (e.g., emergency override).
5. **Outputs**:
   - Signals to control the traffic lights (e.g., turning on/off red, yellow, green LEDs or relays).
6. **Optional Features**:
   - Adaptive control based on traffic density.
   - Pedestrian crossing signals.
   - Emergency vehicle priority.

### How It Works
- The FPGA is programmed with HDL code to define the logic of the traffic light sequence.
- The FSM cycles through states (e.g., "North-South Green," "North-South Yellow," "East-West Green") based on timers or sensor inputs.
- The FPGA processes inputs in real-time and sends appropriate signals to the traffic lights.
- The design can be reconfigured for different intersections or traffic patterns by updating the FPGA's programming.

### Advantages of Using FPGA
- **Customizability**: Easily modify timing or logic for specific intersections.
- **Speed**: FPGAs process signals in parallel, ensuring low-latency control.
- **Reliability**: Hardware-based implementation is robust and less prone to software crashes.
- **Scalability**: Can handle complex intersections with multiple lanes or pedestrian signals.

### Example Workflow
1. **Design**: Create an FSM in VHDL/Verilog to define light sequences (e.g., Green for 30s, Yellow for 5s, Red for 35s).
2. **Simulation**: Test the design using tools like ModelSim to verify timing and logic.
3. **Synthesis**: Use FPGA tools  to map the design to the FPGA.
4. **Implementation**: Load the design onto the FPGA and connect it to the traffic light hardware.
5. **Testing**: Verify operation in a real or simulated intersection.

## Traffic light controller Logic

<img src="https://github.com/user-attachments/assets/f698f643-a4a2-4a96-9849-6565bd3b7920" width="600" />







This diagram represents the state transitions of a traffic light controller for an intersection with two main roads (M1 and M2) and a side road (S), implemented using an FPGA. Each state shows the traffic light status (Green, Yellow, Red) for each direction and the transitions between states, labeled with conditions like TMG, TY, and TTG. 

### Intersection Layout
- **M1 and M2**: Two main roads, likely in opposite directions (e.g., North-South and East-West).
- **S**: A side road intersecting the main roads.
- Traffic lights control the flow in each direction, with M1 and M2 typically prioritized over S.

### State Descriptions
Each state shows the light status for M1, M2, and S:
- **Green (G)**: Vehicles can go.
- **Yellow (Y)**: Transition phase, prepare to stop.
- **Red (R)**: Vehicles must stop.

#### 1. **Top Row (Left to Right)**
- **State 1 (TMG)**: 
  - M1: Green (vehicles on M1 can go).
  - M2: Red (vehicles on M2 must stop).
  - S: Red (vehicles on S must stop).
  - **Transition (TMG)**: Stays in this state for a "Main Green Timer" (TMG) duration, ensuring M1 has enough time for traffic flow.
- **State 2 (TY)**:
  - M1: Yellow (M1 traffic prepares to stop).
  - M2: Red.
  - S: Red.
  - **Transition (TY)**: After TMG expires, M1 switches to Yellow for a "Yellow Timer" (TY) duration as a transition phase.
- **State 3 (TTG)**:
  - M1: Red.
  - M2: Green (M2 traffic can now go).
  - S: Red.
  - **Transition (TTG)**: After TY expires, M2 gets a "Through Traffic Green" (TTG) timer, allowing M2 traffic to flow.

#### 2. **Bottom Row (Left to Right)**
- **State 4 (TY)**:
  - M1: Yellow.
  - M2: Yellow (M2 traffic prepares to stop).
  - S: Red.
  - **Transition (TY)**: After TTG expires, M2 switches to Yellow for the TY duration.
- **State 5 (TSG)**:
  - M1: Red.
  - M2: Red.
  - S: Green (side road traffic can now go).
  - **Transition (TSG)**: After TY expires, S gets a "Side Green Timer" (TSG), allowing side road traffic to flow.
- **State 6 (TY)**:
  - M1: Red.
  - M2: Red.
  - S: Yellow (S traffic prepares to stop).
  - **Transition (TY)**: After TSG expires, S switches to Yellow for the TY duration, then loops back to State 1 (M1 Green).

### Transition Conditions
- **TMG (Main Green Timer)**: Duration for M1 to stay Green.
- **TY (Yellow Timer)**: Duration for the Yellow phase during transitions.
- **TTG (Through Traffic Green)**: Duration for M2 to stay Green.
- **TSG (Side Green Timer)**: Duration for S to stay Green.


## Verilog code for the FPGA

To implement the Traffic Light Controller in the [VSDSquadronFM](https://www.vlsisystemdesign.com/vsdsquadronfm/) or any FPGA board first we need a [**Verilog HDL**](https://github.com/Ahtesham18112011/Traffic_controller_VSDSquadronFM/blob/main/traffic_controller.v) or VHDL code that is understood by Hardware. So here i will focus on the Verilog HDL code.

### Analysis of the verilog code

      ``` `timescale 1ns / 1ps
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

endmodule ```

## Steps for implementation in VSDSquadronFM

1. Open the virtulal Ubuntu Software and open the Linux terminal (Download [Oracle Virtual box](https://www.virtualbox.org/) for virtual Ubuntu software)
2. Clone my Github repository by typing this in the terminal

         git clone https://github.com/Ahtesham18112011/Traffic_controller_VSDSquadronFM.git

3. Then type,

         cd Implementation

4. Then type,

         make build

5.  Then connect your VSDSquadronFM board, and type,

         sudo make flash








