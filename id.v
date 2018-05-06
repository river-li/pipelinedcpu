module pipeir (pc4,ins,wir,clk,clrn,dpc4,inst);
	input [31:0] pc4,ins;
	input wir,clk,clrn;
	output [31:0] dpc4,inst;
	reg [31:0] dpc4,inst;
	always @(posedge clk or negedge clrn)begin
	  if (clrn==0)begin
	    dpc4<=0;
	    inst<=0;
	    end
	   else if(wir) begin
	     inst <= ins;
	     dpc4 <= pc4;
	    end
	   end
	    
	//dffe32 pc_plus4 (pc4,clk,clrn,~wir,dpc4);
	//dffe32 instruction (ins,clk,clrn,~wir,inst);
	endmodule

module pipeid (mwreg,mrn,ern,ewreg,em2reg,mm2reg,dpc4,inst,wrn,
		wdi,ealu,malu,mmo,wwreg,clk,clrn,bpc,jpc,pcsource,
		nostall,wreg,m2reg,wmem,aluc,aluimm,a,b,imm,rn/*rn is the register that would be destination*/,
		shift,jal);
	input [31:0] dpc4,inst,wdi,ealu,malu,mmo;
	input [4:0] ern,mrn,wrn;
	input mwreg,ewreg,em2reg,mm2reg,wwreg;
	input clk,clrn;
	output [31:0] bpc,jpc,a,b,imm;
	output [4:0] rn;
	output [3:0] aluc;
	output [1:0] pcsource;
	output nostall,wreg,m2reg,wmem,aluimm,shift,jal;
	//nostall is wpcir,when it is 1, ir is writeable
	
	wire[5:0] op,func;
	wire [4:0] rs,rt,rd;
	wire [31:0] qa,qb,br_offset;
	wire [15:0] ext16;
	wire [1:0] fwda,fwdb;
	wire	regrt,sext,rsrtequ,e;
	assign	func=inst[5:0];
	assign	op=inst[31:26];
	assign	rs=inst[25:21];
	assign	rt=inst[20:16];
	assign	rd=inst[15:11];
	assign	jpc={dpc4[31:28],inst[25:0],2'b00};

	pipeidcu cu(mwreg,mrn,ern,ewreg,em2reg,mm2reg,rsrtequ,func,
		op,rs,rt,wreg,m2reg,wmem,aluc,regrt,aluimm,
		fwda,fwdb,nostall,sext,pcsource,shift,jal);
	RF rf(rs,rt,wdi,wrn,wwreg,~clk,qa,qb);
//	regfile rf(rs,rt,wdi,wrn,wwreg,~clk,clrn,qa,qb);
	mux2x5	des_reg_no	(rd,rt,regrt,rn);
	mux4x32 alu_a (qa,ealu,malu,mmo,fwda,a);
	mux4x32 alu_b (qb,ealu,malu,mmo,fwdb,b);

	assign	rsrtequ=~|(a^b);	//rsrtequ=(a==b)
	assign	e=sext & inst[15];
	assign	ext16={16{e}};
	assign	imm={ext16,inst[15:0]};
	assign	br_offset={imm[29:0],2'b00};
	
	cla32 br_addr (dpc4,br_offset,1'b0,bpc);
	endmodule


module pipeidcu (mwreg,mrn,ern,ewreg,em2reg,mm2reg,rsrtequ,func,op,rs,rt,
	wreg,m2reg,wmem,aluc,regrt,aluimm,fwda,fwdb,nostall,sext,
	pcsource,shift,jal);
	input	mwreg,ewreg,em2reg,mm2reg,rsrtequ;
	input [4:0] mrn,ern,rs,rt;
	input [5:0] func,op;
	output	wreg,m2reg,wmem,regrt,aluimm,sext,shift,jal;
	output [3:0] aluc;
	output [1:0] pcsource;
	output [1:0] fwda,fwdb;
	output nostall;
	
	reg [1:0] fwda,fwdb;
	wire r_type,i_add,i_sub,i_and,i_or,i_xor,i_sll,i_srl,i_sra,i_jr;
	wire i_addi,i_andi,i_ori,i_xori,i_lw,i_sw,i_beq,i_bne,i_lui,i_j,i_jal;
	and(r_type,~op[5],~op[4],~op[3],~op[2],~op[1],~op[0]);
	and(i_add,r_type,func[5],~func[4],~func[3],~func[2],~func[1],~func[0]);
	and(i_sub,r_type,func[5],~func[4],~func[3],~func[2],func[1],~func[0]);
	and(i_and,r_type,func[5],~func[4],~func[3],func[2],~func[1],~func[0]);
	and(i_or,r_type,func[5],~func[4],~func[3],func[2],~func[1],~func[0]);
	and(i_xor,r_type,func[5],~func[4],~func[3],func[2],func[1],~func[0]);
	and(i_sll,r_type,~func[5],~func[4],~func[3],~func[2],~func[1],~func[0]);
	and(i_srl,r_type,~func[5],~func[4],~func[3],~func[2],func[1],~func[0]);
	and(i_sra,r_type,func[5],~func[4],~func[3],~func[2],func[1],func[0]);
	and(i_jr,r_type,func[5],~func[4],func[3],~func[2],~func[1],~func[0]);
	
	and(i_addi,~op[5],~op[4],op[3],~op[2],~op[1],~op[0]);
	and(i_andi,~op[5],~op[4],op[3],op[2],~op[1],~op[0]);
	and(i_ori,~op[5],~op[4],op[3],op[2],~op[1],op[0]);
	and(i_xori,~op[5],~op[4],op[3],op[2],op[1],~op[0]);
	and(i_lw,op[5],~op[4],~op[3],~op[2],op[1],op[0]);
	and(i_sw,op[5],~op[4],op[3],~op[2],op[1],op[0]);
	and(i_beq,~op[5],~op[4],~op[3],op[2],~op[1],~op[0]);
	and(i_bne,~op[5],~op[4],~op[3],op[2],~op[1],op[0]);
	and(i_lui,~op[5],~op[4],op[3],op[2],op[1],op[0]);
	and(i_j,~op[5],~op[4],~op[3],~op[2],op[1],~op[0]);
	and(i_jal,~op[5],~op[4],~op[3],~op[2],op[1],op[0]);

	wire i_rs = i_add | i_sub | i_and | i_or | i_xor | i_jr |i_addi| i_andi |
		i_ori| i_xori| i_lw| i_sw| i_beq | i_bne;
	wire i_rt = i_add | i_sub | i_and | i_or | i_xor | i_sll |i_srl| i_sra |
		i_sw| i_beq| i_bne;
	assign nostall= ~(ewreg & em2reg & (ern!=0) &(i_rs &(ern==rs)|i_rt &(ern==rt)));

	always @ (ewreg or mwreg or ern or mrn or em2reg or mm2reg or rs or rt) begin
		fwda = 2'b00;
		if (ewreg&(ern!=0)&(ern==rs)&~em2reg) begin
			fwda=2'b01;
		end else begin
			if(mwreg &(mrn!=0)&(mrn==rs)& ~mm2reg) begin
				fwda=2'b10;
			end else begin
				if(mwreg &(mrn!=0)&(mrn==rs)&mm2reg) begin
					fwda=2'b11;
				end
			end
		end
		fwdb=2'b00;
		if (ewreg&(ern!=0)&(ern==rt)&~em2reg) begin
			fwdb=2'b01;
		end else begin
			if(mwreg &(mrn!=0)&(mrn==rt)& ~mm2reg) begin
				fwdb=2'b10;
			end else begin
				if(mwreg &(mrn!=0)&(mrn==rt)&mm2reg) begin
					fwdb=2'b11;
				end
			end
		end
	end
	assign wreg =(i_add |i_sub|i_and|i_or|i_xor|i_sll|i_srl|
		i_sra|i_addi|i_andi|i_ori|i_xori|i_lw|i_lui|i_jal)&nostall;
	assign regrt=i_addi|i_andi|i_ori|i_xori|i_lw|i_lui;
	assign jal=i_jal;
	assign m2reg=i_lw;
	assign shift = i_sll|i_srl|i_sra;
	assign aluimm=i_addi|i_andi|i_ori|i_xori|i_lw|i_lui|i_sw;
	assign sext = i_addi|i_lw|i_sw|i_beq|i_bne;
	assign aluc[3]=i_sra;
	assign aluc[2]=i_sub|i_or|i_srl|i_sra|i_ori|i_lui;
	assign aluc[1]=i_xor|i_sll|i_srl|i_sra|i_xori|i_beq|i_bne|i_lui;
	assign aluc[0]=i_and|i_or|i_sll|i_srl|i_sra|i_andi|i_ori;
	assign wmem = i_sw&nostall;
	assign pcsource[1]=i_jr|i_j|i_jal;
	assign pcsource[0]=i_beq&rsrtequ|i_bne&~rsrtequ|i_j|i_jal;
	endmodule

