library vunit_lib;
context vunit_lib.vunit_context;
use vunit_lib.array_pkg.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std_unsigned.all;
use ieee.numeric_std.all;

entity tb_using_phase_synchronization_and_many_test_cases is
  generic (
    runner_cfg : runner_cfg_t);
end entity tb_using_phase_synchronization_and_many_test_cases;

architecture tb of tb_using_phase_synchronization_and_many_test_cases is
  constant len : positive := 16;
  signal clk : std_logic := '0';
  signal d, q   : std_logic_vector(7 downto 0);
begin
  test_runner: process is
    variable test_vector : array_t;
  begin
    test_runner_setup(runner, runner_cfg);

    while test_suite loop
      entry_gate(runner);
      if run("Test with some data") then
        test_vector.load_csv("some_data.csv");
      elsif run("Test with some other data") then
        test_vector.load_csv("some_other_data.csv");
      end if;

      for i in 0 to test_vector.length-1 loop
        wait until rising_edge(clk);
        d <= to_slv(test_vector.get(i), d'length);
      end loop;
    end loop;

    test_runner_cleanup(runner);
  end process test_runner;

  verifier: process is
    variable result_vector : array_t;
  begin
    lock_exit(runner, test_runner_cleanup);
    wait_until(runner, test_case_setup);

    if active_test_case = "Test with some data" then
      result_vector.load_csv("some_data.csv");
    elsif active_test_case = "Test with some other data" then
      result_vector.load_csv("some_other_data.csv");
    else
      check_failed("Unknown test case");
    end if;

    for i in 1 to len + 1 loop
      wait until rising_edge(clk);
    end loop;

    for i in 0 to result_vector.length-1 loop
      wait until rising_edge(clk);
      check_equal(unsigned(q), result_vector.get(i));
    end loop;

    unlock_exit(runner, test_runner_cleanup);
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
