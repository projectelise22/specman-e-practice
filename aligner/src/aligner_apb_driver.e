File: aligner_apb_driver.e
Description: Contains the following
             - base sequence with item, created_kind, created_driver
             - actual driver implementation
                - reset method
                - drive method
            - extension of MAIN sequence to create sequence for APB
                - write -> read -> compare
<'
-- APB Base Sequence
sequence apb_base_seq using
    item           = apb_item,
    created_kind   = apb_seq_kind,
    created_driver = apb_seq_driver;

-- APB Driver
unit apb_driver {
    !drv_smp : aligner_smp;
    !seq_drv : apb_seq_driver;
    !tr      : apb_item;

    -- reset method
    reset() is {
        drv_smp.reset_n$ = 0;
        drv_smp.paddr$   = 0x0;
        drv_smp.psel$    = 0;
        drv_smp.penable$ = 0;
        drv_smp.pwrite$  = 0;
        drv_smp.pwdata$  = 0x0;
    };

    -- drive to DUT
    drive() @drv_smp.rise_clk is {
        reset();
        wait [2] * cycle;

        while (TRUE) {
            tr = seq_drv.get_next_item();
            message(LOW, "[DRV] Sending new transaction");
            print tr;

            wait [tr.pre_drv_dly] * cycle;

            drv_smp.psel$   = 1;
            drv_smp.pwrite$ = tr.pwrite;
            drv_smp.paddr$  = tr.paddr;

            if (tr.pwrite == 1) {
                drv_smp.pwdata$ = tr.pwdata;
            };

            wait cycle;

            drv_smp.penable$ = 1;

            wait true(drv_smp.pready$ == 1);

            drv_smp.psel$    = 0;
            drv_smp.penable$ = 0;
            drv_smp.pwrite$  = 0;
            drv_smp.paddr$   = 0x0;
            drv_smp.pwdata$  = 0x0;

            wait [tr.post_drv_dly] * cycle;
            
            emit seq_drv.item_done;
            message(LOW, "[DRV] Sending completed");
        };
    };
};
'>

Base sequence using MAIN
<'
extend MAIN apb_base_seq {
    !wr_item : apb_item;
    !rd_item : apb_item;

    body() @driver.clock is only{
        -- Create 5 transaction of write -> read
        for i from 1 to 5 {
            -- Do a write first
            do wr_item keeping {
                .pwrite == 1;
            };

            -- Do a read after
            do rd_item keeping {
                .pwrite == 0;
                .paddr  == wr_item.paddr;
            };
        };

        wait [20] * cycle;
        message(LOW, "Base test sequence ended");
        stop_run();
    };

};
'>