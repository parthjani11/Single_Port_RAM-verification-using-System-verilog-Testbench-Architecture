`timescale 1ns/100ps /* Time Unit (ns) / Precision(ps) */

`define DATA_WIDTH 8
`define DATA_DEPTH 32
`define num_transactions 150

// Added 'automatic' to fix the scope parsing errors
function automatic integer log2;
    input integer n;
    begin
        log2 = 0;
        while(2**log2 < n) begin
            log2 = log2 + 1;
        end
    end
endfunction

parameter ADDR_WIDTH = log2(`DATA_DEPTH);
