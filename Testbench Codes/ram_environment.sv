//`include "defines.svh"

class ram_environment;
    
    // Virtual interfaces
    virtual ram_if drv_vif;
    virtual ram_if mon_vif;
    virtual ram_if ref_vif;

    // Communication Channels
    mailbox #(ram_transaction) mbx_gd;
    mailbox #(ram_transaction) mbx_dr;
    mailbox #(ram_transaction) mbx_rs;
    mailbox #(ram_transaction) mbx_ms;

    // Verification Components
    ram_generator        gen;
    ram_driver           drv;
    ram_monitor          mon;
    ram_reference_model  ref_sb;
    ram_scoreboard       scb;

    // Environment Constructor
    function new(virtual ram_if drv_vif, virtual ram_if mon_vif, virtual ram_if ref_vif);
        this.drv_vif = drv_vif;
        this.mon_vif = mon_vif;
        this.ref_vif = ref_vif;
    endfunction

    // Build Task to create structural items
    task build();
        begin
            mbx_gd = new();
            mbx_dr = new();
            mbx_rs = new();
            mbx_ms = new();
            
            gen    = new(mbx_gd);
            drv    = new(mbx_gd, mbx_dr, drv_vif.DRV);
            mon    = new(mon_vif.MON, mbx_ms);
            ref_sb = new(mbx_dr, mbx_rs, ref_vif.REF_SB);
            scb    = new(mbx_rs, mbx_ms);
        end
    endtask

    // Execution initiation task executing component threads concurrently
    task start();
        fork
            gen.start();
            drv.start();
            mon.start();
            scb.start();
            ref_sb.start();
        join
    endtask

endclass

