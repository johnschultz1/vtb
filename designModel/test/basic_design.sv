module test(

input bit i_test1,
input bit i_test2,
input bit i_test3,
basic_if if_1,
output bit [1:0] o_test1
);

test_2 child_test(
    .i_test2({i_test1,i_test2}),
    .i_test3(i_test1),
    .i_test5(i_test1),
    .o_test4(o_test1[0:0]),
    .if_1(if_1));

test_2 child_test2(
    .i_test2({i_test1,i_test2}),
    .i_test3(i_test1),
    .i_test5(i_test1),
    .o_test4(o_test1[1:1]),
    .if_1(if_1));

endmodule

module test_2(

input bit i_test2,
input bit i_test3,
input bit i_test5,
basic_if if_1,
output bit o_test4
);

bit [31:0] local_bit, bit2;

assign bit2 = i_test2;
assign o_test4 = bit2;


endmodule

interface basic_if (

input if_input1,
output if_output3

);

endinterface