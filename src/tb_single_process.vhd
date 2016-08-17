library vunit_lib;
context vunit_lib.vunit_context;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std_unsigned.all;
use ieee.numeric_std.all;

library osvvm;
use osvvm.RandomPkg.all;

entity tb_single_process is
  generic (
    runner_cfg : runner_cfg_t);
end entity tb_single_process;

architecture tb of tb_single_process is
  constant len : positive := 16;
  signal clk : std_logic := '0';
  signal d, q   : std_logic_vector(7 downto 0);
begin
  test_runner: process is
    variable rv : RandomPType ;
    variable test_vector : integer_vector(1 to 100);
  begin
    test_runner_setup(runner, runner_cfg);

    test_vector := rv.RandIntV(0, 2**d'length-1, test_vector'length);
    for i in 1 to test_vector'length + len loop
      wait until rising_edge(clk);

      if i <= test_vector'length then
        d <= to_slv(test_vector(i), d'length);
      end if;

      if i > len + 1 then
        check_equal(unsigned(q), test_vector(i-len-1));
      end if;
    end loop;

    test_runner_cleanup(runner);
  end process test_runner;

  clk <= not clk after 5 ns;

  dut: entity work.delay
    generic map (
      len => len)
    port map(
      clk => clk,
      d => d,
      q => q);

end architecture tb;
