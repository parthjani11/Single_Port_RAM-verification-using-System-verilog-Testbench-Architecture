class ram_monitor;
    
    ram_transaction mon_trans;
    mailbox #(ram_transaction) mbx_ms;
    virtual ram_if.MON vif;

    // FUNCTIONAL COVERAGE for outputs
    covergroup mon_cg;
        DATA_OUT: coverpoint mon_trans.data_out {
            bins data_intervals[16] = {[0:$]}; 
        }
    endgroup

    // Constructor
    function new(virtual ram_if.MON vif, mailbox #(ram_transaction) mbx_ms);
        this.vif = vif;
        this.mbx_ms = mbx_ms;
        mon_cg = new();
    endfunction

    // Task to collect output
    task start();
        // 1. Sync exactly with the driver's start time
        repeat(5) @(vif.mon_cb);
        
        for(int i=0; i<`num_transactions; i++) begin
            mon_trans = new();
            
            // Cycle 1: Capture the address currently being driven
            @(vif.mon_cb); 
            mon_trans.address = vif.mon_cb.address;
            
            // Cycle 2: Capture the data out
            // We sample unconditionally so the Scoreboard never gets starved
            @(vif.mon_cb);
            mon_trans.data_out = vif.mon_cb.data_out;
            
            // Push EVERY transaction to the scoreboard to prevent hanging
            mbx_ms.put(mon_trans);
            mon_cg.sample();
        end
    endtask

endclass
