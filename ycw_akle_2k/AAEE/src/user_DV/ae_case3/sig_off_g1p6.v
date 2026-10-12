//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2026/01/16 15:49:22
// Design Name: 
// Module Name: sig_off_g1p6.v
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// *******************************************************************************
// Revision: 0.2.0
// Date: 2026/01/27 16:40:45
// Status: Updated
// Notes: Removed the excess state and its processing logic
// *******************************************************************************
// Revision 0.1.0 
// Date: 2026/01/16 15:49:22
// Status: File Created
// Notes: 
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

`timescale 1ns / 1ps
module sig_off_g1p6 #(
    parameter NUM_SIGS = 6,

    parameter DLY_LOAD_VAL = 16'd1000,

    parameter DLY_SIG_1_REF = 16'd21,
    parameter DLY_SIG_2_REF = 16'd12,
    parameter DLY_SIG_3_REF = 16'd25,
    parameter DLY_SIG_4_REF = 16'd18,
    // width of the state vector; must be >= 3 to preserve original encodings
    parameter integer NUM_FSM_STATES = 3
) (
    input clk_i,
    input rst_ni,

    input sig_off_ni,

    input  [NUM_SIGS-1:0] sig_i,
    output [NUM_SIGS-1:0] sig_o
);
    //  Local parameter definitions  
    localparam CNT_DIR_UP = 1'b0;
    localparam CNT_DIR_DOWN = 1'b1;
    localparam [1:0] PHASE2_HOLD = 2'b00;
    localparam [1:0] PHASE2_OFF2 = 2'b01;
    localparam [1:0] PHASE2_OFF56 = 2'b10;
    localparam [1:0] PHASE2_OFF3 = 2'b11;

    //  Input signal encoding definitions
    localparam SIG_P = 6'b100011;
    localparam SIG_P_0P = 6'b100010;
    localparam SIG_0P = 6'b110010;
    localparam SIG_0P_0N = 6'b110110;
    localparam SIG_0N = 6'b110100;
    localparam SIG_0N_N = 6'b010100;
    localparam SIG_N = 6'b011100;


    //  regs definitions

    // ============================================
    // 注册所有wire信号（如果需要）
    // ============================================
    // 确保所有信号都有明确的寄存器存储
    reg  [         5:0] phase1_sig_tmp_r;
    reg  [         5:0] phase2_sig_tmp_r;

    reg  [NUM_SIGS-1:0] sig_i_r;
    // Explicit fabric relay between the input IO register and the core register.
    // The keep attribute preserves the stage for post-synthesis placement checks.
    (* keep = "true" *)reg  [NUM_SIGS-1:0] sig_i_relay_r;
    (* keep = "true" *)reg  [NUM_SIGS-1:0] sig_i_pipe_r;

    // sig_off_ni is already registered in ae_case3 and may be absorbed into the
    // input IO tile.  These two stages align the control path with sig_i and keep
    // the core mux from being driven directly by the device boundary.
    (* keep = "true" *)reg                 sig_off_relay_r;
    (* keep = "true" *)reg                 sig_off_core_r;

    reg                 sig_off_ena_r;
    reg  [         5:0] sig_tmp_r;

    reg  [         5:0] sig_tmp_1p_r;
    reg  [         5:0] sig_o_r;
    reg  [         3:0] dly_active_r;
    reg  [         1:0] phase2_op_r;

    wire [         3:0] dly_match0;
    wire [         5:0] sig_tmp_i_w;
    wire [         5:0] sig_tmp_edge_w;
    // Registered versions to break long combinational paths (timing optimization)
    reg  [         3:0] dly_match_r;
    reg  [         5:0] sig_tmp_edge_r;
    wire [         5:0] sig_tmp_edge_pulse;

    always @(posedge clk_i or negedge rst_ni) begin
        if (!rst_ni) begin
            sig_i_r       <= 6'd0;
            sig_i_relay_r <= 6'd0;
            sig_i_pipe_r  <= 6'd0;
        end else begin
            // IO -> relay -> core.  VPR may absorb sig_i_r into the IO tile;
            // the two following fabric stages give placement a real timing
            // cut and a register that can be located between IO and decode.
            sig_i_r       <= sig_i;
            sig_i_relay_r <= sig_i_r;
            sig_i_pipe_r  <= sig_i_relay_r;
        end
    end

    always @(posedge clk_i or negedge rst_ni) begin
        if (!rst_ni) begin
            sig_off_relay_r <= 1'b0;
            sig_off_core_r  <= 1'b0;
        end else begin
            sig_off_relay_r <= sig_off_ni;
            sig_off_core_r  <= sig_off_relay_r;
        end
    end

    always @(posedge clk_i or negedge rst_ni) begin
        if (!rst_ni) begin
            sig_tmp_1p_r <= 6'd0;
            sig_o_r      <= 6'd0;
        end else begin
            sig_tmp_1p_r <= sig_tmp_r;
            // A second boundary stage isolates the core state/history nets
            // from the output IO registers.
            sig_o_r      <= sig_tmp_1p_r;
        end
    end

    //  Pcnt delay match signals

    always @(posedge clk_i or negedge rst_ni) begin
        if (!rst_ni) begin
            dly_active_r <= 4'd0;
        end else begin
            // start delay counting when a synchronized edge pulse occurs
            // only lower 4 bits of the 6-bit edge vector are used for these delays
            dly_active_r <= sig_tmp_edge_pulse[3:0] | (dly_active_r & (~dly_match_r));
        end
    end

    wire [5:0] sig_off_2_w;
    wire [5:0] sig_off_3_w;
    wire [5:0] sig_off_5_6_w;

    // sig_tmp_1p_r and the former phase2_src_r were cycle-identical copies of
    // sig_tmp_r.  Reuse the existing output-pipeline stage to remove the
    // duplicate RTL state and give phase2 one canonical snapshot net.
    assign sig_off_2_w   = {sig_tmp_1p_r[5:2], 1'b0, sig_tmp_1p_r[0]};
    assign sig_off_3_w   = {sig_tmp_1p_r[5:3], 1'b0, sig_tmp_1p_r[1:0]};
    assign sig_off_5_6_w = {1'b0, 1'b0, sig_tmp_1p_r[3:0]};

    wire sig_off_trig_5_6_w;
    assign sig_off_trig_5_6_w = dly_match_r[1] && (~dly_active_r[2]) ||
                              dly_match_r[2] && (~dly_active_r[1]);




    // ============================================
    // 主寄存器：最终输出寄存器
    // ============================================
    always @(posedge clk_i or negedge rst_ni) begin
        if (!rst_ni) begin
            sig_tmp_r <= 6'd0;
        end else if (!sig_off_core_r) begin
            if (!sig_off_ena_r) begin
                // 从第一阶段寄存器读取
                sig_tmp_r <= phase1_sig_tmp_r;
            end else begin
                // 从第二阶段寄存器读取
                sig_tmp_r <= phase2_sig_tmp_r;
            end
        end else begin
            // 直接使用输入
            sig_tmp_r <= sig_i_pipe_r;
        end
    end

    // ============================================
    // 使能寄存器：控制状态机
    // ============================================
    always @(posedge clk_i or negedge rst_ni) begin
        if (!rst_ni) begin
            sig_off_ena_r <= 1'b0;
        end else if (!sig_off_core_r) begin
            sig_off_ena_r <= 1'b1;
        end else begin
            sig_off_ena_r <= 1'b0;
        end
    end

    // ============================================
    // 第一阶段寄存器：根据输入模式和 dly_active_r[0] 计算。
    // ============================================
    always @(posedge clk_i or negedge rst_ni) begin
        if (!rst_ni) begin
            phase1_sig_tmp_r <= 6'd0;
        end else if (sig_i_pipe_r == SIG_P) begin
            phase1_sig_tmp_r <= SIG_P_0P;
        end else if (sig_i_pipe_r == SIG_P_0P) begin
            if (dly_active_r[0]) begin
                phase1_sig_tmp_r <= SIG_P_0P;
            end else begin
                phase1_sig_tmp_r <= 6'b100000;
            end
        end else if (sig_i_pipe_r == SIG_0P) begin
            phase1_sig_tmp_r <= 6'b110000;
        end else if (sig_i_pipe_r == SIG_0P_0N) begin
            phase1_sig_tmp_r <= 6'b110000;
        end else if (sig_i_pipe_r == SIG_0N) begin
            phase1_sig_tmp_r <= 6'b110000;
        end else if (sig_i_pipe_r == SIG_0N_N) begin
            if (dly_active_r[0]) begin
                phase1_sig_tmp_r <= SIG_0N_N;
            end else begin
                phase1_sig_tmp_r <= 6'b110000;
            end
        end else if (sig_i_pipe_r == SIG_N) begin
            phase1_sig_tmp_r <= SIG_0N_N;
        end else begin
            phase1_sig_tmp_r <= sig_i_pipe_r;
        end
    end

    // ============================================
    // 第二阶段寄存器：优先级逻辑
    // ============================================
    always @(posedge clk_i or negedge rst_ni) begin
        if (!rst_ni) begin
            phase2_sig_tmp_r <= 6'd0;
        end else begin
            // Capture the priority as one mutually-exclusive action before the
            // data mux.  Yosys may recode this register to one-hot, but the phase2
            // data LUTs no longer implement the three-input priority relation.
            case (phase2_op_r)
                PHASE2_OFF2:  phase2_sig_tmp_r <= sig_off_2_w;
                PHASE2_OFF56: phase2_sig_tmp_r <= sig_off_5_6_w;
                PHASE2_OFF3:  phase2_sig_tmp_r <= sig_off_3_w;
                default:      phase2_sig_tmp_r <= phase2_sig_tmp_r;
            endcase
        end
    end

    //////
    assign sig_tmp_edge_w = sig_tmp_1p_r & (~sig_tmp_r);
    // Register edge and match signals to break combinational chains (one-clock latency)
    always @(posedge clk_i or negedge rst_ni) begin
        if (!rst_ni) begin
            sig_tmp_edge_r <= 6'd0;
            dly_match_r <= 4'd0;
            phase2_op_r <= PHASE2_HOLD;
        end else begin
            sig_tmp_edge_r <= sig_tmp_edge_w;
            dly_match_r <= dly_match0;
            // Resolve the legacy [0] > [1] > [2] priority at the transaction
            // capture boundary instead of repeating it in every data-bit LUT.
            if (dly_match_r[0]) phase2_op_r <= PHASE2_OFF2;
            else if (sig_off_trig_5_6_w) phase2_op_r <= PHASE2_OFF56;
            else if (dly_match_r[3]) phase2_op_r <= PHASE2_OFF3;
            else phase2_op_r <= PHASE2_HOLD;
        end
    end

    // sig_tmp_edge_w is a falling-edge detector and therefore cannot remain
    // asserted in consecutive cycles.  Its registered value is already a
    // one-cycle pulse; differentiating it again only adds a LUT to every
    // dly_active/event path.
    assign sig_tmp_edge_pulse = sig_tmp_edge_r;


    //  Delay control
    pcounter16_clkp_arstn_sr #(
        .LOAD_VAL  (DLY_LOAD_VAL),
        .MATCH0_REF(DLY_SIG_1_REF)
    ) u_dly_sig_1 (
        .clk_i    (clk_i),
        .rst_i    (rst_ni),
        .up_down_i(CNT_DIR_UP),
        .event_i  (sig_tmp_edge_pulse[0]),
        .enable_i (dly_active_r[0]),
        .match0_o (dly_match0[0])
    );

    pcounter16_clkp_arstn_sr #(
        .LOAD_VAL  (DLY_LOAD_VAL),
        .MATCH0_REF(DLY_SIG_2_REF)
    ) u_dly_sig_2 (
        .clk_i    (clk_i),
        .rst_i    (rst_ni),
        .up_down_i(CNT_DIR_UP),
        .event_i  (sig_tmp_edge_pulse[1]),
        .enable_i (dly_active_r[1]),
        .match0_o (dly_match0[1])
    );

    pcounter16_clkp_arstn_sr #(
        .LOAD_VAL  (DLY_LOAD_VAL),
        .MATCH0_REF(DLY_SIG_3_REF)
    ) u_dly_sig_3 (
        .clk_i    (clk_i),
        .rst_i    (rst_ni),
        .up_down_i(CNT_DIR_UP),
        .event_i  (sig_tmp_edge_pulse[2]),
        .enable_i (dly_active_r[2]),
        .match0_o (dly_match0[2])
    );

    pcounter16_clkp_arstn_sr #(
        .LOAD_VAL  (DLY_LOAD_VAL),
        .MATCH0_REF(DLY_SIG_4_REF)
    ) u_dly_sig_4 (
        .clk_i    (clk_i),
        .rst_i    (rst_ni),
        .up_down_i(CNT_DIR_UP),
        .event_i  (sig_tmp_edge_pulse[3]),
        .enable_i (dly_active_r[3]),
        .match0_o (dly_match0[3])
    );


    assign sig_o = sig_o_r;
endmodule
