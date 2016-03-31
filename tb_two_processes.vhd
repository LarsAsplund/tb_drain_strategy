library vunit_lib;
context vunit_lib.vunit_context;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std_unsigned.all;
use ieee.numeric_std.all;

library osvvm;
use osvvm.RandomPkg.all;

entity tb_two_processes is
  generic (
    runner_cfg : runner_cfg_t);
end entity tb_two_processes;

architecture tb of tb_two_processes is
  constant len : positive := 16;
  signal clk : std_logic := '0';
  signal d, q   : std_logic_vector(7 downto 0);
  shared variable test_vector : integer_vector(1 to 100);
  signal verification_done : boolean := false;
begin
  test_runner: process is
    variable rv : RandomPType ;
  begin
    test_runner_setup(runner, runner_cfg);

    test_vector := rv.RandIntV(0, 2**d'length-1, test_vector'length);
    for i in 1 to test_vector'length loop
      wait until rising_edge(clk);
      d <= to_slv(test_vector(i), d'length);
    end loop;

    wait until verification_done;

    test_runner_cleanup(runner);
  end process test_runner;

  verifier: process is
  begin
    for i in 1 to len + 1 loop
      wait until rising_edge(clk);
    end loop;

    for i in 1 to test_vector'length loop
      wait until rising_edge(clk);
      check_equal(unsigned(q), test_vector(i));
    end loop;

    verification_done <= true;
  end process verifier;

  clk <= not clk after 5 ns;

  dut: entity work.delay
    generic map (
      len => len)
    port map(
      clk => clk,
      d => d,
      q => q);

end architecture tb;
