package msg_types_pkg is
  constant test_vector_length : positive := 100;
  type msg_type_t is (test);
  type test_msg_t is record
    msg_type : msg_type_t;
    test_vector : integer_vector(1 to test_vector_length);
    last_vector : boolean;
  end record test_msg_t;
end package msg_types_pkg;
