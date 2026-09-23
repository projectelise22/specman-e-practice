File: aligner_env.e
Description: Aligner environment unit

================================================================
File: aligner_env.e
Description: Environment unit for Aligner
================================================================
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

    -- Start driver and monitor tcms
    run() is also {
        start apb_agt.apb_drv.drive();
        start apb_agt.apb_col.write_to_mon();
    };

};
'>