module off_pwm_mode_ctrl (
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

    wire off_pwm_i_p_w, off_pwm_i_n_w;

    edge_detection u_edge_detection (
        .clk_i        (clk_i),
        .rst_ni       (rst_ni),
        .signal_i     (off_pwm_i),
        .edge_p_trig_o(off_pwm_i_p_w),
        .edge_n_trig_o(off_pwm_i_n_w)
    );

    // 流水线优化：将复杂逻辑分解为多个阶段
    reg [2:0] stage_reg;  // 用于流水线延迟匹配

    // 第一级流水线：计算触发条件
    wire level_trigger_condition = (off_pwm_i & off_pwm_trig_pol_i[1]) | 
                                  (~off_pwm_i & off_pwm_trig_pol_i[0]);
    wire edge_trigger_condition = (off_pwm_i_p_w & off_pwm_trig_pol_i[1]) | 
                                 (off_pwm_i_n_w & off_pwm_trig_pol_i[0]);

    // 第二级流水线：根据触发模式选择条件
    reg trigger_condition_stage1;
    always @(posedge clk_i or negedge rst_ni) begin
        if (!rst_ni) begin
            trigger_condition_stage1 <= 1'b0;
        end else begin
            if (off_pwm_trig_mode_i == TRIG_MODE_LVL) begin
                trigger_condition_stage1 <= level_trigger_condition;
            end else begin
                trigger_condition_stage1 <= edge_trigger_condition;
            end
        end
    end

    // 第三级流水线：根据保护模式决定最终输出
    reg off_pwm_on_r;
    always @(posedge clk_i or negedge rst_ni) begin
        if (!rst_ni) begin
            off_pwm_on_r <= 1'b0;
        end else begin
            if (off_pwm_prot_mode_i == PROT_MODE_CBC) begin
                // Cycle by cycle mode - 保持当前触发状态
                off_pwm_on_r <= trigger_condition_stage1;
            end else begin
                // One shot mode - 如果被触发则保持高电平直到复位
                if (trigger_condition_stage1) begin
                    off_pwm_on_r <= 1'b1;
                end else begin
                    off_pwm_on_r <= 1'b0;
                end
            end
        end
    end

    assign off_pwm_o = ~off_pwm_on_r;
endmodule
