module ccb_keep (
    input wire clk_ccb_i,
    input wire rst_ni,
    input wire [3:0] event_trig_i,
    output wire test_o
);
    assign test_o = event_trig_i[0];
    (* keep *)
    ccb #(
        .FPGA_LOC_X(3.0),
        .FPGA_LOC_Y(1.0),
        .FPGA_LOC_Z(0.0),
        // Event0 triggered instructions
        .EVENT0_INST0({`PULL, 3'b000, `R2}),
        .EVENT0_INST1({`SUB, `R2, `R0}),
        .EVENT0_INST2({`MOV, `R0, `R3}),
        .EVENT0_INST3({`ADD, `R3, `R1}),
        .EVENT0_INST4({`MOV_T1, `R0, `C0}),
        .EVENT0_INST5({`MOV_T2, `R1, `C0}),
        .EVENT0_INST6({`PUSH, `R2, 3'b000}),
        .EVENT0_INST7({`INTR, 6'b000001}),
        // Initial register values, R0-R3
        .R0(32'd1),
        .R1(32'd2),
        .R2(32'd3),
        .R3(32'd4),
    ) u_ccb_1 (
        .ccb_clk_i    (clk_ccb_i),
        .ccb_rst_ni   (rst_ni),
        .ccb_event_i  ({event_trig_i}),
        .pcnt_event_i (6'b111111),
        // Enable only when a RTL-level simulation before synthesis is required
`ifdef FULL_CCB_MODEL_FOR_SIM
        .rdata0_i     (32'b0),
        .rdata1_i     (32'b0),
        .rdata2_i     (32'b0),
`endif
        .match0_ref0_o(),
        .match1_ref0_o(),
        .load_val0_o  (),
        .match0_ref1_o(),
        .match1_ref1_o(),
        .load_val1_o  (),
        .match0_ref2_o(),
        .match1_ref2_o(),
        .load_val2_o  ()
    );


endmodule
