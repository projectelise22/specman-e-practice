<'
-- ================================================= --
--   alu_evc.e : monitor + driver wrapper with clk
-- ================================================= --

unit alu_evc_u {

  -- driver and monitor instance
  driver  : alu_driver_u  is instance;
  monitor : alu_monitor_u is instance;
  
  -- clk port instance
  clk_p   : in simple_port of bit is instance;
  
  -- connect clk_p to both driver and monitor
  keep driver.clk_p  == read_only(clk_p);
  keep monitor.clk_p == read_only(clk_p);
  
  -- HDL binding
  -- relative to simulation top
  -- format: 'module_name.signal_name'
  
  keep clk_p.hdl_path()            == "alu.clk";
  keep driver.rst_n_p.hdl_path()   == "alu.rst_n";
  keep driver.a_p.hdl_path()       == "alu.a";
  keep driver.b_p.hdl_path()       == "alu.b";
  keep driver.op_p.hdl_path()      == "alu.op";
  keep driver.valid_p.hdl_path()   == "alu.valid";
  keep monitor.result_p.hdl_path() == "alu.result";
  keep monitor.done_p.hdl_path()     == "alu.done";

}; -- alu_evc_u
'>
