library ieee;
use ieee.std_logic_1164.all;

entity delay is
  generic (
    len : positive);
  port (
    clk : in  std_logic;
    d   : in  std_logic_vector;
    q   : out std_logic_vector);
end entity delay;

architecture behavioral of delay is
begin
  main: process is
    type delay_line_t is array (natural range <>) of std_logic_vector(d'range);
    variable delay_line : delay_line_t(1 to len);
  begin
    wait until rising_edge(clk);
    delay_line(2 to len) := delay_line(1 to len-1);
    delay_line(1) := d;
    q <= delay_line(delay_line'right);
  end process main;
end architecture behavioral;
