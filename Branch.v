module Branch(
    input branch_inst,
    input [2:0] cond,
    input [2:0] NVZflag,
    output Branch
);

assign Branch = branch_inst & (
    (~|cond & ~NVZflag[0]) |
    (cond == 3'b001 & NVZflag[0]) |
    (cond == 3'b010 & ~NVZflag[2] & ~NVZflag[0]) |
    (cond == 3'b011 & NVZflag[2]) |
    (cond == 3'b100 & (NVZflag[0] | ( ~NVZflag[2] & ~NVZflag[0]))) |
    (cond == 3'b101 & (NVZflag[2] | NVZflag[0])) |
    (cond == 3'b110 & NVZflag[1]) |
    (&cond)
);

endmodule