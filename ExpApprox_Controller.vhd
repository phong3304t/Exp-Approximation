library ieee;
use ieee.std_logic_1164.all;
use work.ExpApprox_pkg.all;

entity ExpApprox_Controller is
    port (
        clk     : in  std_logic;
        rst_n   : in  std_logic;
        start   : in  std_logic;

        -- datapath
        i_lt_N  : in  std_logic;  -- i < N
        Z_lt_0  : in  std_logic;  -- Z < 0

        -- Control to datapath
        init_dp  : out std_logic;
        iter_dp  : out std_logic;
        iter_pos : out std_logic;
        inc_i    : out std_logic;
        out_ld   : out std_logic;
        done     : out std_logic
    );
end ExpApprox_Controller;

architecture rtl of ExpApprox_Controller is

    type state_type is (
        S0, S1, S2, S3, S4, S5,
        S6, S7, S8, S9, S10, S11
    );

    signal state, next_state : state_type;

begin

    -- State register
    process(clk, rst_n)
    begin
        if rst_n = '0' then
            state <= S0;
        elsif rising_edge(clk) then
            state <= next_state;
        end if;
    end process;

    -- Next-state logic
    process(state, start, i_lt_N, Z_lt_0)
    begin
        next_state <= state;

        case state is
            when S0 =>
                next_state <= S1;

            when S1 =>
                if start = '1' then
                    next_state <= S2;
                end if;

            when S2 =>
                next_state <= S3;

            when S3 =>
                if i_lt_N = '1' then
                    next_state <= S4;
                else
                    next_state <= S8;
                end if;

            when S4 =>
                if Z_lt_0 = '1' then
                    next_state <= S5;
                else
                    next_state <= S6;
                end if;

            when S5 =>
                next_state <= S7;

            when S6 =>
                next_state <= S7;

            when S7 =>
                next_state <= S3;

            when S8 =>
                next_state <= S9;

            when S9 =>
                next_state <= S10;

            when S10 =>
                if start = '0' then
                    next_state <= S11;
                end if;

            when S11 =>
                next_state <= S0;
        end case;
    end process;


    -- Output control (Moore FSM) 
    process(state)
    begin
        -- defaults
        init_dp  <= '0';
        iter_dp  <= '0';
        iter_pos <= '0';
        inc_i    <= '0';
        out_ld   <= '0';
        done     <= '0';

        case state is
            -- Init datapath
            when S2 =>
                init_dp <= '1';

            -- ITERATION: Z < 0
            when S5 =>
                iter_dp  <= '1';
                iter_pos <= '0';   -- Z < 0 => subtract

            -- ITERATION: Z >= 0
            when S6 =>
                iter_dp  <= '1';
                iter_pos <= '1';   -- Z >= 0 => add

            -- Increment i
            when S7 =>
                inc_i <= '1';

            -- set output
	when S8 =>
  		out_ld <= '1';
            when S9 =>
              
                done   <= '1';

            when others =>
                null;
        end case;
    end process;

end rtl;

