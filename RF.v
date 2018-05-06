`include "global_def.v"
module regfile (rna,rnb,d,wn,we,clk,clrn,qa,qb);
	input [4:0] rna,rnb,wn;		//readnumbera,readnumberb,writenumber
	input [31:0] d;			//data that should be written in the wn
	input	 we,clk,clrn;		//writen enable signal,clk is clock, clrn is a signal that could set all reg to Zero
	output [31:0] qa,qb;		//read output
	reg	[31:0] regfile [1:31];		//The zero reg is all zero
	integer i;
	//read ports
	assign qa = (rna==0) ? 0: regfile[rna];		//if rna==0,set qa=0;else set it to the value in reg[rna]
	assign qb = (rnb==0) ? 0: regfile[rnb];
 /* `ifdef DEBUG       
         $display("R[00-07]=%8X, %8X, %8X, %8X, %8X, %8X, %8X, %8X", 0, regfile[1], regfile[2], regfile[3], regfile[4], regfile[5], regfile[6], regfile[7]);
         $display("R[08-15]=%8X, %8X, %8X, %8X, %8X, %8X, %8X, %8X", regfile[8], regfile[9], regfile[10], regfile[11], regfile[12], regfile[13], regfile[14], regfile[15]);
         $display("R[16-23]=%8X, %8X, %8X, %8X, %8X, %8X, %8X, %8X", regfile[16], regfile[17], regfile[18], regfile[19], regfile[20], regfile[21], regfile[22], regfile[23]);
         $display("R[24-31]=%8X, %8X, %8X, %8X, %8X, %8X, %8X, %8X", regfile[24], regfile[25], regfile[26], regfile[27], regfile[28], regfile[29], regfile[30], regfile[31]);
  `endif*/
	//write ports
	always @(posedge clk or negedge clrn)
		if (clrn==0) begin
			for (i=1;i<32;i=i+1)
				regfile[i]<=0;
		end else if ((wn!=0)&&we)	//if writing is enabled and have a write number
			regfile[wn]<=d;
			  endmodule


module RF( rs, rt, write_data,write_addr, RFWr,clk, rf_out1, rf_out2 ); //regfile
   
   input  [4:0]  rs, rt, write_addr; 
   input  [31:0] write_data;  //data to write
   input         clk; 
   input         RFWr; 
   output reg [31:0] rf_out1, rf_out2; //two operators to alu
   
   reg [31:0] regfile[31:0];
   
   integer i;
   initial begin //initialize with 0
       for (i=0; i<32; i=i+1)
          regfile[i] = 0;
   end
   //supposed to write into at posedge while access at negedge
   always @(write_data) begin
      if (RFWr)
         regfile[write_addr] <= write_data; //arithmetic instr. assignment
      
   end
   
   always @(posedge clk) begin
     assign rf_out1 = (rs == 0) ? 32'd0 : regfile[rs]; //if rs not 0, mv the word at rs to RD and output, rs==0 e.g. sll lui
     assign rf_out2 = (rt == 0) ? 32'd0 : regfile[rt]; //if 0, regfile[0] equals 0, rt==0, e.g. jr
     `ifdef DEBUG //debug macro, print info
         $display("R[00-07]=%8X, %8X, %8X, %8X, %8X, %8X, %8X, %8X", 0, regfile[1], regfile[2], regfile[3], regfile[4], regfile[5], regfile[6], regfile[7]);
         $display("R[08-15]=%8X, %8X, %8X, %8X, %8X, %8X, %8X, %8X", regfile[8], regfile[9], regfile[10], regfile[11], regfile[12], regfile[13], regfile[14], regfile[15]);
         $display("R[16-23]=%8X, %8X, %8X, %8X, %8X, %8X, %8X, %8X", regfile[16], regfile[17], regfile[18], regfile[19], regfile[20], regfile[21], regfile[22], regfile[23]);
         $display("R[24-31]=%8X, %8X, %8X, %8X, %8X, %8X, %8X, %8X", regfile[24], regfile[25], regfile[26], regfile[27], regfile[28], regfile[29], regfile[30], regfile[31]);
      `endif
   end
      
endmodule


