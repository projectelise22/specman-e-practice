<'
-- ================================================= --
--   alu_driver.e : Driver for TB
-- ================================================= --

unit alu_driver_u {

  -- Ports
  clk_p   : in  simple_port of bit            is instance;
  rst_n_p : in  simple_port of bit            is instance;
  a_p     : out simple_port of uint (bits: 8) is instance;
  b_p     : out simple_port of uint (bits: 8) is instance;
  op_p    : out simple_port of uint (bits: 2) is instance;
  valid_p : out simple_port of bit            is instance;
  
  -- Driver reset method
  drive_reset() @clk_p$ is {
    rst_n_p$ = 0;
    wait [5];
    rst_n_p$ = 1;
    wait [2];
  };
  
  drive_packet(pkt: alu_packet_s) @clk_p$ is {
    -- Wait for next rising clk edge before driving
    @clk_p$;
    
    -- Drive all inputs simultaneously
    a_p$     = pkt.a;
    b_p$     = pkt.b;
    op_p$    = pkt.op.as_a(uint);
    valid_p$ = 1;
    
    -- Hold valid
    @clk_p$;
    
    -- Deassert valid;
    valid_p$ = 0;
  };

}; -- alu_driver_u
'>