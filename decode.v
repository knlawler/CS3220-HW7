`include "global_def.h"

module Decode(
  I_CLOCK,
  I_LOCK,
  I_PC,
  I_IR,
  I_FE_Valid, 	
  I_WriteBackRegIdx,
  I_WriteBackVRegIdx,	      
  I_WriteBackData,
  I_CCValue,
  I_WriteBackPC,
  I_WriteBackPCEn,
  I_VecSrc1Value,
  I_VecSrc2Value,
  I_VecDestValue,
  I_RegWEn, 
  I_VRegWEn, 	 
  I_CCWEn,
  I_EDDestRegIdx,
  I_EDDestVRegIdx,
  I_EDDestWrite,
  I_EDDestVWrite,
  I_MDDestRegIdx,
  I_MDDestVRegIdx,
  I_MDDestWrite,
  I_MDDestVWrite,
  I_EDCCWEn,
  I_MDCCWEn,
  I_GPUStallSignal, 
  O_LOCK,
  O_PC,
  O_Opcode,
  O_IR, 	      
  O_Src1Value,
  O_Src2Value,
  O_DestRegIdx,
  O_DestVRegIdx,
  O_Idx, 
  O_Imm,
  O_DepStallSignal,
  O_BranchStallSignal,
  O_CCValue, 	      
  O_VecSrc1Value,
  O_VecSrc2Value,
  O_DE_Valid
);

/////////////////////////////////////////
// IN/OUT DEFINITION GOES HERE
/////////////////////////////////////////

input [`VREG_WIDTH-1:0] I_VecSrc1Value; // Never used
input [`VREG_WIDTH-1:0] I_VecSrc2Value; // Never used

// Inputs from the fetch stage
input 						I_CLOCK;
input 						I_LOCK;
input [`PC_WIDTH-1:0]	I_PC;
input [`IR_WIDTH-1:0]	I_IR;
input 						I_FE_Valid;

// Inputs from the writeback stage
input [3:0]						I_WriteBackRegIdx;
input [`REG_WIDTH-1:0]		I_WriteBackData;
input 							I_RegWEn;

input [`VREG_ID_WIDTH-1:0]	I_WriteBackVRegIdx;
input [`VREG_WIDTH-1:0] 	I_VecDestValue;
input 							I_VRegWEn;

input [2:0]						I_CCValue;
input 							I_CCWEn;

input [`PC_WIDTH-1:0]		I_WriteBackPC;   
input								I_WriteBackPCEn;

// input from EX and Mem stage for dependency checking
input I_EDCCWEn;
input I_MDCCWEn;

input [3:0] I_EDDestRegIdx;
input I_EDDestWrite;

input [`VREG_ID_WIDTH-1:0] I_EDDestVRegIdx;
input I_EDDestVWrite;

input [3:0] I_MDDestRegIdx;
input I_MDDestWrite;

input [`VREG_ID_WIDTH-1:0] I_MDDestVRegIdx;
input I_MDDestVWrite;

// pipeline stall due to GPU stage
input I_GPUStallSignal;  
 	
// Outputs to the execute stage
output reg 								O_LOCK;
output reg [`PC_WIDTH-1:0] 		O_PC;
output reg [`OPCODE_WIDTH-1:0]	O_Opcode;
output reg [`IR_WIDTH-1:0] 		O_IR;
output reg [2:0] 						O_CCValue;
output reg 								O_DE_Valid;

output reg [`REG_WIDTH-1:0] 		O_Src1Value;
output reg [`REG_WIDTH-1:0] 		O_Src2Value;
output reg [`REG_WIDTH-1:0] 		O_Imm;
output reg [3:0] 						O_DestRegIdx;
    
output reg [`VREG_WIDTH-1:0] 		O_VecSrc1Value; 
output reg [`VREG_WIDTH-1:0] 		O_VecSrc2Value;
output reg [1:0] 						O_Idx;
output reg [`VREG_ID_WIDTH-1:0] 	O_DestVRegIdx;

// Output to the fetch stage, indicating a stall
output reg O_DepStallSignal;
output reg O_BranchStallSignal;

/////////////////////////////////////////
// WIRE/REGISTER DECLARATION GOES HERE
/////////////////////////////////////////

// Scalar Register File (R0-R7: Integer, R8-R15: Floating-point)
reg [`REG_WIDTH-1:0] RF[0:`NUM_RF-1];
reg RF_VALID[0:`NUM_RF-1];

// Vector Register File
reg [`VREG_WIDTH-1:0] VRF[0:`NUM_VRF-1];
reg VRF_VALID[0:`NUM_VRF-1];

// Condition Code Register
reg [2:0] CCValue;

// Sign-extended immediate value
wire [`REG_WIDTH-1:0] Imm32;
SignExtension SE0(.In(I_IR[15:0]), .Out(Imm32));

// Decode module
wire [`OPCODE_WIDTH-1:0] Opcode;
assign Opcode = I_IR[31:24];

reg 								dep_stall;
reg 								br_stall;

reg [`REG_WIDTH-1:0]			Src1Value;
reg [`REG_WIDTH-1:0]			Src2Value;
reg [`REG_WIDTH-1:0]			Imm;
reg [3:0] 						DestRegIdx;

reg [`VREG_WIDTH-1:0] 		VecSrc1Value;
reg [`VREG_WIDTH-1:0] 		VecSrc2Value;
reg [1:0] 						Idx;
reg [`VREG_ID_WIDTH-1:0]	DestVRegIdx;

/////////////////////////////////////////
// INITIAL/ASSIGN STATEMENT GOES HERE
/////////////////////////////////////////

reg[7:0] trav;
initial begin
	for (trav = 0; trav < `NUM_RF; trav = trav + 1'b1) begin
		RF[trav] = 0;
		RF_VALID[trav] = 1;  
	end 

	for (trav = 0; trav < `NUM_VRF; trav = trav + 1'b1) begin
		VRF[trav] = 0;
		VRF_VALID[trav] = 1;  
	end 

	CCValue = 0;

	O_PC = 0;
	O_Opcode = 0;
	O_DepStallSignal = 0;
	
	dep_stall = 0;
	br_stall = 0;
	Src1Value = 0;
	Src2Value = 0;
	Imm = 0;
	DestRegIdx = 0;
	VecSrc1Value = 0;
	VecSrc2Value = 0;
	Idx = 0;
	DestVRegIdx = 0;
end

/////////////////////////////////////////
// ALWAYS STATEMENT GOES HERE
/////////////////////////////////////////

// Need to check destiation ids to check data dependency
always @(*) begin	
   case (Opcode)
	
	`OP_ADD_D: begin 
		Src1Value = RF[I_IR[19:16]];
		Src2Value = RF[I_IR[11:8]];
		DestRegIdx = I_IR[23:20];
	     
		if ( ((I_IR[19:16] == I_EDDestRegIdx) && I_EDDestWrite) || 
			  ((I_IR[19:16] == I_MDDestRegIdx) && I_MDDestWrite) ||
			  ((I_IR[11:8]  == I_EDDestRegIdx) && I_EDDestWrite) || 
			  ((I_IR[11:8]  == I_MDDestRegIdx) && I_MDDestWrite) )
			dep_stall = 1;
		else
			dep_stall = 0; 	

	end `OP_ADD_F: begin
		Src1Value = RF[I_IR[19:16]];
		Src2Value = RF[I_IR[11:8]];
		DestRegIdx = I_IR[23:20];
	     
		if ( ((I_IR[19:16] == I_EDDestRegIdx) && I_EDDestWrite) || 
			  ((I_IR[19:16] == I_MDDestRegIdx) && I_MDDestWrite) ||
			  ((I_IR[11:8]  == I_EDDestRegIdx) && I_EDDestWrite) || 
			  ((I_IR[11:8]  == I_MDDestRegIdx) && I_MDDestWrite) )
			dep_stall = 1;
		else
			dep_stall = 0; 	

	end `OP_ADDI_D: begin
		Src1Value = RF[I_IR[19:16]];
		Imm = Imm32;
		DestRegIdx = I_IR[23:20];
	     
		if ( ((I_IR[19:16] == I_EDDestRegIdx) && I_EDDestWrite) || 
			  ((I_IR[19:16] == I_MDDestRegIdx) && I_MDDestWrite) )
			dep_stall = 1;
		else
			dep_stall = 0; 	

	end `OP_ADDI_F: begin
		Src1Value = RF[I_IR[19:16]];
		Imm = Imm32;
		DestRegIdx = I_IR[23:20];
	     
		if ( ((I_IR[19:16] == I_EDDestRegIdx) && I_EDDestWrite) || 
			  ((I_IR[19:16] == I_MDDestRegIdx) && I_MDDestWrite) )
			dep_stall = 1;
		else
			dep_stall = 0; 

	/*end `OP_VADD: begin 

	end `OP_AND_D: begin

	end `OP_ANDI_D: begin

	end `OP_MOV: begin 

	end `OP_MOVI_D: begin 

	end `OP_MOVI_F: begin 

	end `OP_VMOV: begin 

	end `OP_VMOVI: begin 

	end `OP_CMP: begin
	      
	end `OP_CMPI: begin
	     
	end `OP_VCOMPMOV: begin
	     
	end `OP_VCOMPMOVI: begin
	     
	end `OP_LDB: begin

	end `OP_LDW: begin

	end `OP_STB: begin*/

	end `OP_STW: begin
		Src1Value = RF[I_IR[19:16]];
		Src2Value = RF[I_IR[23:20]];
		Imm = Imm32;

		if ( ((I_IR[19:16] == I_EDDestRegIdx) && I_EDDestWrite) || 
			  ((I_IR[19:16] == I_MDDestRegIdx) && I_MDDestWrite) ||
			  ((I_IR[23:20] == I_EDDestRegIdx) && I_EDDestWrite) || 
			  ((I_IR[23:20] == I_MDDestRegIdx) && I_MDDestWrite) )
			dep_stall = 1;
		else
			dep_stall = 0; 

	end `OP_BRP: begin
		Imm = Imm32;
		dep_stall = I_EDCCWEn || I_MDCCWEn;
	      
	end `OP_BRN: begin
		Imm = Imm32;
		dep_stall = I_EDCCWEn || I_MDCCWEn;

	end `OP_BRZ: begin
		Imm = Imm32;
		dep_stall = I_EDCCWEn || I_MDCCWEn;

	end `OP_BRNP: begin
		Imm = Imm32;
		dep_stall = I_EDCCWEn || I_MDCCWEn;

	end `OP_BRZP: begin
		Imm = Imm32;
		dep_stall = I_EDCCWEn || I_MDCCWEn;
	  
	end `OP_BRNZ: begin
		Imm = Imm32;
		dep_stall = I_EDCCWEn || I_MDCCWEn;
	     
	end `OP_BRNZP: begin
		Imm = Imm32;
		dep_stall = I_EDCCWEn || I_MDCCWEn;

	/*end `OP_JMP: begin

	end `OP_JSR: begin

	end `OP_JSRR: begin*/
	
	end default: begin
		dep_stall = 0;
	end
   endcase
end

// Branch opcode detection
always @(*) begin
	br_stall =
		(I_IR[31:27] == 5'b11011) ||
		(I_IR[31:24] == `OP_JMP)  ||
		(I_IR[31:24] == `OP_JSR)  ||
		(I_IR[31:24] == `OP_JSRR);
end
      
/////////////////////////////////////////
// ## Note ##
// First half clock cycle to write data back into the register file 
// 1. To write data back into the register file
// 2. Update Conditional Code to the following branch instruction to refer
/////////////////////////////////////////
always @(posedge I_CLOCK) begin
	if (I_LOCK == 1'b1) begin
		
		// TODO, should these be non-blocking?
		if (I_RegWEn)
			RF[I_WriteBackRegIdx] <= I_WriteBackData;
		if (I_VRegWEn)
			VRF[I_WriteBackVRegIdx] <= I_VecDestValue;
		if (I_CCWEn)
			CCValue <= I_CCValue;
		if (I_WriteBackPC)
			/* TODO, ??? */;
			
	end
end

/////////////////////////////////////////
// ## Note ##
// Second half clock cycle to read data from the register file
// 1. To read data from the register file
// 2. To update valid bit for the corresponding register (for both writeback instruction and current instruction) 
/////////////////////////////////////////
always @(negedge I_CLOCK) begin
	O_LOCK 			<= I_LOCK;
	O_PC 				<= I_PC;
   O_Opcode 		<= Opcode;
	O_IR 				<= I_IR;
	O_CCValue		<= CCValue;
	
	O_Src1Value 	<= Src1Value;
	O_Src2Value 	<= Src2Value;
	O_Imm 			<= Imm;
	O_DestRegIdx 	<= DestRegIdx;
	
	O_VecSrc1Value	<= VecSrc1Value;
	O_VecSrc2Value <= VecSrc2Value;
	O_Idx 			<= Idx;
	O_DestVRegIdx 	<= DestVRegIdx;
   
	if (I_LOCK == 1'b1) begin
		O_DE_Valid 				<= I_FE_Valid;
		O_DepStallSignal		<= dep_stall;
		O_BranchStallSignal	<= br_stall;
	end else begin
		O_DE_Valid 				<= 0;
		O_DepStallSignal 		<= 0;
		O_BranchStallSignal	<= 0;
	end 
end

endmodule
