================================================================
File: aligner/src/aligner_apb_agent.e
Description: This file implements the APB agent of the aligner tb
================================================================
<'
import aligner_apb_item.e;
import aligner_apb_driver.e;
import aligner_apb_collector.e;
import aligner_apb_monitor.e;

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

    ------------------------------------
    -- Collector/Monitor/Scoreboard unit
    ------------------------------------
    -- Declare collector, monitor, and scoreboard units
    apb_col : aligner_apb_collector is instance;
    apb_mon : aligner_apb_monitor is instance;

    -- Connect e ports
    connect_pointers() is also{
        apb_col.smp = smp;
    };

    -- Connect tlm ports
    connect_ports() is also {
        apb_col.col2mon_o.connect(apb_mon.col2mon_i);
    };

    ------------------------
    -- Coverage
    ------------------------

};
'>