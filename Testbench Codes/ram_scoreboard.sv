class ram_scoreboard;
    
    ram_transaction ref2sb_trans, mon2sb_trans;
    mailbox #(ram_transaction) mbx_rs;
    mailbox #(ram_transaction) mbx_ms;
    
    // Local validation storage mirroring memory addresses
    logic [`DATA_WIDTH-1:0] ref_mem [`DATA_DEPTH-1:0];
    logic [`DATA_WIDTH-1:0] mon_mem [`DATA_DEPTH-1:0];
    
    int MATCH = 0;
    int MISMATCH = 0;

    // 1. Define a struct to capture error details securely
    typedef struct {
        time fail_time;
        int  address;
        logic [`DATA_WIDTH-1:0] exp_data; 
        logic [`DATA_WIDTH-1:0] act_data; 
    } fail_record_t;
    
    // 2. Create a queue to store all failed transactions
    fail_record_t failed_q[$];

    // Constructor
    function new(mailbox #(ram_transaction) mbx_rs, mailbox #(ram_transaction) mbx_ms);
        this.mbx_rs = mbx_rs;
        this.mbx_ms = mbx_ms;
    endfunction

    // Task collecting and processing transaction blocks concurrently
    task start();
        for(int i=0; i<`num_transactions; i++) begin
            ref2sb_trans = new();
            mon2sb_trans = new();
            
            fork
                begin
                    mbx_rs.get(ref2sb_trans);
                    ref_mem[ref2sb_trans.address] = ref2sb_trans.data_out;
                end
                begin
                    mbx_ms.get(mon2sb_trans);
                    mon_mem[mon2sb_trans.address] = mon2sb_trans.data_out;
                end
            join
            
            compare_report();
        end
        
        // 3. Print the final summary only AFTER all transactions are processed
        print_summary();
    endtask

    // Core validation checking task
    task compare_report();
        // 1. Ignore reads from uninitialized reference memory
        if(ref_mem[ref2sb_trans.address] === 8'hx) begin
            // Do nothing. It's an invalid read, so we don't count it as a pass or fail.
        end
        // 2. Perform the actual check for valid data
        else if(ref_mem[ref2sb_trans.address] === mon_mem[mon2sb_trans.address]) begin
            ++MATCH;
        end 
        else begin
            ++MISMATCH;
            
            // On failure, push the details into the queue
            begin
                fail_record_t f_rec;
                f_rec.fail_time = $time;
                f_rec.address   = mon2sb_trans.address;
                f_rec.exp_data  = ref_mem[ref2sb_trans.address];
                f_rec.act_data  = mon_mem[mon2sb_trans.address];
                failed_q.push_back(f_rec);
            end
        end
    endtask
    
    // 5. Final Reporting Task to print the error table
    task print_summary();
        $display("\n==================================================================");
        $display("                     SIMULATION COMPLETION SUMMARY                  ");
        $display("==================================================================");
        $display("Total Matches:    %0d", MATCH);
        $display("Total Mismatches: %0d", MISMATCH);
        
        if (MISMATCH > 0) begin
            $display("\n------------------------------------------------------------------");
            $display("                     FAILED TRANSACTIONS LOG                      ");
            $display("------------------------------------------------------------------");
            $display("| TIME      | ADDRESS | EXPECTED (REF) | ACTUAL (MON) |");
            $display("------------------------------------------------------------------");
            // Iterate through the queue and print each failure
            foreach(failed_q[i]) begin
                $display("| %0t\t| %0h\t  | %0h\t\t   | %0h\t\t  |", 
                         failed_q[i].fail_time, failed_q[i].address, failed_q[i].exp_data, failed_q[i].act_data);
            end
            $display("------------------------------------------------------------------\n");
        end else begin
            $display("\n******************************************************************");
            $display("                       ALL TESTS PASSED!                          ");
            $display("******************************************************************\n");
        end
    endtask

endclass
