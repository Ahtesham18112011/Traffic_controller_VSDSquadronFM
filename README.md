# Traffic Light Controller
A **traffic light controller using FPGA** is a digital system implemented on a Field-Programmable Gate Array (FPGA) to manage the operation of traffic lights at an intersection. It controls the sequence and timing of traffic signals (red, yellow, green) to ensure smooth and safe traffic flow. FPGAs are used because they offer flexibility, high-speed processing, and the ability to implement custom logic for real-time control.

# Table of contents

|Contents| Description | 
|----------|----------|
|1. [**Key Components and Functionality**](#key-components-and-functionality)    | Funtion of the  Traffic Light Controller    |
|2. [**Traffic light controller Logic**](#traffic-light-controller-logic)    | Logic  of  the Traffic Light Controller system     | 
|3. [**Verilog code for the FPGA**](#verilog-code-for-the-fpga)             | Verilog code for  Traffic Light Controller      |  
|4. [**Analysis of the verilog code**](#analysis-of-the-verilog-code) | Verilog code analysis|
|5. [**Steps for implementation in VSDSquadronFM**](#steps-for-implementation-in-vsdsquadronfm) |Implementaion in the VSDSquadronFM|
|6. [**Testing**](#testing) | Testing with LEDs



 


    


## Key Components and Functionality
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

To implement the Traffic Light Controller in the [VSDSquadronFM](https://www.vlsisystemdesign.com/vsdsquadronfm/) or any FPGA board first we need a [Verilog HDL](https://github.com/Ahtesham18112011/Traffic_controller_VSDSquadronFM/blob/main/Implementation/traffic_controller.v) or VHDL code that is understood by Hardware. So here i will focus on the Verilog HDL code.

***********************************************************************************************************************************************************************************
### Analysis of the verilog code
This Verilog code implements a **Traffic Light Controller** for an FPGA, managing traffic lights at an intersection with four roads: Main Road 1 (M1), Main Road 2 (M2), Main Through Road (MT), and Side Road (S). Each road has three lights (Green, Yellow, Red) controlled by 3-bit signals. The controller uses a **Finite State Machine (FSM)** to cycle through six states, determining which lights are active based on time durations. Below is a detailed explanation of the code:

---

### **Module Declaration**
```verilog
module top(
    input clk, rst,                  // Clock and reset inputs
    output reg [2:0] light_M1,       // 3-bit signal for M1 (Green, Yellow, Red)
    output reg [2:0] light_S,        // 3-bit signal for Side road
    output reg [2:0] light_MT,       // 3-bit signal for Main Through road
    output reg [2:0] light_M2        // 3-bit signal for M2
);
```
- **Inputs**:
  - `clk`: Clock signal to synchronize state transitions.
  - `rst`: Active-high reset signal to initialize the system.
- **Outputs**:
  - `light_M1`, `light_M2`, `light_MT`, `light_S`: 3-bit registers for each road's lights, where:
    - `001` = Green
    - `010` = Yellow
    - `100` = Red
    - `000` = Off (used in the default case for safety).

---

### **Parameters**
```verilog
parameter S1=0, S2=1, S3=2, S4=3, S5=4, S6=5;
parameter sec7=7, sec5=5, sec2=2, sec3=3;
```
- **States**: Six states (`S1` to `S6`) represent different phases of the traffic light cycle.
- **Timers**:
  - `sec7`: 7 seconds for Main Green phases.
  - `sec5`: 5 seconds for Through Green phase.
  - `sec2`: 2 seconds for Yellow transitions.
  - `sec3`: 3 seconds for Side Green phase.
- **Assumption**: Each clock cycle is treated as 1 second for simplicity, though in a real FPGA, a clock divider would be used to convert nanoseconds to seconds.

---

### **Internal Registers**
```verilog
reg [3:0] count;    // 4-bit counter for timing state durations
reg [2:0] ps;       // 3-bit register for the present state
```
- `count`: Tracks the time spent in each state (up to 15 clock cycles, sufficient for the longest duration of 7 seconds).
- `ps`: Stores the current state of the FSM (S1 to S6).

---

### **Sequential Logic (State Transitions)**
```verilog
always @(posedge clk or posedge rst) begin
    if (rst == 1) begin
        ps <= S1;       // Reset to S1
        count <= 0;     // Reset counter
    end
    else begin
        case (ps)
            S1: if (count < sec7) begin
                    ps <= S1;       // Stay in S1
                    count <= count + 1;
                end
                else begin
                    ps <= S2;       // Move to S2
                    count <= 0;
                end
            ...
            default: ps <= S1;  // Fallback to S1
        endcase
    end
end
```
- **Purpose**: Updates the FSM state (`ps`) and counter (`count`) on each positive clock edge or reset.
- **Reset Behavior**: If `rst` is high, the FSM resets to state `S1` (M1 and M2 Green), and `count` is cleared.
- **State Transitions**:
  - Each state checks the counter against the required duration (e.g., `sec7` for S1).
  - If the counter is below the duration, the state remains unchanged, and `count` increments.
  - When the counter reaches the duration, the FSM transitions to the next state, and `count` resets to 0.
- **State Sequence**:
  - **S1**: M1 and M2 Green for 7 seconds.
  - **S2**: M2 transitions to Yellow for 2 seconds.
  - **S3**: M1 and MT Green for 5 seconds.
  - **S4**: M1 and MT transition to Yellow for 2 seconds.
  - **S5**: Side road Green for 3 seconds.
  - **S6**: Side road Yellow for 2 seconds, then loops back to S1.
- **Default**: If an invalid state is reached, the FSM returns to `S1`.

---

### **Combinational Logic (Output Control)**
```verilog
always @(ps) begin
    case (ps)
        S1: begin
            light_M1 <= 3'b001;  // M1 Green
            light_M2 <= 3'b001;  // M2 Green
            light_MT <= 3'b100;  // MT Red
            light_S  <= 3'b100;  // S Red
        end
        ...
        default: begin
            light_M1 <= 3'b000;  // All lights off
            light_M2 <= 3'b000;
            light_MT <= 3'b000;
            light_S  <= 3'b000;
        end
    endcase
end
```
- **Purpose**: Sets the traffic light outputs based on the current state (`ps`).
- **Light Encoding**:
  - `001`: Green
  - `010`: Yellow
  - `100`: Red
  - `000`: Off (default safety state).
- **State Outputs**:
  - **S1**: M1 and M2 Green, MT and S Red (Main roads prioritized).
  - **S2**: M1 Green, M2 Yellow (transition), MT and S Red.
  - **S3**: M1 and MT Green, M2 and S Red.
  - **S4**: M1 and MT Yellow (transition), M2 and S Red.
  - **S5**: S Green, M1, M2, and MT Red (Side road prioritized).
  - **S6**: S Yellow (transition), M1, M2, and MT Red.
- **Default**: All lights off to prevent unsafe conditions.

---











## Steps for implementation in [VSDSquadronFM](https://www.vlsisystemdesign.com/vsdsquadronfm/)

1. Open the virtulal Ubuntu Software and open the Linux terminal (Download [Oracle Virtual box](https://www.virtualbox.org/) for virtual Ubuntu software)
2. Clone my Github repository by typing this in the terminal

```shell
git clone https://github.com/Ahtesham18112011/Traffic_controller_VSDSquadronFM.git
```

4. Then type,

```shell
cd Implementation
```

6. Then type,

```shell
make build
```

8.  Then connect your VSDSquadronFM board, and type,

```shell  
sudo make flash
```
***********************************************************************************************************************************************************************************
## Testing
To test, you can use Red,Yellow and Green LEDs. Connect the pins as folows:

| Signal Name   | Pin Number | Description                                      |
|---------------|------------|--------------------------------------------------|
| rst           | 42         | Reset signal (active high) to initialize the FSM to S1 (M1 Green) |
| clk           | 43         | Clock signal for state transitions and timing    |
| light_M1[0]   | 44         | Main Road 1 Green (001 when active)              |
| light_M1[1]   | 45         | Main Road 1 Yellow (010 when active)             |
| light_M1[2]   | 46         | Main Road 1 Red (100 when active)                |
| light_MT[0]   | 47         | Main Through Road Green (001 when active)        |
| light_MT[1]   | 48         | Main Through Road Yellow (010 when active)       |
| light_MT[2]   | 2          | Main Through Road Red (100 when active)          |
| light_M2[0]   | 3          | Main Road 2 Green (001 when active)              |
| light_M2[1]   | 4          | Main Road 2 Yellow (010 when active)             |
| light_M2[2]   | 6          | Main Road 2 Red (100 when active)                |
| light_S[0]    | 9          | Side Road Green (001 when active)                |
| light_S[1]    | 10         | Side Road Yellow (010 when active)               |
| light_S[2]    | 12         | Side Road Red (100 when active)                  |

>[!NOTE]
> We need a clock of frequency 1 hertz, this can be generated with an oscillator, 555 timer etc. I have used an Arduino board to generate a clock of frequency 1Hz, if you have an Arduino board, you can copy the 1Hz generatng code from [here](https://github.com/Ahtesham18112011/Traffic_controller_VSDSquadronFM/blob/main/1hertz.ino#L4)









*************************************************************************************************************************************************************************************************************************

## License

This project is licensed under the MIT License - see the [LICENSE](./LICENSE) file for details.

## Connect with me 
Connect with me in


[<img src="https://cdn.jsdelivr.net/gh/devicons/devicon/icons/linkedin/linkedin-original.svg" width="30"/>](https://www.linkedin.com/in/ahtesham-ahmed-779845365/)

