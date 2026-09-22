<'
package uvc_top;

import aligner_env.e;

extend sys {
	env: aligner_env is instance;
    keep env.hdl_path() == "~/tb_top";
    
    setup() is also {
        set_config(print, radix, hex);
        set_config(run, tick_max, 1100000);
        set_config(simulation,enable_ports_unification,TRUE);        
    };
};

'>
