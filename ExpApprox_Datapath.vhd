library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.ExpApprox_pkg.all;

entity ExpApprox_Datapath is
    port (
        clk     : in  std_logic;
        rst_n   : in  std_logic;

        -- Control from controller
        init_dp  : in  std_logic;
        iter_dp  : in  std_logic;
        iter_pos : in  std_logic;
        inc_i    : in  std_logic;
        out_ld   : in  std_logic;

        -- Input
        t_in    : in  q2_14;

        -- Feedback
        i_lt_N  : out std_logic;
        Z_lt_0  : out std_logic;

        -- Output
        exp_out : out q2_14
    );
end ExpApprox_Datapath;

architecture rtl of ExpApprox_Datapath is

    -- Datapath registers
    signal X_reg, Y_reg, Z_reg : q2_14;

    -- Combinational
    signal X_shift, Y_shift : q2_14;
    signal X_add, Y_add     : q2_14;
    signal X_sub, Y_sub     : q2_14;
    signal Z_add, Z_sub     : q2_14;
    signal X_new, Y_new, Z_new : q2_14;
    signal X_src, Y_src, Z_src : q2_14;
    signal Out_src : q2_14;

    -- Iteration counter
    signal i_cnt : integer range 1 to N;

    -- Enable
    signal en_xyz : std_logic;

begin
    --------------------------------------------------------------------
    -- Output & feedback
    --------------------------------------------------------------------
    Out_src <= X_reg + Y_reg;
    --exp_out <= Out_src when out_ld = '1' else exp_out;

    i_lt_N <= '1' when i_cnt < N else '0';
    Z_lt_0 <= Z_reg(Z_reg'high);

    --------------------------------------------------------------------
    -- Shift & arithmetic
    --------------------------------------------------------------------
    X_shift <= shift_right(X_reg, i_cnt);
    Y_shift <= shift_right(Y_reg, i_cnt);


    X_add <= X_reg + Y_shift;
    Y_add <= Y_reg + X_shift;

    X_sub <= X_reg - Y_shift;
    Y_sub <= Y_reg - X_shift;

    Z_add <= Z_reg + LUT(i_cnt);
    Z_sub <= Z_reg - LUT(i_cnt);

    --------------------------------------------------------------------
    -- Select new values (CORDIC)
    --------------------------------------------------------------------
    X_new <= X_add when iter_pos = '1' else X_sub;
    Y_new <= Y_add when iter_pos = '1' else Y_sub;
    Z_new <= Z_sub when iter_pos = '1' else Z_add;

    --------------------------------------------------------------------
    -- Source mux (init / iter / hold)
    --------------------------------------------------------------------
    X_src <= INV_K when init_dp = '1' else X_new      ;        

    Y_src <= (others => '0')    when init_dp = '1' else
             Y_new   ;           

    Z_src <= t_in               when init_dp = '1' else
             Z_new             ;
    en_xyz <= init_dp or iter_dp;

    --------------------------------------------------------------------
    -- Registers X, Y, Z (q2_14)
    --------------------------------------------------------------------
    reg_x : entity work.Regn
        port map (
            clk   => clk,
            rst_n => rst_n,
            en    => en_xyz,
            d     => X_src,
            q     => X_reg
        );

    reg_y : entity work.Regn
        port map (
            clk   => clk,
            rst_n => rst_n,
            en    => en_xyz,
            d     => Y_src,
            q     => Y_reg
        );

    reg_z : entity work.Regn
        port map (
            clk   => clk,
            rst_n => rst_n,
            en    => en_xyz,
            d     => Z_src,
            q     => Z_reg
        );
    reg_out : entity work.Regn
        port map (
            clk   => clk,
            rst_n => rst_n,
            en    => out_ld,
            d     => Out_src,
            q     => exp_out
        );
    --------------------------------------------------------------------
    -- Iteration counter (KHÔNG dùng Regn)
    --------------------------------------------------------------------
    process(clk, rst_n)
    begin
        if rst_n = '0' then
            i_cnt <= 1;
        elsif rising_edge(clk) then
            if init_dp = '1' then
                i_cnt <= 1;
            elsif inc_i = '1' then
                i_cnt <= i_cnt + 1;
            end if;
        end if;
    end process;

end rtl;

