module pipedereg(dwreg,dm2reg,dwmem,daluc,daluimm,da,db,dimm,drn,
	dshift,djal,dpc4,clk,clrn,ewreg,em2reg,ewmem,
	ealuc,ealuimm,ea,eb,eimm,ern,eshift,ejal,epc4);
	input [31:0] da,db,dimm,dpc4;
	input [4:0] drn;
	input [3:0] daluc;
	input dwreg,dm2reg,dwmem,daluimm,dshift,djal;
	input clk,clrn;
	output [31:0] ea,eb,eimm,epc4;
	output [4:0] ern;
	output [3:0] ealuc;
	output ewreg,em2reg,ewmem,ealuimm,eshift,ejal;
	
	reg [31:0] ea,eb,eimm,epc4;
	reg [4:0] ern;
	reg [3:0] ealuc;
	reg ewreg,em2reg,ewmem,ealuimm,eshift,ejal;

  always @ (posedge clrn or posedge clk)
		if(clrn==0)begin
		  ewreg<=0;
			em2reg<=0;
			ewmem<=0;
			ealuc<=0;
			ealuimm<=0;
			ealuc<=0;
			eb<=0;
			ea<=0;
			ern<=0;
			eimm<=0;
			eshift<=0;
			epc4<=0;
			ejal<=0;
		end else begin
			ewreg<=dwreg;
			em2reg<=dm2reg;
			ewmem<=dwmem;
			ealuc<=daluc;
			ea<=da;
			eimm<=dimm;
			eshift<=dshift;
			epc4<=dpc4;
			ealuimm<=daluimm;
			eb<=db;
			ern<=drn;
			ejal<=djal;
		end
	endmodule


module pipeexe(ealuc,ealuimm,ea,eb,eimm,eshift,ern0,epc4,ejal,ern,ealu);
	input [31:0] ea,eb,eimm,epc4;
	input [4:0] ern0;
	input [3:0] ealuc;
	input ealuimm,eshift,ejal;
	output [31:0] ealu;
	output [4:0] ern;
	wire [31:0] alua,alub,sa,ealu0,epc8;
	wire z;
	assign sa={27'b0,eimm[10:6]};
	//cla32 ret_addr (epc4,32'h4,1'b0,epc8);
	cla32 ret_addr (epc4,32'h0,1'b0,epc8);
	mux2x32 alu_ina(ea,sa,eshift,alua);
	mux2x32 alu_inb(eb,eimm,ealuimm,alub);
	assign ern=ern0|{5{ejal}};
	alu al_unit (alua,alub,ealuc,ealu0,z);
	mux2x32 save_pc8(ealu0,epc8,ejal,ealu);
	endmodule
