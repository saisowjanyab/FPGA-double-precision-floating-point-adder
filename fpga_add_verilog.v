`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    11:24:14 01/29/2019 
// Design Name: 
// Module Name:    fpu_add 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//sss
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////

module fpu_add(clk,rst,
enable,
opa,
opb,
sign,
sum_3,
exponent_2
);
input clk;
input rst;
input enable;
input [63:0]opa;
input [63:0]opb;
output sign;
reg sign;
output [55:0]sum_3;
reg [55:0]sum_3;
output [10:0]exponent_2;
reg [10:0] exponent_2;
reg [10:0]exponent_a;
reg [10:0]exponent_b;
reg [51:0]mantissa_a;
reg [51:0]mantissa_b;
reg [10:0]exponent_small;
reg [10:0]exponent_large;
reg [51:0]mantissa_small;
reg [51:0]mantissa_large;
reg small_is_denorm;
reg large_is_denorm;
reg [10:0]large_norm_small_denorm;
reg [10:0]exponent_diff;
reg [55:0]large_add;
reg [55:0]small_add;
reg [55:0]small_shift;
reg [55:0]small_shift_3;
reg [55:0]sum;
reg [55:0]sum_2;
reg [10:0]exponent;
reg denorm_to_norm;
integer exp_diff_int;
wire small_is_nonzero;
wire small_fraction_enable;
wire small_shift_nonzero;
wire [55:0]small_shift_2;
wire sum_overflow;
wire sum_leading_one;

assign small_shift_nonzero = or_reduce(small_shift);
assign small_is_nonzero = or_reduce(exponent_small)|or_reduce(mantissa_small[51:0]);
assign small_fraction_enable = ( small_is_nonzero & ~( small_shift_nonzero) );
assign small_shift_2 = 56'b00000000000000000000000000000000000000000000000000000001;
assign sum_overflow = sum[55];
assign sum_leading_one = sum_2[54];

always @ ( posedge clk) 
begin

if ( rst == 1'b1 ) 
begin
sign <= 1'b0;
exponent_a <= {11{ 1'b0 }};
exponent_b <= {11{ 1'b0 }};
mantissa_a <= {52{ 1'b0 }};
mantissa_b <= {52{ 1'b0 }};
exponent_small <= {11{ 1'b0 }};
exponent_large <= {11{ 1'b0 }};
mantissa_small <= {52{ 1'b0 }};
mantissa_large <= {52{ 1'b0 }};
small_is_denorm <= 1'b0;
large_is_denorm <= 1'b0;
large_norm_small_denorm <= { 1'b0 };
exponent_diff <= {11{ 1'b0 }};
large_add <= {56{1'b0}};
small_add <= {56{1'b0}};
small_shift <= {56{1'b0}};
small_shift_3 <= {56{1'b0}};
sum <= {56{1'b0}};
sum_2 <= {56{1'b0}};
sum_3 <= {56{1'b0}};
exponent <= {11{ 1'b0 }};
denorm_to_norm <= 1'b0;
exponent_2 <= {11{ 1'b0 }};
end
else if ( enable == 1'b1 )
begin  
sign <= opa[63];
exponent_a <= opa[62:52];
exponent_b <= opb[62:52];
mantissa_a <= opa[51:0];
mantissa_b <= opb[51:0];
if(exponent_a>exponent_b)
begin
exponent_small <= exponent_b;
exponent_large <= exponent_a;
mantissa_small <= mantissa_b;
mantissa_large <= mantissa_a;
end
else
begin
exponent_small <= exponent_a;
exponent_large <= exponent_b;
mantissa_small <= mantissa_a;
mantissa_large <= mantissa_b;
end
if(exponent_small > 0)
begin
small_is_denorm <= 1'b0;
end
else
begin
small_is_denorm <= 1'b1;
end
if(exponent_large > 0)
begin
large_is_denorm <= 1'b0;
end
else
begin
large_is_denorm <= 1'b1;
end
if(small_is_denorm==1'b1 & large_is_denorm==1'b0)
begin
large_norm_small_denorm <= 11'b00000000001;
end
else
begin
large_norm_small_denorm <= 11'b00000000000;
end
exponent_diff <= exponent_large-exponent_small-large_norm_small_denorm;
large_add <= {1'b0,~large_is_denorm, mantissa_large,2'b00};
small_add <= {1'b0,~small_is_denorm, mantissa_small,2'b00};
small_shift <= (small_add >> exponent_diff);
if(small_fraction_enable == 1'b1)
begin
small_shift_3 <= small_shift_2;
end
else
begin
small_shift_3<=small_shift;
end
sum <= large_add + small_shift_3;
if(sum_overflow == 1'b1)
begin
sum_2 <= sum>>1;
end
else
begin
sum_2 <= sum;
end
sum_3 <= sum_2;
if(sum_overflow ==1'b1)
begin
exponent <= exponent_large + 1;
end
else
begin
exponent <= exponent_large;
end
denorm_to_norm <= sum_leading_one & large_is_denorm;
if(denorm_to_norm ==1'b1)
begin
exponent_2 <= exponent + 1;
end
else
begin
exponent_2 <= exponent;
end
end
end
function integer or_reduce(input [55:0]small_shift);
 begin
   
    or_reduce = |small_shift; 
end
endfunction

endmodule
