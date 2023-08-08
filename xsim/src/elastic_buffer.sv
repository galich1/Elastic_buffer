module elastic_buffer #
  (
   parameter int DATA_LENGHT =16 //Variable Data Width
)
  (
   //Control signals
   input logic  clk,
   input logic  rst_n,

   //Handshake signals
   output logic i_ready,
   input  logic i_valid,
   input  logic o_ready,
   output logic o_valid,

   //Data
   input  logic [DATA_LENGHT-1:0] i_data,

   output logic [DATA_LENGHT-1:0] o_data
);
   //Registers for samping input signals
   reg [DATA_LENGHT-1:0] temp_i_data = 0;
   reg                   temp_i_valid = 0;

   always_ff @(posedge clk) begin
      if (rst_n == 1'b0) begin               //Reset clears all output signals and potential valid data in buffer
         i_ready              <= 1'b0;
         o_valid              <= 1'b0;
         temp_i_valid         <= 1'b0;
      end else begin 

         temp_i_data          <= i_data;     //Sampling input signals
         o_data               <= temp_i_data;

         if (temp_i_valid == 1'b1) begin     // We have valid data ready to be sent
            if (o_ready == 1'b1) 
            begin                            // Receiving device is ready - send data
               temp_i_valid   <= i_valid;
               o_valid        <= 1'b1;
            end 
            else begin                       //Else keep valid data, turn set i_ready LOW
               temp_i_valid   <= 1'b1;
               i_ready        <= 1'b0;
               o_valid        <= 1'b0;
            end
         end 
         else begin                          //Without valid data work default
            i_ready           <= 1'b1;
            temp_i_valid      <= i_valid;
            o_valid           <= 1'b0;
         end
      end
   end


endmodule