`include "global_def.h"

module Execute(
  I_CLOCK,
  I_LOCK,
  I_PC,	       
  I_Opcode,
  I_IR, 	       
  I_Src1Value,
  I_Src2Value,
  I_DestRegIdx,
  I_DestVRegIdx,
  I_Imm,
  I_CCValue, 	       
  I_Idx, 
  I_VecSrc1Value,
  I_VecSrc2Value,
  I_DE_Valid, 
  I_GPUStallSignal, 
  O_LOCK,
  O_Opcode,
  O_IR, 	 
  O_PC,   
  O_R15PC,
  O_DestRegIdx,
  O_DestVRegIdx,	 
  O_DestValue,
  O_CCValue, 	       
  O_VecSrc1Value,
  O_VecDestValue,
  O_EX_Valid, 
  O_MARValue, 
  O_MDRValue,
  O_BranchPC_Signal, 
  O_BranchAddrSelect_Signal,
  O_RegWEn,
  O_VRegWEn,
  O_CCWEn,
  O_RegWEn_Signal,
  O_VRegWEn_Signal,
  O_CCWEn_Signal  
);

/////////////////////////////////////////
// IN/OUT DEFINITION GOES HERE
/////////////////////////////////////////

// Inputs from the decode stage
input 							I_CLOCK;
input 							I_LOCK;
input [`PC_WIDTH-1:0]		I_PC;
input [`OPCODE_WIDTH-1:0]	I_Opcode;
input [`IR_WIDTH-1:0]		I_IR;
input [2:0]						I_CCValue;
input 							I_DE_Valid;

input signed [`REG_WIDTH-1:0]		I_Src1Value;
input signed [`REG_WIDTH-1:0]		I_Src2Value;
input signed [`REG_WIDTH-1:0]		I_Imm;
input [3:0]								I_DestRegIdx;

input [`VREG_WIDTH-1:0]				I_VecSrc1Value; 
input [`VREG_WIDTH-1:0]				I_VecSrc2Value; 
input [1:0]								I_Idx; 
input [`VREG_ID_WIDTH-1:0]			I_DestVRegIdx;

// Stall signal from GPU stage    
input I_GPUStallSignal; 

// Outputs to the memory stage
output reg 								O_LOCK;
output reg [`OPCODE_WIDTH-1:0]	O_Opcode;
output reg [`PC_WIDTH-1:0]			O_PC;
output reg [`PC_WIDTH-1:0]			O_R15PC;
output reg [`IR_WIDTH-1:0]			O_IR;
output reg 								O_EX_Valid;

output reg [2:0]						O_CCValue;
output reg 								O_CCWEn;

output reg [`REG_WIDTH-1:0]		O_DestValue;
output reg [3:0]						O_DestRegIdx;
output reg 								O_RegWEn;

output reg [`VREG_WIDTH-1:0]		O_VecSrc1Value; 
output reg [`VREG_WIDTH-1:0]		O_VecDestValue;
output reg [`VREG_ID_WIDTH-1:0]	O_DestVRegIdx;
output reg 								O_VRegWEn;

output reg [`REG_WIDTH-1:0]		O_MARValue;
output reg [`REG_WIDTH-1:0]		O_MDRValue;
  
// Signals to the fetch stage (Note: suffix Signal means the output signal is not from reg) 
output reg [`PC_WIDTH-1:0] 	O_BranchPC_Signal;
output reg							O_BranchAddrSelect_Signal;

// Signals to the DE stage for dependency checking
output reg O_CCWEn_Signal;
output reg O_RegWEn_Signal;
output reg O_VRegWEn_Signal;
  
/////////////////////////////////////////
// WIRE/REGISTER DECLARATION GOES HERE
/////////////////////////////////////////

`define toCC(x) ((x) == 0 ? `CC_Z : x[15] == 0 ? `CC_P : `CC_N)

reg [`REG_WIDTH-1:0] 	dest_value;
reg [2:0] 					cc_value;
reg [`PC_WIDTH-1:0] 		r15pc;
reg [`VREG_WIDTH-1:0] 	vec_dest_value;
reg [`REG_WIDTH-1:0] 	mar_value;
reg [`REG_WIDTH-1:0] 	mdr_value;
reg 							reg_w_en;
reg 							vreg_w_en;
reg 							cc_w_en;
reg 							is_br;
reg [`PC_WIDTH-1:0]		br_addr;

/////////////////////////////////////////
// INITIAL/ASSIGN STATEMENT GOES HERE
/////////////////////////////////////////

initial begin
	dest_value		= 0;
	cc_value			= 0;
	r15pc				= 0;
	vec_dest_value	= 0;
	mar_value		= 0;
	mdr_value		= 0;
	reg_w_en			= 0;
	vreg_w_en		= 0;
	cc_w_en			= 0;
	is_br				= 0;
	br_addr			= 0;
end

/////////////////////////////////////////
// ALWAYS STATEMENT GOES HERE
/////////////////////////////////////////

always @(*) begin  
	case (I_Opcode)
	
	`OP_ADD_D: begin
		dest_value 		= I_Src1Value + I_Src2Value;
		cc_value 		= `toCC(dest_value);
		r15pc 			= I_PC;
		reg_w_en			= 1;
		vreg_w_en		= 0;
		cc_w_en			= 1;
		is_br				= 0;
		
	end `OP_ADD_F: begin
		dest_value 		= I_Src1Value + I_Src2Value;
		cc_value 		= `toCC(dest_value);
		r15pc 			= I_PC;
		reg_w_en			= 1;
		vreg_w_en		= 0;
		cc_w_en			= 1;
		is_br				= 0;

	end `OP_ADDI_D: begin
		dest_value 		= I_Src1Value + I_Imm;
		cc_value 		= `toCC(dest_value);
		r15pc 			= I_PC;
		reg_w_en			= 1;
		vreg_w_en		= 0;
		cc_w_en			= 1;
		is_br				= 0;

	end `OP_ADDI_F: begin
		dest_value 		= I_Src1Value + I_Imm;
		cc_value 		= `toCC(dest_value);
		r15pc 			= I_PC;
		reg_w_en			= 1;
		vreg_w_en		= 0;
		cc_w_en			= 1;
		is_br				= 0;

	end `OP_VADD: begin
		dest_value 		= I_VecSrc1Value + I_VecSrc2Value;
		cc_value 		= `toCC(dest_value);
		r15pc 			= I_PC;
		reg_w_en			= 0;
		vreg_w_en		= 1;
		cc_w_en			= 1;
		is_br				= 0;

	end `OP_AND_D: begin
		dest_value 		= I_Src1Value & I_Src2Value;
		cc_value 		= `toCC(dest_value);
		r15pc 			= I_PC;
		reg_w_en			= 1;
		vreg_w_en		= 0;
		cc_w_en			= 1;
		is_br				= 0;

	end `OP_ANDI_D: begin
		dest_value 		= I_Src1Value & I_Imm;
		cc_value 		= `toCC(dest_value);
		r15pc 			= I_PC;
		reg_w_en			= 1;
		vreg_w_en		= 0;
		cc_w_en			= 1;
		is_br				= 0;

	end `OP_MOV: begin
		dest_value 		= I_Src1Value;
		cc_value 		= `toCC(dest_value);
		r15pc 			= I_PC;
		reg_w_en			= 1;
		vreg_w_en		= 0;
		cc_w_en			= 1;
		is_br				= 0;	

	end `OP_MOVI_D: begin
		dest_value 		= I_Imm;
		cc_value 		= `toCC(dest_value);
		r15pc 			= I_PC;
		reg_w_en			= 1;
		vreg_w_en		= 0;
		cc_w_en			= 1;
		is_br				= 0;

	end `OP_MOVI_F: begin 
		dest_value 		= I_Imm;
		cc_value 		= `toCC(dest_value);
		r15pc 			= I_PC;
		reg_w_en			= 1;
		vreg_w_en		= 0;
		cc_w_en			= 1;
		is_br				= 0;

	end `OP_VMOV: begin 
		dest_value 		= I_VecSrc1Value;
		cc_value 		= `toCC(dest_value);
		r15pc 			= I_PC;
		reg_w_en			= 0;
		vreg_w_en		= 1;
		cc_w_en			= 1;
		is_br				= 0;

	end `OP_VMOVI: begin
		dest_value 		= I_Imm;
		cc_value 		= `toCC(dest_value);
		r15pc 			= I_PC;
		reg_w_en			= 0;
		vreg_w_en		= 1;
		cc_w_en			= 1;
		is_br				= 0;

	/*end `OP_CMP: begin
	      
	end `OP_CMPI: begin
	     
	end `OP_VCOMPMOV: begin
	     
	end `OP_VCOMPMOVI: begin
	     
	end `OP_LDB: begin

	end `OP_LDW: begin

	end `OP_STB: begin*/

	end `OP_STW: begin
		dest_value		= 0;
		cc_value			= 0;
		r15pc				= I_PC;
		vec_dest_value	= 0;
		mar_value		= I_Src1Value + (I_Imm * 1);
		mdr_value		= I_Src2Value;
		reg_w_en			= 0;
		vreg_w_en		= 0;
		cc_w_en			= 0;
		is_br				= 0;
		br_addr			= 0;

	end `OP_BRP: begin
		br_addr 		= I_CCValue == `CC_P ? I_PC + (I_Imm * 4) : I_PC;
		r15pc			= br_addr;
		reg_w_en 	= 0;
		vreg_w_en	= 0;
		cc_w_en		= 0;
		is_br 		= 1;
	      
	end `OP_BRN: begin
		br_addr 		= I_CCValue == `CC_N ? I_PC + (I_Imm * 4) : I_PC;
		r15pc			= br_addr;
		reg_w_en 	= 0;
		vreg_w_en	= 0;
		cc_w_en		= 0;
		is_br 		= 1;

	end `OP_BRZ: begin
		br_addr 		= I_CCValue == `CC_Z ? I_PC + (I_Imm * 4) : I_PC;
		r15pc			= br_addr;
		reg_w_en 	= 0;
		vreg_w_en	= 0;
		cc_w_en		= 0;
		is_br 		= 1;

	end `OP_BRNP: begin
		br_addr 		= I_CCValue != `CC_Z ? I_PC + (I_Imm * 4) : I_PC;
		r15pc			= br_addr;
		reg_w_en 	= 0;
		vreg_w_en	= 0;
		cc_w_en		= 0;
		is_br 		= 1;

	end `OP_BRZP: begin
		br_addr 		= I_CCValue != `CC_N ? I_PC + (I_Imm * 4) : I_PC;
		r15pc			= br_addr;
		reg_w_en 	= 0;
		vreg_w_en	= 0;
		cc_w_en		= 0;
		is_br 		= 1;
	  
	end `OP_BRNZ: begin
		br_addr 		= I_CCValue != `CC_P ? I_PC + (I_Imm * 4) : I_PC;
		r15pc			= br_addr;
		reg_w_en 	= 0;
		vreg_w_en	= 0;
		cc_w_en		= 0;
		is_br 		= 1;
	     
	end `OP_BRNZP: begin
		br_addr 		= I_PC + (I_Imm * 4);
		r15pc			= br_addr;
		reg_w_en 	= 0;
		vreg_w_en	= 0;
		cc_w_en		= 0;
		is_br 		= 1;

	/*end `OP_JMP: begin

	end `OP_JSR: begin

	end `OP_JSRR: begin*/

	end default: begin 
		r15pc 			= I_PC;
		reg_w_en			= 0;
		vreg_w_en		= 0;
		cc_w_en			= 0;
		is_br				= 0;
	end 
	endcase
end

always @(*) begin
	if (I_LOCK == 1'b1 && I_DE_Valid) begin
		O_CCWEn_Signal					= cc_w_en;
		O_RegWEn_Signal				= reg_w_en;
		O_VRegWEn_Signal				= vreg_w_en;
		
		O_BranchPC_Signal 			= br_addr;
		O_BranchAddrSelect_Signal	= is_br;
	end else begin		
		O_CCWEn_Signal					= 0;
		O_RegWEn_Signal				= 0;
		O_VRegWEn_Signal				= 0;
		
		O_BranchPC_Signal 			= 0;
		O_BranchAddrSelect_Signal	= 0;
	end
end

always @(negedge I_CLOCK) begin
	O_LOCK 			<= I_LOCK;
	O_Opcode 		<= I_Opcode;
	O_PC 				<= I_PC;
	O_R15PC 			<= r15pc;
	O_IR 				<= I_IR;
	
	O_CCValue 		<= cc_value;
	
	O_DestValue 	<= dest_value;
	O_DestRegIdx	<= I_DestRegIdx;

	O_VecSrc1Value	<= I_VecSrc1Value; 
	O_VecDestValue <= vec_dest_value;
	O_DestVRegIdx	<= I_DestVRegIdx;

	O_MARValue 		<= mar_value;
	O_MDRValue 		<= mdr_value;

	if (I_LOCK == 1'b1 && I_DE_Valid) begin
		O_EX_Valid			<= I_DE_Valid;
	
		O_CCWEn 				<= cc_w_en;
		O_RegWEn 			<= reg_w_en;
		O_VRegWEn 			<= vreg_w_en;
	end else begin 
		O_EX_Valid			<= 1'b0;

		O_CCWEn				<= 1'b0; 
		O_RegWEn				<= 1'b0;
		O_VRegWEn			<= 1'b0; 
	end
end

endmodule
