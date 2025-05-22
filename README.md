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
3. **Synthesis**: Use FPGA tools (e.g., Xilinx Vivado, Altera Quartus) to map the design to the FPGA.
4. **Implementation**: Load the design onto the FPGA and connect it to the traffic light hardware.
5. **Testing**: Verify operation in a real or simulated intersection.

## Traffic light controller Logic

![image](https://github.com/user-attachments/assets/f698f643-a4a2-4a96-9849-6565bd3b7920)


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



