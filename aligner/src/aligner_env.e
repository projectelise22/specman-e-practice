File: aligner_env.e
Description: Aligner environment unit

<'
import aligner_smp.e;
import aligner_apb_agent.e;

unit aligner_env like any_env {
    -- Port instance
    smp : aligner_smp is instance;

    -- APB Agent
    apb_agt : aligner_apb_agent is instance;
    
    -- Connect dv units
    connect_pointers() is also {
    	apb_agt.smp = smp;
    };

    -- Start dv units
    run() is also {
        start apb_agt.apb_drv.drive();
    };

};
'>