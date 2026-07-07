//`include "defines.svh"

class ram_test;
    
    virtual ram_if drv_vif;
    virtual ram_if mon_vif;
    virtual ram_if ref_vif;
    ram_environment env;

    function new(virtual ram_if drv_vif, virtual ram_if mon_vif, virtual ram_if ref_vif);
        this.drv_vif = drv_vif;
        this.mon_vif = mon_vif;
        this.ref_vif = ref_vif;
    endfunction

    virtual task run();
        env = new(drv_vif, mon_vif, ref_vif);
        env.build();
        env.start();
    endtask

endclass

// INDIVIDUAL DIRECTED WRITE TEST CASE

class test_write extends ram_test;
    ram_transaction_write trans_write;

    function new(virtual ram_if drv_vif, virtual ram_if mon_vif, virtual ram_if ref_vif);
        super.new(drv_vif, mon_vif, ref_vif);
    endfunction

    task run();
        env = new(drv_vif, mon_vif, ref_vif);
        env.build();
        begin
            trans_write = new();
            env.gen.blueprint = trans_write; // Overriding base transaction object
        end
        env.start();
    endtask
endclass

// INDIVIDUAL DIRECTED READ TEST CASE

class test_read extends ram_test;
    ram_transaction_read trans_read;

    function new(virtual ram_if drv_vif, virtual ram_if mon_vif, virtual ram_if ref_vif);
        super.new(drv_vif, mon_vif, ref_vif);
    endfunction

    task run();
        env = new(drv_vif, mon_vif, ref_vif);
        env.build();
        begin
            trans_read = new();
            env.gen.blueprint = trans_read; // Overriding base transaction object
        end
        env.start();
    endtask
endclass

// REGRESSION CONTAINER CLASS

class test_regression extends ram_test;
    ram_transaction trans;
    ram_transaction_write trans_write;
    ram_transaction_read trans_read;
    

    function new(virtual ram_if drv_vif, virtual ram_if mon_vif, virtual ram_if ref_vif);
        super.new(drv_vif, mon_vif, ref_vif);
    endfunction

    task run();
        env = new(drv_vif, mon_vif, ref_vif);
        env.build();
        
        // Phase 1: Random Base Transactions
        trans = new();
        env.gen.blueprint = trans;
        env.start();
        
        // Phase 2: Directed Constrained Writes
        trans_write = new();
        env.gen.blueprint = trans_write;
        env.start();

        
        
        // Phase 3: Directed Constrained Reads
        // This read phase will randomly read out the values injected in Phase 2.5,
        // allowing the monitor to sample the missing data_out bins.
        trans_read = new();
        env.gen.blueprint = trans_read;
        env.start();
    endtask
endclass



