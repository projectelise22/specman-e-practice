<'
-- ================================================= --
--   alu_seq.e
--   PURPOSE: Generates and sends constrained-random stimulus.
--            Renamed run() -> run_start() to avoid TCM conflict.
-- ================================================= --
unit alu_random_seq_u {
    driver     : alu_driver_u;       -- reference, not instance
    scoreboard : alu_scoreboard_u;   -- reference, not instance

    num_packets : uint;
    keep num_packets == 20;

    run_start() @driver.clk_rise is {
        for i from 1 to num_packets {
            var pkt : alu_packet_s = new;
            gen pkt;   -- constraint solver runs: randomizes a, b, op
                       -- then calls post_generate() automatically
            scoreboard.push_expected(pkt);   -- register BEFORE driving
            driver.drive_packet(pkt);
        };
    };
};

-- Corner sequence: inherits from random seq via 'like'
-- Overrides run_start() with targeted cases
-- 'is' (not 'is also') fully replaces the parent method
unit alu_corner_seq_u like alu_random_seq_u {
    run_start() @driver.clk_rise is {
        var pkt : alu_packet_s;

        -- gen ... keeping { } = inline constraint override for one call
        -- 'it' refers to the object being generated
        gen pkt keeping { it.a == 0xFF; it.b == 0xFF; it.op == ADD; };
        scoreboard.push_expected(pkt);
        driver.drive_packet(pkt);

        gen pkt keeping { it.a == it.b; it.op == SUB; };
        scoreboard.push_expected(pkt);
        driver.drive_packet(pkt);

        gen pkt keeping { it.b == 0; it.op == AND_OP; };
        scoreboard.push_expected(pkt);
        driver.drive_packet(pkt);

        gen pkt keeping { it.b == 0xFF; it.op == OR_OP; };
        scoreboard.push_expected(pkt);
        driver.drive_packet(pkt);
    };
};
'>