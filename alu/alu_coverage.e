<'
-- ================================================= --
--   alu_coverage.e
-- ================================================= --
unit alu_coverage_u {
    monitor         : alu_monitor_u;
    !sampled_op     : alu_op_t;
    !sampled_a_high : bool;
    !sampled_b_zero : bool;

    -- Local event alias (same reason as scoreboard)
    event result_ready is @monitor.result_ready;

    -- 'on event { }' — reactive block, runs when event fires
    -- Must end with semicolon after the closing brace
    on result_ready {
        sampled_op     = monitor.last_op;
        sampled_a_high = monitor.last_result >= 128;
        sampled_b_zero = monitor.last_result == 0;
    };

    -- cover: attaches coverage group to an event
    -- auto-samples every time result_ready fires — no manual .sample() needed
    cover result_ready using per_unit_instance is {
        item op     : alu_op_t = sampled_op;
        item a_high : bool     = sampled_a_high using text = "a >= 128";
        item b_zero : bool     = sampled_b_zero using text = "b == 0";
        cross op, a_high;   -- cross coverage: every op X every a_high combo
    };
};
'>