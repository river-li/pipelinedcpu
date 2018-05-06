module pipeimem(
    addr,
    inst
);
    input [11:2] addr;
    output [31:0] inst;
    reg [31:0] imem[1023:0];

    assign inst=imem[addr];
endmodule