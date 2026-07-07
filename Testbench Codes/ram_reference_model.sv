//`include "defines.svh"

class ram_reference_model;
    
    ram_transaction ref_trans;
    mailbox #(ram_transaction) mbx_rs;
    mailbox #(ram_transaction) mbx_dr;
    virtual ram_if.REF_SB vif;

    // 2-D array used for RAM storage
    reg [`DATA_WIDTH-1:0] MEM [`DATA_DEPTH-1:0];

    // Constructor
    function new(mailbox #(ram_transaction) mbx_dr, mailbox #(ram_transaction) mbx_rs, virtual ram_if.REF_SB vif);
        this.mbx_dr = mbx_dr;
        this.mbx_rs = mbx_rs;
        this.vif = vif;
    endfunction

    task start();
        for(int i=0; i<`num_transactions; i++) begin
            ref_trans = new();
            mbx_dr.get(ref_trans); 
            
            @(vif.ref_cb); // Sample the current interface state
            
            if (vif.ref_cb.reset) begin 
                // 1. Reset logic: RAM idle state
                // All memory locations are not explicitly zeroed by spec, 
                // but internal inputs and output become Z or 0.
                ref_trans.data_out = 8'bz; 
		for (int j = 0; j < `DATA_DEPTH; j++) begin
                    MEM[j] = 8'h00;
                end
                $display("REFERENCE MODEL RESET ACTIVE @ %0t", $time);
            end else begin
                // 2. Normal Operation logic
                if(ref_trans.write_enb && !ref_trans.read_enb) begin
                    MEM[ref_trans.address] = ref_trans.data_in;
                    $display("REFERENCE MODEL DATA IN MEMORY MEM[%0h]=%0h @ %0t", ref_trans.address, MEM[ref_trans.address], $time);
                end
                if(ref_trans.read_enb && !ref_trans.write_enb) begin
                    ref_trans.data_out = MEM[ref_trans.address];
                    $display("REFERENCE MODEL DATA OUT FROM MEMORY data_out=%0h @ %0t", ref_trans.data_out, $time);
                end
		if(ref_trans.read_enb && ref_trans.write_enb) begin
                    ref_trans.data_out = MEM[ref_trans.address];
                    $display("REFERENCE MODEL DATA OUT FROM MEMORY data_out=%0h @ %0t", ref_trans.data_out, $time);
                end
            end
            
            mbx_rs.put(ref_trans); 
        end
    endtask

endclass
