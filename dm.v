module pipemem( we,addr,datain,clk,dataout);//clk, addr, data_write, DMWr, data_out ); 
   
   input  [31:0] addr,datain;
   input         we;
   input         clk;
   output [31:0] dataout; 
     
   wire [11:2] address;
   reg [31:0] data_mem[1023:0]; 
   
   integer i;
   initial begin //initialize with 0
       for (i=0; i<1024; i=i+1)
          data_mem[i] = 0;
   end
   
   assign address=addr[11:2];

   always @(posedge clk) begin
      if (we) begin
        data_mem[address] <= datain;
      end   
   end 
   
   assign dataout = data_mem[addr]; // load word
endmodule    

		  

