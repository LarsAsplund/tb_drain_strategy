library vunit_lib;
context vunit_lib.vunit_context;
context vunit_lib.com_context;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std_unsigned.all;
use ieee.numeric_std.all;

library osvvm;
use osvvm.RandomPkg.all;

entity tb_using_com_and_three_processes is
  generic (
    runner_cfg : runner_cfg_t);
end entity tb_using_com_and_three_processes;

architecture tb of tb_using_com_and_three_processes is
  constant len : positive := 16;
  constant test_vector_length : positive := 10;
  signal clk : std_logic := '0';
  signal d, q   : std_logic_vector(7 downto 0);
begin
  test_runner: process is
    variable rv : RandomPType ;
    variable receipt : receipt_t;
    variable status : com_status_t;
    variable test_vector : integer_vector(1 to test_vector_length);
    variable ack : boolean;
    constant self : actor_t := create("test runner");
    constant n_test_vectors : positive := 2;
  begin
    test_runner_setup(runner, runner_cfg);

    for i in 1 to n_test_vectors loop
      test_vector := rv.RandIntV(0, 2**d'length-1, test_vector'length);
      send(net, self, find("driver"), encode(test_vector), receipt);
      send(net, self, find("verifier"), encode(test_vector), receipt);
    end loop;
    receive_reply(net, self, receipt.id, ack, status);

    test_runner_cleanup(runner);
  end process test_runner;

  driver: process
    constant self : actor_t := create("driver");
    variable test_vector : integer_vector(1 to test_vector_length);
    variable message : message_ptr_t;
  begin
    receive(net, self, message);
    test_vector := decode(message.payload.all);

    for i in 1 to test_vector'length loop
      wait until rising_edge(clk);
      d <= to_slv(test_vector(i), d'length);
    end loop;
  end process driver;

  verifier: process is
    constant self : actor_t := create("verifier");
    variable test_vector : integer_vector(1 to test_vector_length);
    variable message : message_ptr_t;
    variable receipt : receipt_t;
    variable is_first : boolean := true;
  begin
    receive(net, self, message);
    test_vector := decode(message.payload.all);

    if is_first then
      for i in 1 to len + 1 loop
        wait until rising_edge(clk);
      end loop;
      is_first := false;
    end if;

    for i in 1 to test_vector'length loop
      wait until rising_edge(clk);
      check_equal(unsigned(q), test_vector(i));
    end loop;

    acknowledge(net, message.sender, message.id, true, receipt);
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
