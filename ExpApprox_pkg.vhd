library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package ExpApprox_pkg is

    -- ======================
    -- Global parameters
    -- ======================
    constant WIDTH : integer := 16;   -- Q2.14
    constant FRAC  : integer := 14;
    constant N     : integer := 15;

    subtype q2_14 is signed(WIDTH-1 downto 0);

    -- ======================
    -- LUT: atanh(2^-i) Q2.14
    -- ======================
    type lut_type is array (1 to N) of q2_14;

    constant LUT : lut_type := (
        to_signed(9000, WIDTH),
        to_signed(4184, WIDTH),
        to_signed(2058, WIDTH),
        to_signed(1025, WIDTH),
        to_signed(512,  WIDTH),
        to_signed(256,  WIDTH),
        to_signed(127,  WIDTH),
        to_signed(63,   WIDTH),
        to_signed(31,   WIDTH),
        to_signed(16,   WIDTH),
        to_signed(8,    WIDTH),
        to_signed(4,    WIDTH),
        to_signed(2,    WIDTH),
        to_signed(1,    WIDTH),
        to_signed(1,    WIDTH)
    );

    -- ======================
    -- 1/K for hyperbolic CORDIC
    -- ======================
    constant INV_K : q2_14 := to_signed(19660, WIDTH);

    -- ======================
    -- Helper function (TB/debug)
    -- ======================
    function q2_14_to_real(x : q2_14) return real;

end package ExpApprox_pkg;

package body ExpApprox_pkg is
    function q2_14_to_real(x : q2_14) return real is
    begin
        return real(to_integer(x)) / real(2**FRAC);
    end function;
end package body ExpApprox_pkg;

