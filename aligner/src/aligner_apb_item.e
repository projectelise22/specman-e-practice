================================================================
File: aligner_apb_item.e
Description: transaction struct for APB items
================================================================
<'
struct apb_item like any_sequence_item {
    -- transaction signals
    paddr     : uint (bits: ALGN_APB_ADDR_WIDTH);
    psel      : bit;
    penable   : bit;
    pwrite    : bit;
    pwdata    : uint (bits: ALGN_APB_DATA_WIDTH);
    !prdata   : uint (bits: ALGN_APB_DATA_WIDTH);
    !pready   : bit;
    !pslverr  : bit;

    keep paddr in [0x0000, 0x000C, 0x00F0, 0x00F4];

    -- transaction options
    pre_drv_dly : uint (bits : 8);
    post_drv_dly : uint (bits : 8);
    keep pre_drv_dly in [0..10];
    keep post_drv_dly in [0..10];
};
'>