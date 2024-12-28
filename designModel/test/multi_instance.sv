module test_top(
    input  bit i_top_1,
    output bit [1:0] o_top_1,
    output bit [2:0] o_top_2
);

    bit net_out_1, net_out_2, net_out_3;

    mod1 c1(
        .i_mod1_1(i_top_1),
        .o_mod1_1(net_out_1)
    );

    mod1 c2(
        .i_mod1_1(net_out_1),
        .o_mod1_1(net_out_2)
    );

    mod1 c3(
        .i_mod1_1(net_out_2),
        .o_mod1_1(o_top_1[1:1])
    );

    // TODO: assignements not detected or linked as connections
    assign net_out_3 = net_out_2;
    assign o_top_2 = {net_out_3, net_out_2, net_out_1};


endmodule

module mod1 ( 
    input  bit i_mod1_1,
    output bit o_mod1_1

);
    bit net_out_1;

    assign net_out_1 = i_mod1_1;
    assign o_mod1_1 = net_out_1;


endmodule