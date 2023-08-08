module tb_elastic_buffer;

   // Parameters
   parameter int  DATA_LENGHT = 16;
   parameter time HALF_PERIOD = 5ns;

   // Clock and Reset Signals
   logic clk   = 0; 
   logic rst_n = 0;

   // Design Under Test (DUT) 
   logic i_ready;
   logic i_valid;
   logic [DATA_LENGHT-1:0] i_data;
   logic o_ready;
   logic o_valid;
   logic [DATA_LENGHT-1:0] o_data;

   // Instantiate the DUT
   elastic_buffer #(
   .DATA_LENGHT(DATA_LENGHT)
   ) dut (
      .clk(clk),
      .rst_n(rst_n),
      .i_ready(i_ready),
      .i_valid(i_valid),
      .i_data(i_data),
      .o_ready(o_ready),
      .o_valid(o_valid),
      .o_data(o_data)
   );

   // Clock generation
   always #HALF_PERIOD clk = ~clk;



   // Stimulus generation
   initial begin
   
      //Default values
      i_valid  <= 1'b0;
      i_data   <= 0;
      o_ready  <= 1'b0;
      
      //Reset generation
      rst_n    <= 1'b0;
      #100;
      rst_n    <= 1'b1;

      // Test case 1: Apply input data with x"0123" while output device is not ready
      i_valid  <= 1'b1;
      i_data   <= 16'h0123;
      #10;
      i_valid  <= 1'b0;
      #10;
      assert (i_ready) begin
         $display("ERROR! when output is not ready, buffer shouldn't be ready to accept new data already having valid data to send!");
      end else begin
         $display("Test case 1 PASS!");
      end
      
      // Test case 2: Test o_ready wait condition
      o_ready  <= 1'b1;
      #10;
      assert (!o_valid && o_data != i_data) begin
         $display("ERROR! Valid data that is waiting should be sent when o_ready occurs!");
      end else begin
         $display("Test case 2 PASS!");
      end

      o_ready  <= 1'b0;
      #40;
      i_valid  <= 1'b1;
      i_data   <= 16'h1234;
      #10;
      i_valid  <= 1'b0;
      #10;

      // Test case 3: Test multiple inputs with o_ready high
      o_ready  <= 1'b1;
      #20;
      i_valid  <= 1'b1;
      i_data   <= 16'h2345;
      #10;
      i_data   <= 16'h3456;
      #10;
      assert (!i_ready) begin
         $display("ERROR! Buffer should be ready to receive new data while o_ready is HIGH!");
      end else begin
         $display("Test case 3.1 PASS!");
      end
      
      assert (o_data != 16'h2345) begin
         $display("ERROR! Wrong data on outut!");
      end else begin
         $display("Test case 3.2 PASS!");
      end
      
      i_data <= 16'h4567;
      

      // Test case 4: Disable o_ready on 1 clock cylcle 
      #10;
      o_ready  <= 1'b0;
      i_valid  <= 1'b0;
      #10;
      o_ready  <= 1'b1;
      #10;
      o_ready  <= 1'b0;
      #10;
      assert (o_valid) begin
         $display("ERROR! Output data cannot be valid while o_ready is low!");
      end else begin
         $display("Test case 4 PASS!");
      end
      
      // Test case 5: Test receiving data after reset 
      rst_n    <= 1'b0;
      #10;
      rst_n    <= 1'b1;
      i_valid  <= 1'b1;
      i_data   <= 16'h5678;
      #10;
      i_valid  <= 1'b0;
      o_ready  <= 1'b1;
      #10;
      assert (!o_valid) begin
         $display("ERROR! Buffer must be ready to collect data on next clock cycle after reset!");
      end else begin
         $display("Test case 5 PASS!");
      end
      #50;

      //End simulation
      $display("Simulation finished.");
      $finish;
   end

endmodule