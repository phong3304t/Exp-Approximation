library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

use work.ExpApprox_pkg.all;

entity ExpApprox_tb is
end ExpApprox_tb;

architecture sim of ExpApprox_tb is

    signal clk     : std_logic := '0';
    signal rst_n   : std_logic := '0';
    signal start   : std_logic := '0';
    signal done    : std_logic;
    signal t_in    : q2_14;
    signal exp_out : q2_14;

    constant CLK_PERIOD : time := 10 ns;

    -- Convert Q2.14 ? real
    function q2_14_to_real(x : q2_14) return real is
    begin
        return real(to_integer(x)) / (2.0**14);
    end function;

    -- Convert real ? Q2.14
    function real_to_q2_14(x : real) return q2_14 is
        variable tmp : integer;
    begin
        tmp := integer(x * (2.0**14));
        return to_signed(tmp, 16);
    end function;

begin

    ----------------------------------------------------------------
    -- DUT
    ----------------------------------------------------------------
    DUT : entity work.ExpApprox
        port map (
            clk     => clk,
            rst_n   => rst_n,
            start   => start,
            t_in    => t_in,
            done    => done,
            exp_out => exp_out
        );

    ----------------------------------------------------------------
    -- Clock
    ----------------------------------------------------------------
    clk_process : process
    begin
        clk <= '0';
        wait for CLK_PERIOD/2;
        clk <= '1';
        wait for CLK_PERIOD/2;
    end process;

    ----------------------------------------------------------------
    -- Stimulus
    ----------------------------------------------------------------
    stim_proc : process
        variable t_real   : real;
        variable hw_real  : real;
        variable ref_real : real;
    begin

        ------------------------------------------------------------
        -- Reset
        ------------------------------------------------------------
        rst_n <= '0';
        wait for 50 ns;
        rst_n <= '1';
        wait for 20 ns;

        ------------------------------------------------------------
        -- Test cases
        ------------------------------------------------------------
        for k in -2 to 2 loop
            t_real := real(k) * 0.5;   -- -1.0, -0.5, 0, 0.5, 1.0
            t_in   <= real_to_q2_14(t_real);

            start <= '1';
            wait for CLK_PERIOD;
            start <= '0';

            -- Wait for done
            wait until done = '1';
            wait for CLK_PERIOD;

            hw_real  := q2_14_to_real(exp_out);
            ref_real := exp(t_real);

            report "---------------------------------------";
            report "t        = " & real'image(t_real);
            report "HW exp   = " & real'image(hw_real);
            report "REF exp  = " & real'image(ref_real);
            report "ERROR    = " & real'image(hw_real - ref_real);

            wait for 50 ns;
        end loop;

        ------------------------------------------------------------
        report "Simulation finished.";
        wait;
    end process;

end sim;

