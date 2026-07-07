`include "defines.svh"

interface ram_if(input bit clk, reset);
    
    // Declaring signals with width
    logic [`DATA_WIDTH-1:0] data_in;
    logic [`DATA_WIDTH-1:0] data_out;
    logic write_enb;
    logic read_enb;
    logic [ADDR_WIDTH-1:0] address;

    // Clocking block for driver
    clocking drv_cb @(posedge clk);
        default input #0 output #0;
        output write_enb, read_enb, data_in, address;
        input reset;
    endclocking

    // Clocking block for monitor
    clocking mon_cb @(posedge clk);
        default input #0 output #0;
        input data_out;
	input address;
	input read_enb;
    endclocking

    // Clocking block for reference model
    clocking ref_cb @(posedge clk);
        default input #0 output #0;
	input reset;
    endclocking

    // Modports specifying access permissions
    modport DRV    (clocking drv_cb);
    modport MON (clocking mon_cb);
    modport REF_SB (clocking ref_cb);

endinterface
