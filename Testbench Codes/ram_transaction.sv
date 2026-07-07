//`include "defines.svh"

class ram_transaction;
    
    // INPUTS declared as rand variables
    rand logic [`DATA_WIDTH-1:0] data_in;
    rand logic write_enb, read_enb;
    rand logic [ADDR_WIDTH-1:0] address;
    
    // OUTPUTS declared as non-rand variables
    logic [`DATA_WIDTH-1:0] data_out;

    // CONSTRAINTS for write_enb and read_enb
    constraint wr_rd_constraint { {write_enb, read_enb} inside {0, 1, 2, 3}; }
   // constraint wr_not_equal_rd { {write_enb, read_enb} != 2'b11; }

    // METHODS - Copying objects
    virtual function ram_transaction copy();
        ram_transaction copy_obj;
        copy_obj = new();
        copy_obj.data_in   = this.data_in;
        copy_obj.write_enb = this.write_enb;
        copy_obj.read_enb  = this.read_enb;
        copy_obj.address   = this.address;
        return copy_obj;
    endfunction

endclass

// EXTENDED TRANSACTIONS FOR SPECIALIZED TESTS

class ram_transaction_write extends ram_transaction;
    constraint wr_rd_constraint { {write_enb, read_enb} == 2'b10; }
    
    virtual function ram_transaction copy();
        ram_transaction_write copy1;
        copy1 = new();
        copy1.data_in   = this.data_in;
        copy1.write_enb = this.write_enb;
        copy1.read_enb  = this.read_enb;
        copy1.address   = this.address;
        return copy1;
    endfunction
endclass

class ram_transaction_read extends ram_transaction;
    constraint wr_rd_constraint { {write_enb, read_enb} == 2'b01; }
    
    virtual function ram_transaction copy();
        ram_transaction_read copy2;
        copy2 = new();
        copy2.data_in   = this.data_in;
        copy2.write_enb = this.write_enb;
        copy2.read_enb  = this.read_enb;
        copy2.address   = this.address;
        return copy2;
    endfunction
endclass



