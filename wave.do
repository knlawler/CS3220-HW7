onerror {resume}
radix define opcode_t {
    "8'h0" "ADD_D",
    "8'h1" "ADDI_D",
    "8'h4" "ADD_F",
    "8'h5" "ADDI_F",
    "8'b00110010" "STW",
    "8'hdc" "BRN",
    "8'hda" "BRZ",
    "8'hd9" "BRP",
    "8'hde" "BRNZ",
    "8'hdd" "BRNP",
    "8'hdb" "BRZP",
    "8'hdf" "BRNZP",
    -default hexadecimal
}
virtual type { \
ADD_D\
ADDI_D\
{0x4 ADD_F}\
{0x5 ADDI_F}\
8'b00110010\
{0xdc BRN}\
{0xda BRZ}\
{0xd9 BRP}\
{0xde BRNZ}\
{0xdd BRNP}\
{0xdb BRZP}\
{0xdf BRNZP}\
} opcode_type
quietly virtual function -install /lg_highlevel/Fetch0 -env /lg_highlevel { &{/lg_highlevel/Fetch0/O_IR[31], /lg_highlevel/Fetch0/O_IR[30], /lg_highlevel/Fetch0/O_IR[29], /lg_highlevel/Fetch0/O_IR[28], /lg_highlevel/Fetch0/O_IR[27], /lg_highlevel/Fetch0/O_IR[26], /lg_highlevel/Fetch0/O_IR[25], /lg_highlevel/Fetch0/O_IR[24] }} Opcode
quietly WaveActivateNextPane {} 0
add wave -noupdate /lg_highlevel/pll0/locked
add wave -noupdate /lg_highlevel/pll0/c0
add wave -noupdate /lg_highlevel/Fetch0/O_FE_Valid
add wave -noupdate -radix opcode_t -childformat {{(7) -radix opcode_t} {(6) -radix opcode_t} {(5) -radix opcode_t} {(4) -radix opcode_t} {(3) -radix opcode_t} {(2) -radix opcode_t} {(1) -radix opcode_t} {(0) -radix opcode_t}} -radixenum symbolic -subitemconfig {{/lg_highlevel/Fetch0/O_IR[31]} {-radix opcode_t -radixenum symbolic} {/lg_highlevel/Fetch0/O_IR[30]} {-radix opcode_t -radixenum symbolic} {/lg_highlevel/Fetch0/O_IR[29]} {-radix opcode_t -radixenum symbolic} {/lg_highlevel/Fetch0/O_IR[28]} {-radix opcode_t -radixenum symbolic} {/lg_highlevel/Fetch0/O_IR[27]} {-radix opcode_t -radixenum symbolic} {/lg_highlevel/Fetch0/O_IR[26]} {-radix opcode_t -radixenum symbolic} {/lg_highlevel/Fetch0/O_IR[25]} {-radix opcode_t -radixenum symbolic} {/lg_highlevel/Fetch0/O_IR[24]} {-radix opcode_t -radixenum symbolic}} /lg_highlevel/Fetch0/Opcode
add wave -noupdate -radix decimal /lg_highlevel/Fetch0/O_PC
add wave -noupdate -radix hexadecimal -childformat {{{/lg_highlevel/Fetch0/O_IR[31]} -radix symbolic} {{/lg_highlevel/Fetch0/O_IR[30]} -radix symbolic} {{/lg_highlevel/Fetch0/O_IR[29]} -radix symbolic} {{/lg_highlevel/Fetch0/O_IR[28]} -radix symbolic} {{/lg_highlevel/Fetch0/O_IR[27]} -radix symbolic} {{/lg_highlevel/Fetch0/O_IR[26]} -radix symbolic} {{/lg_highlevel/Fetch0/O_IR[25]} -radix symbolic} {{/lg_highlevel/Fetch0/O_IR[24]} -radix symbolic} {{/lg_highlevel/Fetch0/O_IR[23]} -radix hexadecimal} {{/lg_highlevel/Fetch0/O_IR[22]} -radix hexadecimal} {{/lg_highlevel/Fetch0/O_IR[21]} -radix hexadecimal} {{/lg_highlevel/Fetch0/O_IR[20]} -radix hexadecimal} {{/lg_highlevel/Fetch0/O_IR[19]} -radix hexadecimal} {{/lg_highlevel/Fetch0/O_IR[18]} -radix hexadecimal} {{/lg_highlevel/Fetch0/O_IR[17]} -radix hexadecimal} {{/lg_highlevel/Fetch0/O_IR[16]} -radix hexadecimal} {{/lg_highlevel/Fetch0/O_IR[15]} -radix hexadecimal} {{/lg_highlevel/Fetch0/O_IR[14]} -radix hexadecimal} {{/lg_highlevel/Fetch0/O_IR[13]} -radix hexadecimal} {{/lg_highlevel/Fetch0/O_IR[12]} -radix hexadecimal} {{/lg_highlevel/Fetch0/O_IR[11]} -radix hexadecimal} {{/lg_highlevel/Fetch0/O_IR[10]} -radix hexadecimal} {{/lg_highlevel/Fetch0/O_IR[9]} -radix hexadecimal} {{/lg_highlevel/Fetch0/O_IR[8]} -radix hexadecimal} {{/lg_highlevel/Fetch0/O_IR[7]} -radix hexadecimal} {{/lg_highlevel/Fetch0/O_IR[6]} -radix hexadecimal} {{/lg_highlevel/Fetch0/O_IR[5]} -radix hexadecimal} {{/lg_highlevel/Fetch0/O_IR[4]} -radix hexadecimal} {{/lg_highlevel/Fetch0/O_IR[3]} -radix hexadecimal} {{/lg_highlevel/Fetch0/O_IR[2]} -radix hexadecimal} {{/lg_highlevel/Fetch0/O_IR[1]} -radix hexadecimal} {{/lg_highlevel/Fetch0/O_IR[0]} -radix hexadecimal}} -subitemconfig {{/lg_highlevel/Fetch0/O_IR[31]} {-height 15 -radix symbolic} {/lg_highlevel/Fetch0/O_IR[30]} {-height 15 -radix symbolic} {/lg_highlevel/Fetch0/O_IR[29]} {-height 15 -radix symbolic} {/lg_highlevel/Fetch0/O_IR[28]} {-height 15 -radix symbolic} {/lg_highlevel/Fetch0/O_IR[27]} {-height 15 -radix symbolic} {/lg_highlevel/Fetch0/O_IR[26]} {-height 15 -radix symbolic} {/lg_highlevel/Fetch0/O_IR[25]} {-height 15 -radix symbolic} {/lg_highlevel/Fetch0/O_IR[24]} {-height 15 -radix symbolic} {/lg_highlevel/Fetch0/O_IR[23]} {-height 15 -radix hexadecimal} {/lg_highlevel/Fetch0/O_IR[22]} {-height 15 -radix hexadecimal} {/lg_highlevel/Fetch0/O_IR[21]} {-height 15 -radix hexadecimal} {/lg_highlevel/Fetch0/O_IR[20]} {-height 15 -radix hexadecimal} {/lg_highlevel/Fetch0/O_IR[19]} {-height 15 -radix hexadecimal} {/lg_highlevel/Fetch0/O_IR[18]} {-height 15 -radix hexadecimal} {/lg_highlevel/Fetch0/O_IR[17]} {-height 15 -radix hexadecimal} {/lg_highlevel/Fetch0/O_IR[16]} {-height 15 -radix hexadecimal} {/lg_highlevel/Fetch0/O_IR[15]} {-height 15 -radix hexadecimal} {/lg_highlevel/Fetch0/O_IR[14]} {-height 15 -radix hexadecimal} {/lg_highlevel/Fetch0/O_IR[13]} {-height 15 -radix hexadecimal} {/lg_highlevel/Fetch0/O_IR[12]} {-height 15 -radix hexadecimal} {/lg_highlevel/Fetch0/O_IR[11]} {-height 15 -radix hexadecimal} {/lg_highlevel/Fetch0/O_IR[10]} {-height 15 -radix hexadecimal} {/lg_highlevel/Fetch0/O_IR[9]} {-height 15 -radix hexadecimal} {/lg_highlevel/Fetch0/O_IR[8]} {-height 15 -radix hexadecimal} {/lg_highlevel/Fetch0/O_IR[7]} {-height 15 -radix hexadecimal} {/lg_highlevel/Fetch0/O_IR[6]} {-height 15 -radix hexadecimal} {/lg_highlevel/Fetch0/O_IR[5]} {-height 15 -radix hexadecimal} {/lg_highlevel/Fetch0/O_IR[4]} {-height 15 -radix hexadecimal} {/lg_highlevel/Fetch0/O_IR[3]} {-height 15 -radix hexadecimal} {/lg_highlevel/Fetch0/O_IR[2]} {-height 15 -radix hexadecimal} {/lg_highlevel/Fetch0/O_IR[1]} {-height 15 -radix hexadecimal} {/lg_highlevel/Fetch0/O_IR[0]} {-height 15 -radix hexadecimal}} /lg_highlevel/Fetch0/O_IR
add wave -noupdate /lg_highlevel/Decode0/O_DE_Valid
add wave -noupdate -radix opcode_t /lg_highlevel/Decode0/O_Opcode
add wave -noupdate -radix decimal /lg_highlevel/Decode0/RF
add wave -noupdate -radix decimal /lg_highlevel/Decode0/Src1Value
add wave -noupdate -radix decimal /lg_highlevel/Decode0/Src2Value
add wave -noupdate -radix decimal /lg_highlevel/Decode0/O_Imm
add wave -noupdate -radix unsigned /lg_highlevel/Decode0/O_DestRegIdx
add wave -noupdate /lg_highlevel/Execute0/O_EX_Valid
add wave -noupdate -radix opcode_t /lg_highlevel/Execute0/O_Opcode
add wave -noupdate /lg_highlevel/Execute0/O_RegWEn
add wave -noupdate -radix unsigned /lg_highlevel/Execute0/O_DestRegIdx
add wave -noupdate -radix decimal /lg_highlevel/Execute0/O_DestValue
add wave -noupdate /lg_highlevel/Execute0/O_CCWEn
add wave -noupdate -radix binary /lg_highlevel/Execute0/O_CCValue
TreeUpdate [SetDefaultTree]
configure wave -namecolwidth 150
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {119205 ps} {631205 ps}
