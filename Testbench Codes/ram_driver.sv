//`include "defines.svh"

class ram_driver;
    
    ram_transaction drv_trans;
    mailbox #(ram_transaction) mbx_gd;
    mailbox #(ram_transaction) mbx_dr; // To reference model
    virtual ram_if.DRV vif;

    // FUNCTIONAL COVERAGE for inputs
   covergroup drv_cg; 
        WRITE: coverpoint drv_trans.write_enb; 
        READ:  coverpoint drv_trans.read_enb; 
        
        DATA_IN: coverpoint drv_trans.data_in {
            // Overrides the 64 auto bins and divides the 0-255 range into 16 equal buckets
            bins data_intervals[16] = {[0:$]}; 
        }
        WRXRD: cross WRITE, READ {
            ignore_bins illegal_state = binsof(WRITE) intersect {1} && binsof(READ) intersect {1};
        }
        ADDRESS: coverpoint drv_trans.address; 
       // WRXRD: cross WRITE, READ; 
    endgroup

    // Constructor to establish mailboxes and virtual interface connections
    function new(mailbox #(ram_transaction) mbx_gd, mailbox #(ram_transaction) mbx_dr, virtual ram_if.DRV vif);
        this.mbx_gd = mbx_gd;
        this.mbx_dr = mbx_dr;
        this.vif = vif;
        drv_cg = new(); // Creating the object for covergroup
    endfunction

    // Task to drive the stimuli
    task start();
        repeat(5) @(vif.drv_cb);
        for(int i=0; i<`num_transactions; i++) begin
            drv_trans = new();
            mbx_gd.get(drv_trans); // Getting transaction from generator
            
            if(vif.drv_cb.reset == 1) begin
                repeat(1) @(vif.drv_cb) begin
                    vif.drv_cb.write_enb <= 0;
                    vif.drv_cb.read_enb  <= 0;
                    vif.drv_cb.data_in   <= 8'b0;
                    vif.drv_cb.address    <= 0;

		    drv_trans.write_enb = 0; 
                    drv_trans.read_enb  = 0;

                    mbx_dr.put(drv_trans);
                    repeat(1) @(vif.drv_cb);
                    //$display("DRIVER DRIVING DATA TO THE INTERFACE (RESET Active) data_in=%0h, write_enb=%0d, read_enb=%0d, address=%0h @ %0t", 
                             //vif.drv_cb.data_in, vif.drv_cb.write_enb, vif.drv_cb.read_enb, vif.drv_cb.address, $time);
			$display("DRIVER OPERATION DRIVING DATA TO THE INTERFACE data_in=%0h, write_enb=%0d, read_enb=%0d, address=%0h @ %0t", 
         drv_trans.data_in, drv_trans.write_enb, drv_trans.read_enb, drv_trans.address, $time);
                end
            end 
            else begin
                repeat(1) @(vif.drv_cb) begin
                    vif.drv_cb.write_enb <= drv_trans.write_enb;
                    vif.drv_cb.read_enb  <= drv_trans.read_enb;
                    vif.drv_cb.data_in   <= drv_trans.data_in;
                    vif.drv_cb.address   <= drv_trans.address;
                    repeat(1) @(vif.drv_cb);
                    
                    //$display("DRIVER OPERATION DRIVING DATA TO THE INTERFACE data_in=%0h, write_enb=%0d, read_enb=%0d, address=%0h @ %0t", 
                             //vif.drv_cb.data_in, vif.drv_cb.write_enb, vif.drv_cb.read_enb, vif.drv_cb.address, $time);
                    $display("DRIVER OPERATION DRIVING DATA TO THE INTERFACE data_in=%0h, write_enb=%0d, read_enb=%0d, address=%0h @ %0t", 
         drv_trans.data_in, drv_trans.write_enb, drv_trans.read_enb, drv_trans.address, $time);
                    
                    vif.drv_cb.write_enb <= 0;
		    vif.drv_cb.read_enb  <= 0;
                    mbx_dr.put(drv_trans); // Send to reference model
                    drv_cg.sample(); // Sampling the covergroup
                    $display("INPUT FUNCTIONAL COVERAGE = %0d", drv_cg.get_coverage());
                end
            end
        end
    endtask

endclass

