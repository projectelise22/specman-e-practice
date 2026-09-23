================================================================
File: aligner_apb_collector.e
Description: Collector for Aligner APB
================================================================
<'
unit aligner_apb_collector {
    -- Fields
    !smp      : aligner_smp;

    col2mon_o : out interface_port of tlm_analysis of apb_item is instance;
    keep bind(col2mon_o, empty);

    -- Method for pushing transactions to monitor
    -- Sample DUT pins, pack as tr, then write to monitor
    write_to_mon() @smp.rise_clk is {
		while (TRUE) {
          var tr: apb_item = new;
          
          message(LOW, "[COL] Starting to collect new transaction");
          
          wait true(smp.psel$ == 1'b1);
          tr.psel   = smp.psel$;
          tr.paddr  = smp.paddr$;
          tr.pwrite = smp.pwrite$;

          wait true(smp.penable$ == 1'b1);
          tr.penable = smp.penable$;

          wait true(smp.pready$ == 1'b1);
          tr.pready  = smp.pready$;
          tr.pslverr = smp.pslverr$;

          if (tr.pwrite == 0) {
            tr.prdata = smp.prdata$;
          } else {
            tr.pwdata = smp.pwdata$;
          };
          
          message(LOW, "[COL] Done collecting transaction");
          
          -- Push to monitor
          col2mon_o$.write(tr);
		};
    };
};
'>