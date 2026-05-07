<'
-- ================================================= --
--   alu_coverage.e : Coverage for TB
-- ================================================= --

unit alu_coverage_u {

  -- reference to monitor
  monitor: alu_monitor_u;
  
  -- sampled values
  !sampled_op     : alu_op_t;
  !sampled_a_high : bool; -- TRUE if a >= 128
  !sampled_b_zero : bool; -- TRUE if b == 0
  
  -- update sampled values when monitor sees result ready event
  on monitor.result_ready {
    sampled_op     = monitor.last_op;
    sampled_a_high = monitor.last_result >= 128;
    sampled_b_zero = monitor.last_result == 0;
  }
  
  -- coverage
  cover monitor.result_ready using per_unit_instance is {
    -- for all 4 opcodes
    item op : alu_op_t = sampled_op;
    
    -- for a value
    item a_high : bool = sampled_a_high using text = "a >= 128";
    
    -- for b value
    item b_zero : bool = sampled_b_zero using text = "b == 0";
    
    cross op, a_high;
  };
  
  
}; -- alu_coverage_u
'>