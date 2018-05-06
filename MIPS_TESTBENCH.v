 module MIPS_TB();
   reg clk, rst;
//   reg [31:0] pc,inst,ealu,malu,walu;
    
   pipelinedcpu U_MIPS(
      clk,rst//,pc,inst,ealu,malu,walu
   );
    
   initial begin
      $readmemh( "code.txt" , U_MIPS.inst_memory.imem ) ;
      $monitor("PC = 0x%8X, IR = 0x%8X", U_MIPS.pc, U_MIPS.inst ); 
      clk = 1 ;
      rst = 0 ;
      #5 ;
      rst = 1 ;
      //#20 ;
      //rst = 0 ;
   end
   
   always
	   #(50) clk = ~clk;
   
endmodule

