-- Entity declaration for the Traffic Light Controller
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Traffic_Light_Controller is
    port (
        clk, rst : in STD_LOGIC;                    -- Inputs: Clock signal (clk) and Reset signal (rst)
        light_M1 : out STD_LOGIC_VECTOR(2 downto 0); -- Output: 3-bit signal for Main road 1 (M1: Green, Yellow, Red)
        light_S  : out STD_LOGIC_VECTOR(2 downto 0); -- Output: 3-bit signal for Side road (S: Green, Yellow, Red)
        light_MT : out STD_LOGIC_VECTOR(2 downto 0); -- Output: 3-bit signal for Main Through road (MT: Green, Yellow, Red)
        light_M2 : out STD_LOGIC_VECTOR(2 downto 0)  -- Output: 3-bit signal for Main road 2 (M2: Green, Yellow, Red)
    );
end entity Traffic_Light_Controller;

architecture Behavioral of Traffic_Light_Controller is
    -- State type definition for the FSM (6 states as per the diagram)
    type state_type is (S1, S2, S3, S4, S5, S6);
    signal ps : state_type := S1;  -- Present state, initialized to S1

    -- Counter signal to track time in each state
    signal count : unsigned(3 downto 0) := (others => '0');  -- 4-bit counter, initialized to 0

    -- Timer constants (in clock cycles, assuming 1 cycle = 1 second for simplicity)
    constant sec7 : integer := 7;  -- 7 seconds for Main Green (TMG)
    constant sec5 : integer := 5;  -- 5 seconds for Through Green (TTG)
    constant sec2 : integer := 2;  -- 2 seconds for Yellow (TY)
    constant sec3 : integer := 3;  -- 3 seconds for Side Green (TSG)

    -- Internal signals for outputs (to assign in a process)
    signal light_M1_int : STD_LOGIC_VECTOR(2 downto 0);
    signal light_S_int  : STD_LOGIC_VECTOR(2 downto 0);
    signal light_MT_int : STD_LOGIC_VECTOR(2 downto 0);
    signal light_M2_int : STD_LOGIC_VECTOR(2 downto 0);

begin
    -- Sequential process: Handles state transitions and counter updates on clock or reset
    process(clk, rst)
    begin
        if rst = '1' then
            ps <= S1;        -- On reset, go to initial state S1 (M1 Green)
            count <= (others => '0');  -- Reset the counter
        elsif rising_edge(clk) then
            case ps is
                -- State S1: M1 Green, M2 Green, MT Red, S Red (TMG phase)
                when S1 =>
                    if count < sec7 then
                        ps <= S1;        -- Stay in S1 until the 7-second timer expires
                        count <= count + 1;
                    else
                        ps <= S2;        -- Move to S2 (M1 Green, M2 Yellow) after 7 seconds
                        count <= (others => '0');  -- Reset counter
                    end if;

                -- State S2: M1 Green, M2 Yellow, MT Red, S Red (TY phase)
                when S2 =>
                    if count < sec2 then
                        ps <= S2;        -- Stay in S2 for 2 seconds (Yellow duration)
                        count <= count + 1;
                    else
                        ps <= S3;        -- Move to S3 (M1 Green, MT Green) after 2 seconds
                        count <= (others => '0');
                    end if;

                -- State S3: M1 Green, M2 Red, MT Green, S Red (TTG phase)
                when S3 =>
                    if count < sec5 then
                        ps <= S3;        -- Stay in S3 for 5 seconds
                        count <= count + 1;
                    else
                        ps <= S4;        -- Move to S4 (M1 Yellow, MT Yellow) after 5 seconds
                        count <= (others => '0');
                    end if;

                -- State S4: M1 Yellow, M2 Red, MT Yellow, S Red (TY phase)
                when S4 =>
                    if count < sec2 then
                        ps <= S4;        -- Stay in S4 for 2 seconds
                        count <= count + 1;
                    else
                        ps <= S5;        -- Move to S5 (S Green) after 2 seconds
                        count <= (others => '0');
                    end if;

                -- State S5: M1 Red, M2 Red, MT Red, S Green (TSG phase)
                when S5 =>
                    if count < sec3 then
                        ps <= S5;        -- Stay in S5 for 3 seconds
                        count <= count + 1;
                    else
                        ps <= S6;        -- Move to S6 (S Yellow) after 3 seconds
                        count <= (others => '0');
                    end if;

                -- State S6: M1 Red, M2 Red, MT Red, S Yellow (TY phase)
                when S6 =>
                    if count < sec2 then
                        ps <= S6;        -- Stay in S6 for 2 seconds
                        count <= count + 1;
                    else
                        ps <= S1;        -- Loop back to S1 (M1 Green) after 2 seconds
                        count <= (others => '0');
                    end if;

                -- Default case (though not needed with enumerated type, added for completeness)
                when others =>
                    ps <= S1;
            end case;
        end if;
    end process;

    -- Combinational process: Sets the traffic light outputs based on the current state
    process(ps)
    begin
        case ps is
            -- State S1: M1 and M2 Green, MT and S Red (Main roads prioritized)
            when S1 =>
                light_M1_int <= "001";  -- M1 Green (001 = Green, 010 = Yellow, 100 = Red)
                light_M2_int <= "001";  -- M2 Green
                light_MT_int <= "100";  -- MT Red
                light_S_int  <= "100";  -- S Red

            -- State S2: M1 Green, M2 Yellow (transition), MT Red, S Red
            when S2 =>
                light_M1_int <= "001";  -- M1 Green
                light_M2_int <= "010";  -- M2 Yellow
                light_MT_int <= "100";  -- MT Red
                light_S_int  <= "100";  -- S Red

            -- State S3: M1 Green, M2 Red, MT Green, S Red
            when S3 =>
                light_M1_int <= "001";  -- M1 Green
                light_M2_int <= "100";  -- M2 Red
                light_MT_int <= "001";  -- MT Green
                light_S_int  <= "100";  -- S Red

            -- State S4: M1 Yellow (transition), M2 Red, MT Yellow, S Red
            when S4 =>
                light_M1_int <= "010";  -- M1 Yellow
                light_M2_int <= "100";  -- M2 Red
                light_MT_int <= "010";  -- MT Yellow
                light_S_int  <= "100";  -- S Red

            -- State S5: M1 Red, M2 Red, MT Red, S Green (Side road prioritized)
            when S5 =>
                light_M1_int <= "100";  -- M1 Red
                light_M2_int <= "100";  -- M2 Red
                light_MT_int <= "100";  -- MT Red
                light_S_int  <= "001";  -- S Green

            -- State S6: M1 Red, M2 Red, MT Red, S Yellow (transition)
            when S6 =>
                light_M1_int <= "100";  -- M1 Red
                light_M2_int <= "100";  -- M2 Red
                light_MT_int <= "100";  -- MT Red
                light_S_int  <= "010";  -- S Yellow

            -- Default case: Turn off all lights (safety state)
            when others =>
                light_M1_int <= "000";  -- All lights off
                light_M2_int <= "000";
                light_MT_int <= "000";
                light_S_int  <= "000";
        end case;
    end process;

    -- Assign internal signals to output ports
    light_M1 <= light_M1_int;
    light_S  <= light_S_int;
    light_MT <= light_MT_int;
    light_M2 <= light_M2_int;

end architecture Behavioral;
