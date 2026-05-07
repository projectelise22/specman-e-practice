<'
-- ================================================= --
--   alu_monitor.e : Monitor for TB
-- ================================================= --

unit alu_monitor_u {

  -- Ports
  clk_p    : in simple_port of bit            is instance;
  result_p : in simple_port of uint (bits: 9) is instance;
  done_p   : in simple_port of bit            is instance;
  
  -- State Fields
  !last_result : uint (bits: 9);
  !last_op     : alu_op_t;
  
  -- Events
  event result_ready is true(done_p$ == 1) @clk_p$;
  
  monitor_output() @clk_p is {
    while TRUE {
      -- Wait until done signal is high
      wait @result_ready;
      
      -- Sample and store result
      last_result = result_p$;
      message(LOW, "[MON] Result observed: 0x%0x", last_result);
    };
  };
}; -- alu_monitor_u
'>