<'
-- ================================================= --
--   alu_monitor.e
--   PURPOSE: Passively observes DUT outputs. Never drives.
--            Fires result_ready event for scoreboard/coverage.
-- ================================================= --
unit alu_monitor_u {

    clk_p    : in simple_port of bit            is instance;
    result_p : in simple_port of uint (bits: 9) is instance;
    done_p   : in simple_port of bit            is instance;

    !last_result : uint (bits: 9);   -- ! = not randomized, state storage
    !last_op     : alu_op_t;

    event clk_rise     is rise(clk_p$)              @sim;
    -- result_ready fires on any clock edge where done is high
    event result_ready is true(done_p$ == 1) @clk_rise;

    -- monitor_output runs forever in the background
    -- auto-started via run() below — no need to call from env
    monitor_output() @clk_rise is {
        while TRUE {
            wait @result_ready;              -- block until done=1
            last_result = result_p$;         -- sample output
            message(LOW, appendf("[MON] result=0x%03x", last_result));
        };
    };

    -- run() is called automatically by Specman on every unit at sim start
    -- 'is also' extends the default empty run() — does not replace it
    -- start launches monitor_output() as a background thread
    run() is also {
        start monitor_output();
    };
};
'>