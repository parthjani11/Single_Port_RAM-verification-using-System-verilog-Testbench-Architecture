//`include "defines.svh"

class ram_generator;
    
    // Ram transaction class handle
    ram_transaction blueprint;
    
    // Mailbox for generator to driver connection
    mailbox #(ram_transaction) mbx_gd;

    // Explicitly overriding the constructor to make mailbox connection
    function new(mailbox #(ram_transaction) mbx_gd);
        this.mbx_gd = mbx_gd;
        blueprint = new();
    endfunction

    // Task to generate the random stimuli
    task start();
        for(int i=0; i<`num_transactions; i++) begin
            // Randomizing the inputs
            assert(blueprint.randomize() == 1);
            
            // Putting the randomized inputs to mailbox
            mbx_gd.put(blueprint.copy());
            
            $display("GENERATOR Randomized transaction data_in=%0h, write_enb=%0d, read_enb=%0d, address=%0h @ %0t", 
                     blueprint.data_in, blueprint.write_enb, blueprint.read_enb, blueprint.address, $time);
        end
    endtask

endclass
