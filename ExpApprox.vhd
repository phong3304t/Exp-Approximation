library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.ExpApprox_pkg.all;

entity ExpApprox is
    port (
        clk     : in  std_logic;
        rst_n   : in  std_logic;
        start   : in  std_logic;
        t_in    : in  q2_14;
        done    : out std_logic;
        exp_out : out q2_14
    );
end ExpApprox;

architecture rtl of ExpApprox is

    -- Control signals
    signal init_dp  : std_logic;
    signal iter_pos : std_logic;
    signal iter_dp  : std_logic;
    signal inc_i    : std_logic;
    signal out_ld   : std_logic;  -- FIX: thêm cho kh?p controller

    -- Condition feedback
    signal i_lt_N   : std_logic;
    signal Z_lt_0   : std_logic;

begin

    ------------------------------------------------------------------
    -- Controller
    ------------------------------------------------------------------
    U_CTRL : entity work.ExpApprox_Controller
        port map (
            clk      => clk,
            rst_n    => rst_n,
            start    => start,

            i_lt_N   => i_lt_N,
            Z_lt_0   => Z_lt_0,

            init_dp  => init_dp,
            iter_dp  => iter_dp,
            iter_pos => iter_pos,
            inc_i    => inc_i,
            out_ld   => out_ld,   -- FIX
            done     => done
        );

    ------------------------------------------------------------------
    -- Datapath
    ------------------------------------------------------------------
    U_DP : entity work.ExpApprox_Datapath
        port map (
            clk      => clk,
            rst_n    => rst_n,

            init_dp  => init_dp,
            iter_dp  => iter_dp,
            iter_pos => iter_pos,
            inc_i    => inc_i,

            t_in     => t_in,

            i_lt_N   => i_lt_N,
            Z_lt_0   => Z_lt_0,
            out_ld   => out_ld,
            exp_out  => exp_out
        );

end rtl;


