`include "global_def.h"

module Fetch(
  I_CLOCK,
  I_LOCK,
  I_BranchPC,
  I_BranchAddrSelect,
  I_BranchStallSignal,
  I_DepStallSignal,
  I_GPUStallSignal, 
  O_LOCK,
  O_PC,
  O_IR,
  O_FE_Valid 	     
);

/////////////////////////////////////////
// IN/OUT DEFINITION GOES HERE
/////////////////////////////////////////

// Inputs from high-level module (lg_highlevel)
input I_CLOCK;
input I_LOCK;

// Inputs from the memory stage 
input [`PC_WIDTH-1:0] I_BranchPC; // Branch Target Address
input I_BranchAddrSelect; // Asserted only when Branch Target Address resolves

// Inputs from the decode stage
input I_BranchStallSignal; // Asserted from when branch instruction is decoded; 
input I_DepStallSignal; // Asserted when register dependency is detected in the decode stage 
input I_GPUStallSignal; // Assserted when a GPU stall the piepline in the GPU stage  

// Outputs to the decode stage
output reg O_LOCK;
output reg [`PC_WIDTH-1:0] O_PC;
output reg [`IR_WIDTH-1:0] O_IR;
output reg  O_FE_Valid;
 
/////////////////////////////////////////
// WIRE/REGISTER DECLARATION GOES HERE
/////////////////////////////////////////

reg[`INST_WIDTH-1:0] InstMem[0:`INST_MEM_SIZE-1];

/////////////////////////////////////////
// INITIAL/ASSIGN STATEMENT GOES HERE
/////////////////////////////////////////

initial begin
  $readmemh("sum.hex", InstMem);

  O_LOCK = 1'b0;
  O_PC = 16'h0;
  O_IR = 32'hFF000000;
end

/////////////////////////////////////////
// ALWAYS STATEMENT GOES HERE
/////////////////////////////////////////

wire [`INST_MEM_ADDR_SIZE-3:0] PC_line;
assign PC_line = O_PC[`INST_MEM_ADDR_SIZE-1:2];

wire [`IR_WIDTH-1:0] IR_out;
assign IR_out = InstMem[PC_line];

wire latch_keep;
assign latch_keep = I_DepStallSignal;

/////////////////////////////////////////
// ## Note ##
// 1. Update output values (O_PC, O_IR) and PC.
// 2. You should be careful about STALL signals.
/////////////////////////////////////////
always @(negedge I_CLOCK) begin
	O_LOCK <= I_LOCK;

	if (I_LOCK == 1'b1) begin
		if (latch_keep) begin
			O_PC			<= O_PC;
			O_IR			<= O_IR;
			O_FE_Valid	<= O_FE_Valid;
		end else begin
			O_PC			<= I_BranchAddrSelect ? I_BranchPC : O_PC + `PC_WIDTH'd4;
			O_IR			<= IR_out;
			O_FE_Valid	<= !(I_BranchStallSignal || I_BranchAddrSelect);
		end
	end else begin
		O_PC 			<= 0;
		O_IR 			<= 0;
		O_FE_Valid	<= 0; 
	end
end

endmodule
