<'
-- ================================================= --
--   alu_driver.e
--   PURPOSE: Drives signals onto DUT. Unit because it needs
--            to live across time and own ports.
-- ================================================= --
unit alu_driver_u {

    -- Ports: out = driver writes to DUT, in = driver reads from DUT
    clk_p   : in  simple_port of bit            is instance;
    rst_n_p : out simple_port of bit            is instance;
    a_p     : out simple_port of uint (bits: 8) is instance;
    b_p     : out simple_port of uint (bits: 8) is instance;
    op_p    : out simple_port of uint (bits: 2) is instance;
    valid_p : out simple_port of bit            is instance;

    -- clk_rise: converts simple_port to a named event
    -- @sim means: trigger is evaluated at simulation time
    -- rise() detects the 0->1 transition of clk
    event clk_rise is rise(clk_p$) @sim;

    -- TCM: @clk_rise makes this method time-aware (like a SV task)
    -- wait [N] = wait N rising edges — cleaner than SV repeat(N)
    drive_reset() @clk_rise is {
        rst_n_p$ = 0;    -- assert reset (active low)
        wait [5];        -- hold 5 clocks
        rst_n_p$ = 1;    -- deassert
        wait [2];        -- settle time
    };

    -- drive_packet: drives one transaction onto DUT inputs
    -- wait @clk_rise = wait for next rising edge (NOT standalone @clk_rise)
    drive_packet(pkt: alu_packet_s) @clk_rise is {
        wait @clk_rise;          -- sync to clock before driving
        a_p$     = pkt.a;
        b_p$     = pkt.b;
        op_p$    = pkt.op.as_a(uint);   -- cast enum to uint for port
        valid_p$ = 1;
        wait @clk_rise;          -- hold valid for one clock
        valid_p$ = 0;
        message(LOW, appendf("[DRV] op=%s a=0x%02x b=0x%02x exp=0x%03x",
                              pkt.op, pkt.a, pkt.b, pkt.expected_result));
    };
};
'>