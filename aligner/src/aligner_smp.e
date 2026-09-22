================================================================
File: aligner/src/aligner_smp.e
Description: This file implements the simple port map to
             communicate with the aligner dut from Udemy class
================================================================
<'

define ALGN_APB_ADDR_WIDTH 16;
define ALGN_APB_DATA_WIDTH 32;
define ALGN_DATA_WIDTH   32;
define ALGN_OFFSET_WIDTH 2;
define ALGN_SIZE_WIDTH   3;

unit aligner_smp {
    -------------------
    -- Port declaration
    -------------------
    -- Global signals
    clk     : simple_port of bit is instance;
    reset_n : simple_port of bit is instance;

    -- APB
    paddr   : simple_port of uint(bits:ALGN_APB_ADDR_WIDTH) is instance;
    pwrite  : simple_port of bit is instance;
    psel    : simple_port of bit is instance;
    penable : simple_port of bit is instance;
    pwdata  : simple_port of uint(bits:ALGN_APB_DATA_WIDTH) is instance;
    prdata  : in simple_port of uint(bits:ALGN_APB_DATA_WIDTH) is instance;
    pready  : in simple_port of bit is instance;
    pslverr : in simple_port of bit is instance;

    -- RX MD
    md_rx_valid  : simple_port of bit is instance;
    md_rx_data   : simple_port of uint(bits:ALGN_DATA_WIDTH) is instance;
    md_rx_offset : simple_port of uint(bits:ALGN_OFFSET_WIDTH) is instance;
    md_rx_size   : simple_port of uint(bits:ALGN_SIZE_WIDTH) is instance;
    md_rx_ready  : in simple_port of bit is instance;
    md_rx_err    : in simple_port of bit is instance;

    -- TX MD
    md_tx_valid  : in simple_port of bit is instance;
    md_tx_data   : in simple_port of uint(bits:ALGN_DATA_WIDTH) is instance;
    md_tx_offset : in simple_port of uint(bits:ALGN_OFFSET_WIDTH) is instance;
    md_tx_size   : in simple_port of uint(bits:ALGN_SIZE_WIDTH) is instance;
    md_tx_ready  : simple_port of bit is instance;
    md_tx_err    : simple_port of bit is instance;

    --------------------
    -- Binding to DUT
    --------------------
    keep {
        bind(clk, external);
        bind(reset_n, external);

        bind(paddr, external);
        bind(pwrite, external);
        bind(psel, external);
        bind(penable, external);
        bind(pwdata, external);
        bind(prdata, external);
        bind(pready, external);
        bind(pslverr, external);

        bind(md_rx_valid, external);
        bind(md_rx_data, external);
        bind(md_rx_offset, external);
        bind(md_rx_size, external);
        bind(md_rx_ready, external);
        bind(md_rx_err, external);

        bind(md_tx_valid, external);
        bind(md_tx_data, external);
        bind(md_tx_offset, external);
        bind(md_tx_size, external);
        bind(md_tx_ready, external);
        bind(md_tx_err, external);
    };

    keep {
        soft clk.hdl_path()     == "clk";
        soft reset_n.hdl_path() == "reset_n";

        soft paddr.hdl_path()   == "paddr";
        soft pwrite.hdl_path()  == "pwrite";
        soft psel.hdl_path()    == "psel";
        soft penable.hdl_path() == "penable";
        soft pwdata.hdl_path()  == "pwdata";
        soft prdata.hdl_path()  == "prdata";
        soft pready.hdl_path()  == "pready";
        soft pslverr.hdl_path() == "pslverr";

        soft md_rx_valid.hdl_path()  == "md_rx_valid";
        soft md_rx_data.hdl_path()   == "md_rx_data";
        soft md_rx_offset.hdl_path() == "md_rx_offset";
        soft md_rx_size.hdl_path()   == "md_rx_size";
        soft md_rx_ready.hdl_path()  == "md_rx_ready";
        soft md_rx_err.hdl_path()    == "md_rx_err";

        soft md_tx_valid.hdl_path()  == "md_tx_valid";
        soft md_tx_data.hdl_path()   == "md_tx_data";
        soft md_tx_offset.hdl_path() == "md_tx_offset";
        soft md_tx_size.hdl_path()   == "md_tx_size";
        soft md_tx_ready.hdl_path()  == "md_tx_ready";
        soft md_tx_err.hdl_path()    == "md_tx_err";
    };

    ----------------------
    -- Event declarations
    ----------------------
    -- Clock event
    event rise_clk is rise(clk$) @sim;

    -- Reset events
    reset_asserted :  bool;
    keep soft reset_asserted == FALSE;

    event reset_asserted_e is fall(reset_n$) and true(reset_asserted == FALSE) @rise_clk;

    on reset_asserted_e {
        reset_asserted = TRUE;
        message(LOW, "[aligner_smp]", " Reset asserted");
    };

    event reset_deasserted_e is rise(reset_n$) and true(reset_asserted == TRUE) @rise_clk;

    on reset_deasserted_e {
        reset_asserted = FALSE;
        message(LOW, "[aligner_smp]", " Reset deasserted");
    };

};

'>