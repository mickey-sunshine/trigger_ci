`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/10/11 14:14:16
// Design Name: 
// Module Name: off_pwm_mode_ctrl
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.2.0 - add off pwm control mode
// Revision 0.1.0 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module ae_case3_off_pwm_mode_ctrl (
    input clk_i,
    input rst_ni,

    input       off_pwm_prot_mode_i,
    input       off_pwm_trig_mode_i,
    input [1:0] off_pwm_trig_pol_i,

    input pwm_ctrl_loop_start_i,

    input  off_pwm_i,
    output off_pwm_o
);

    // off pwm protect mode
    parameter PROT_MODE_CBC = 1'b0;  //  0, cycle by cycle
    parameter PROT_MODE_OST = 1'b1;  //  1, oneshot

    // off pwm trigger mode:  
    parameter TRIG_MODE_LVL = 1'b0;  //  0, Level-triggered mode  
    parameter TRIG_MODE_EDG = 1'b1;  //  1, Edge-triggered mode

    // off pwm trigger polarity
    parameter TRIG_POL_DIS = 2'b00;
    parameter TRIG_POL_LOW = 2'b01;  //  In edge-triggered mode, it is triggered on the falling edge
    parameter TRIG_POL_HIGH = 2'b10;    //  In edge-triggered mode, it is triggered on the rising edge 
    parameter TRIG_POL_BOTH = 2'b11;  //  In edge-triggered mode, it is triggered on the both edge  

    reg off_pwm_on_r;
    reg loop_start_r;

    wire off_pwm_i_p_w, off_pwm_i_n_w;

    ae_case3_edge_detection u_ae_case3_edge_detection (
        .clk_i        (clk_i),
        .rst_ni       (rst_ni),
        .signal_i     (off_pwm_i),
        .edge_p_trig_o(off_pwm_i_p_w),
        .edge_n_trig_o(off_pwm_i_n_w)
    );

    always @(posedge clk_i or negedge rst_ni) begin
        if (!rst_ni) begin
            off_pwm_on_r <= 1'b0;
            loop_start_r <= 1'b0;
        end else begin
            if (off_pwm_prot_mode_i == PROT_MODE_CBC) begin
                // Cycle by cycle mode
                if (off_pwm_trig_mode_i == TRIG_MODE_LVL) begin
                    // Level-triggered mode
                    if ((off_pwm_i & off_pwm_trig_pol_i[1]) | (~off_pwm_i & off_pwm_trig_pol_i[0])) begin
                        off_pwm_on_r <= 1'b1;
                    end else begin
                        off_pwm_on_r <= 1'b0;
                    end
                end else begin
                    // Edge-triggered mode
                    if (off_pwm_i_p_w & off_pwm_trig_pol_i[1]) begin
                        off_pwm_on_r <= 1'b1;
                    end else if (off_pwm_i_n_w & off_pwm_trig_pol_i[0]) begin
                        off_pwm_on_r <= 1'b1;
                    end else begin
                        off_pwm_on_r <= 1'b0;
                    end
                end
            end else begin
                // One shot mode
                // clear oneshot when loop start is asserted (rising edge)
                if (pwm_ctrl_loop_start_i & ~loop_start_r) begin
                    off_pwm_on_r <= 1'b0;
                end

                if (off_pwm_trig_mode_i) begin
                    if (off_pwm_i_p_w & off_pwm_trig_pol_i[1]) begin
                        off_pwm_on_r <= 1'b1;
                    end

                    if (off_pwm_i_n_w & off_pwm_trig_pol_i[0]) begin
                        off_pwm_on_r <= 1'b1;
                    end
                end else begin
                    if (off_pwm_i & off_pwm_trig_pol_i[1]) begin
                        off_pwm_on_r <= 1'b1;
                    end else if (~off_pwm_i & off_pwm_trig_pol_i[0]) begin
                        off_pwm_on_r <= 1'b1;
                    end
                end
            end

            // sample loop start input for rising-edge detection
            loop_start_r <= pwm_ctrl_loop_start_i;
        end
    end


    assign off_pwm_o = ~off_pwm_on_r;
endmodule
