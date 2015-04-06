`include "global_def.h"

module Writeback(
  I_CLOCK,
  I_LOCK,
  I_Opcode,
  I_IR, 	
  I_PC,  
  I_R15PC,
  I_DestRegIdx,
  I_DestVRegIdx, 	
  I_DestValue,  
  I_CCValue, 		 
  I_VecSrc1Value,
  I_VecDestValue,
  I_MEM_Valid,
  I_RegWEn, 
  I_VRegWEn, 
  I_CCWEn,
  I_GPUStallSignal, 
  O_LOCK,
  O_WriteBackRegIdx,
  O_WriteBackVRegIdx,		 
  O_WriteBackData,
  O_PC, 
  O_CCValue, 		 
  O_VecDestValue,
  O_GSRValue, 
  O_GSRValue_Valid,
  O_VertexV1, 
  O_VertexV2, 
  O_VertexV3,
  O_RegWEn, 
  O_VRegWEn, 	 
  O_CCWEn     	       
);

/////////////////////////////////////////
// IN/OUT DEFINITION GOES HERE
/////////////////////////////////////////
//
// Inputs from the memory stage
input 							I_CLOCK;
input 							I_LOCK;
input [`PC_WIDTH-1:0]		I_PC;
input [`PC_WIDTH-1:0]		I_R15PC;
input [`OPCODE_WIDTH-1:0]	I_Opcode;
input [`IR_WIDTH-1:0]		I_IR;
input								I_MEM_Valid; 

input [2:0]						I_CCValue;
input								I_CCWEn;

input [`REG_WIDTH-1:0]		I_DestValue;
input [3:0]						I_DestRegIdx;
input								I_RegWEn;

input [`VREG_WIDTH-1:0]		I_VecSrc1Value; 
input [`VREG_WIDTH-1:0]		I_VecDestValue;
input [`VREG_ID_WIDTH-1:0]	I_DestVRegIdx;  
input								I_VRegWEn;

// input from GPU stage 
input								I_GPUStallSignal;     

// Outputs to the decode stage
output reg								O_LOCK;
output reg [`PC_WIDTH-1:0]			O_PC;

output reg [2:0]						O_CCValue;
output reg								O_CCWEn; 

output reg[`REG_WIDTH-1:0]			O_WriteBackData;
output reg [3:0]						O_WriteBackRegIdx;
output reg								O_RegWEn;

output reg [`VREG_WIDTH-1:0]		O_VecDestValue;
output reg [`VREG_ID_WIDTH-1:0]	O_WriteBackVRegIdx;
output reg								O_VRegWEn; 	 

// Output to the GPU stage 
output reg [`GSR_WIDTH-1:0]			O_GSRValue; 
output reg [`VERTEX_REG_WIDTH-1:0]	O_VertexV1;
output reg [`VERTEX_REG_WIDTH-1:0]	O_VertexV2;
output reg [`VERTEX_REG_WIDTH-1:0]	O_VertexV3;
output reg									O_GSRValue_Valid; 

/////////////////////////////////////////
// WIRE/REGISTER DECLARATION GOES HERE
/////////////////////////////////////////

reg [1:0] vertex_point_status;

// Write back stage should perform
// graphics pipeline operations
// set vertex, setcolor, rotate, translate, scale, begin primitive, endprimitive, 
   
reg [29:0] vertex_v1_t;
reg [29:0] vertex_v2_t;
reg [29:0] vertex_v3_t;

/////////////////////////////////////////
// INITIAL STATEMENT GOES HERE
/////////////////////////////////////////

initial begin
	vertex_point_status = 0;
	vertex_v1_t = 0;
	vertex_v2_t = 0;
	vertex_v3_t = 0;
end

/////////////////////////////////////////
// ALWAYS STATEMENT GOES HERE
// Generate write back data to the decode stage 
//   Perform Graphic operaionts 
/////////////////////////////////////////
   
always @(negedge I_CLOCK) begin
	O_LOCK					<= I_LOCK;
	O_PC 						<= I_PC;
	
	O_CCValue 				<= I_CCValue;
   
	O_WriteBackData 		<= I_DestValue;
	O_WriteBackRegIdx 	<= I_DestRegIdx;

	O_VecDestValue 		<= I_VecDestValue;
	O_WriteBackVRegIdx 	<= I_DestVRegIdx;

	O_GSRValue				<= 0;
	O_VertexV1				<= 0;
	O_VertexV2				<= 0;
	O_VertexV3				<= 0;
	O_GSRValue_Valid		<= 0;
	
	if (I_LOCK == 1'b1) begin
		O_CCWEn		<= I_CCWEn; 
		O_RegWEn 	<= I_RegWEn;
		O_VRegWEn 	<= I_VRegWEn;   
	end else begin
		O_CCWEn		<= 1'b0; 
		O_RegWEn 	<= 1'b0;
		O_VRegWEn 	<= 1'b0; 
	end
end
   
endmodule
