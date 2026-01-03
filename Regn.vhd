library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.ExpApprox_pkg.all;

entity Regn is
    port (
        clk   : in  std_logic;
        rst_n : in  std_logic;   -- async reset, active-low
        en    : in  std_logic;
        d     : in  q2_14;
        q     : out q2_14
    );
end entity;

architecture rtl of Regn is
begin
    process(clk, rst_n)
    begin
        if rst_n = '0' then
            q <= (others => '0');
        elsif rising_edge(clk) then
            if en = '1' then
                q <= d;
            end if;
        end if;
    end process;
end architecture;

