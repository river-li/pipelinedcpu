module pipepc(
    clk,rst,wpc,npc,pc
);
    input clk,rst,wpc;
    input [31:0] npc;
    output [31:0] pc;
    dffe32 program_counter(npc,clk,rst,wpc,pc);

endmodule