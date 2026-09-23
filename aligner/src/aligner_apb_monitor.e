================================================================
File: aligner_apb_monitor.e
Description: Monitor for Aligner APB
================================================================
<'
unit aligner_apb_monitor {
    -- Fields
    !tr : apb_item;
    col2mon_i : in interface_port of tlm_analysis of apb_item is instance;
    mon2scb_o : out interface_port of tlm_analysis of apb_item is instance;

    -- Constraints
    keep {
        bind(col2mon_i, empty);
        bind(mon2scb_o, empty);
    };

    -- col2mon write() implementation
    write(new_apb_item: apb_item) is {
        tr = new_apb_item;
        message(NONE, "Got apb item from collector");
        print tr;
        --mon2scb_o$.write(tr);
    };
};
'>