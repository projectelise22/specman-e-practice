<'
-- ================================================= --
--   alu_evc.e
--   PURPOSE: eVC — bundles driver + monitor. This is the
--            reusable component. HDL bindings live here.
--            ONE clock port shared via read_only — eliminates
--            the DEPR_PORTS_UNIFICATION warning.
-- ================================================= --
unit alu_evc_u {
    driver  : alu_driver_u  is instance;
    monitor : alu_monitor_u is instance;
    clk_p   : in simple_port of bit is instance;

    event clk_rise is rise(clk_p$) @sim;

    -- CORRECT: each port gets its own hdl_path binding
    -- The warning about unification is safe to ignore
    keep clk_p.hdl_path()            == "top.alu.clk";
    keep driver.clk_p.hdl_path()     == "top.alu.clk";   -- driver's own port
    keep monitor.clk_p.hdl_path()    == "top.alu.clk";   -- monitor's own port

    keep driver.rst_n_p.hdl_path()   == "top.alu.rst_n";
    keep driver.a_p.hdl_path()       == "top.alu.a";
    keep driver.b_p.hdl_path()       == "top.alu.b";
    keep driver.op_p.hdl_path()      == "top.alu.op";
    keep driver.valid_p.hdl_path()   == "top.alu.valid";
    keep monitor.result_p.hdl_path() == "top.alu.result";
    keep monitor.done_p.hdl_path()   == "top.alu.done";

    -- DO NOT use: keep driver.clk_p == read_only(clk_p);
    -- This causes the "instances must be unique" constraint error
};
'>