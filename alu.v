`include "mux4x32.v"
`include "shift.v"
`include "cla32.v"
module alu (a,b,aluop,r,z);
	input [31:0] a,b;		
	input [3:0] aluop;
	//aluop:
	//x000 add
	//x100 sub
	
	//x001 and
	//x101 or
	
	//x010 xor
	//x110 lui
	
	//0011 sll
	//0111 srl
	//1111 sra
	output [31:0] r;
	output z;
	wire [31:0] d_and = a&b;
	wire [31:0] d_or = a|b;		
	wire [31:0] d_xor = a^b;
	wire [31:0] d_lui = {b[15:0],16'h0};
	wire [31:0] d_and_or = aluop[2]?d_or:d_and;
	wire [31:0] d_xor_lui = aluop[2]?d_lui:d_xor;
	wire [31:0] d_as,d_sh;
	addsub32 as32 (a,b,aluop[2],d_as);
	shift shifter (b,a[4:0],aluop[2],aluop[3],d_sh);
	mux4x32 select (d_as,d_and_or,d_xor_lui,d_sh,aluop[1:0],r);
	assign z=~|r;		//z is zero
endmodule

module addsub32(a,b,sub,s);
	input [31:0] a,b;
	input	     sub;
	output [31:0] s;
	cla32 as32 (a,b^{32{sub}},sub,s);
endmodule


