<'
-- ================================================= --
--   alu_env.e
--   PURPOSE: Wires everything together. Test uses AOP
--            (extend) to add run_env() without modifying env.
-- ================================================= --
unit alu_env_u {
    evc        : alu_evc_u        is instance;   -- creates eVC + driver + monitor
    seq        : alu_random_seq_u is instance;
    corner_seq : alu_corner_seq_u is instance;
    cov        : alu_coverage_u   is instance;
    scb        : alu_scoreboard_u is instance;

    -- read_only(): inject references into units that need them
    -- These are NOT new instances — just pointers to existing ones
    keep seq.driver            == read_only(evc.driver);
    keep seq.scoreboard        == read_only(scb);
    keep corner_seq.driver     == read_only(evc.driver);
    keep corner_seq.scoreboard == read_only(scb);
    keep cov.monitor           == read_only(evc.monitor);
    keep scb.monitor           == read_only(evc.monitor);
};

-- AOP: extend adds run_env() to alu_env_u from outside the file
-- This is the test — the env file itself never needs to change
extend alu_env_u {
    run_env() @evc.clk_rise is {
        evc.driver.drive_reset();

        all of {
            -- Branch 1: drive all stimulus then stop the simulation
            {
                seq.run_start();
                corner_seq.run_start();
                stop_run();   -- clean simulation end (like $finish)
                              -- signals all of to unblock when this branch ends
            };
            -- Branch 2: scoreboard runs in background (auto-started via run())
            -- We still include it here so all of waits for both
            -- (though stop_run in branch 1 will end everything)
        };

        message(LOW, "--- Test Complete ---");
    };
};

-- extend sys: mandatory entry point
-- Part 1: instantiate the env so it exists
-- Part 2: use sys.run() to launch run_env() as a background TCM
--         sys.run() is NOT a TCM — cannot use wait/@ directly
--         so we use 'start' to fire run_env() as a concurrent thread
extend sys {
    env : alu_env_u is instance;

    run() is also {
        start env.run_env();   -- launch the TCM thread and return
                               -- simulation continues, clock ticks,
                               -- run_env() runs concurrently
    };
};
'>