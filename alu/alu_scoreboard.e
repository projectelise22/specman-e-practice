<'
-- ================================================= --
--   alu_scoreboard.e
--   PURPOSE: Compares DUT output to expected.
--            Uses local event alias to satisfy e's
--            const-path requirement for 'on' and 'cover'.
-- ================================================= --
unit alu_scoreboard_u {
    monitor     : alu_monitor_u;    -- reference, not instance
    !expected_q : list of alu_packet_s;   -- FIFO queue of expected results

    -- Local event alias: required because 'monitor' is an injected
    -- reference (non-const path). e's 'on' clause needs a const path.
    -- This aliases monitor.result_ready through a locally-owned event.
    event result_ready is @monitor.result_ready;

    push_expected(pkt: alu_packet_s) is {
        expected_q.add(pkt);   -- called by sequence BEFORE driving
    };

    -- check_results: runs forever, checks each result as it arrives
    -- Named check_results (not run) to avoid TCM redeclaration conflict
    check_results() @monitor.clk_rise is {
        while TRUE {
            wait @result_ready;
            var actual : uint (bits:9) = monitor.last_result;
            if expected_q.size() == 0 {
                dut_error("[SCB] Result received but queue is empty!");
            } else {
                var exp : alu_packet_s = expected_q.pop0();   -- pop front (FIFO)
                if actual != exp.expected_result {
                    dut_error(appendf("[SCB] FAIL | Exp:0x%03x Got:0x%03x",
                                      exp.expected_result, actual));
                } else {
                    out(appendf("[SCB] PASS | Exp:0x%03x Got:0x%03x",
                                exp.expected_result, actual));
                };
            };
        };
    };

    -- Auto-start check_results — same pattern as monitor_output
    run() is also {
        start check_results();
    };
};
'>
