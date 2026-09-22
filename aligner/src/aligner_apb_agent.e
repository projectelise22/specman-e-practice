File: aligner/src/aligner_apb_agent.e
Description: This file implements the APB agent of the aligner tb

<'
import aligner_apb_item.e;
import aligner_apb_driver.e;

unit aligner_apb_agent {

    ------------------------
    -- Configuration
    ------------------------
    
    ------------------------
    -- interface smp
    ------------------------
    !smp : aligner_smp;
    event clk is @smp.rise_clk;

    ------------------------
    -- Driver/Sequencer unit
    ------------------------
    -- Declare sequence driver and driver unit
    seq_drv : apb_seq_driver is instance;
    apb_drv : apb_driver is instance;
    
    -- Connect sequence driver and ports
    connect_pointers() is also {
        apb_drv.seq_drv = seq_drv;
        apb_drv.drv_smp = smp;
    };

    -- emit event for sequence driver clock
    on clk {
        emit seq_drv.clock;
    };

    
    ------------------------
    -- Monitor
    ------------------------

    ------------------------
    -- Coverage
    ------------------------

};
'>