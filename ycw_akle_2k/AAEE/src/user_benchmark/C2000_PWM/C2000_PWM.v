module C2000_PWM (
    input clk_i,
    input rst_ni,
    input e0,
    input e1,
    output reg pwm_opening,
    output reg pwm_closing
);

    parameter LOAD_VAL = 32'd100;
    parameter MATCH1_VAL = 32'd65;

    // 内部状态定义
    localparam OPENED = 2'b00;
    localparam CLOSING = 2'b01;
    localparam CLOSED = 2'b11;
    localparam OPENING = 2'b10;
    wire [1:0] state;
    reg [1:0] state_d1;

    wire reset_counter;
    wire zero_o;
    wire match1_o;
    wire mode0;
    wire [31:0] q_o;
    always @(posedge clk_i or negedge rst_ni) begin
        if (!rst_ni) begin
            pwm_opening <= 1'b0;
            pwm_closing <= 1'b0;
        end else begin
            if (state == OPENING) begin
                if (match1_o == 1'b1) begin
                    pwm_opening <= 1'b1;
                end else if (zero_o == 1'b1) begin
                    pwm_opening <= 1'b0;
                end else begin
                    pwm_opening <= pwm_opening;
                    pwm_closing <= 1'b0;
                end
            end else if (state == CLOSING) begin
                if (match1_o == 1'b1) begin
                    pwm_closing <= 1'b1;
                end else if (zero_o == 1'b1) begin
                    pwm_closing <= 1'b0;
                end else begin
                    pwm_closing <= pwm_closing;
                    pwm_opening <= 1'b0;
                end
            end else begin
                if (zero_o == 1'b1) begin
                    pwm_opening <= 1'b0;
                    pwm_closing <= 1'b0;
                end else begin
                    pwm_opening <= pwm_opening;
                    pwm_closing <= pwm_closing;
                end
            end
        end
    end

    // --------------------------------------------------
    // mode0 信号，仅在 OPENING 或 CLOSING 状态为高
    // --------------------------------------------------
    assign mode0 = (state == CLOSING || state == OPENING);
    assign mode0_d1 = (state_d1 == CLOSING || state_d1 == OPENING);

    // 检测状态边沿变化（用于重启计数器）
    always @(posedge clk_i or negedge rst_ni) begin
        if (!rst_ni) state_d1 <= OPENED;
        else state_d1 <= state;
    end

    assign reset_counter = (state_d1 != state);  // 状态跳变时重启计数器
    pcounter32_clkp_arstn_load #(
        .LOAD_VAL  (LOAD_VAL),
        .MATCH0_REF(32'h0),
        .MATCH1_REF(MATCH1_VAL)
    ) core (
        .clk_i(clk_i),
        .rst_i(rst_ni),
        .up_down_i(1'b1),
        .event_i(zero_o || (reset_counter && mode0)),
        // .load_i(zero_o || (reset_counter && mode0)),
        .enable_i(1'b1),
        .match0_o(),
        .match1_o(match1_o),
        .zero_o(zero_o)
    );

    // pwm_controller u_pwm_controller (
    //     .clk_i(clk_i),
    //     .rst_ni(rst_ni),
    //     .state(state),  // 2bits 输入状态机状态：00=OPENED, 01=CLOSING, 11=CLOSED, 10=OPENING
    //     .load_val(LOAD_VAL),  //16bits PWM 周期
    //     .match1_val(MATCH1_VAL),  //16bits PWM 占空比
    //     .pwm_opening(pwm_opening),  // 正在打开状态时输出
    //     .pwm_closing(pwm_closing)
    // );
    C2000_FSM u_C2000_FSM (
        .clk_i(clk_i),
        .rst_ni(rst_ni),
        .e0(e0),
        .e1(e1),
        .out(state)  //2bits
    );

endmodule

// module pwm_controller (
//     input clk_i,
//     input rst_ni,
//     input [1:0] state,  // 输入状态机状态：00=OPENED, 01=CLOSING, 11=CLOSED, 10=OPENING
//     input [15:0] load_val,  // PWM 周期
//     input [15:0] match1_val,  // PWM 占空比
//     output reg pwm_opening,  // 正在打开状态时输出
//     output reg pwm_closing  // 正在关闭状态时输出
// );

//     // 内部状态定义
//     localparam OPENED = 2'b00;
//     localparam CLOSING = 2'b01;
//     localparam CLOSED = 2'b11;
//     localparam OPENING = 2'b10;

//     reg  [15:0] counter;
//     wire        mode0;  // 计数器使能（只在 OPENING 或 CLOSING）
//     wire        reset_counter;  // 状态变化时触发

//     reg  [ 1:0] state_d1;

//     // --------------------------------------------------
//     // mode0 信号，仅在 OPENING 或 CLOSING 状态为高
//     // --------------------------------------------------
//     assign mode0 = (state == CLOSING || state == OPENING);

//     // 检测状态边沿变化（用于重启计数器）
//     always @(posedge clk_i or negedge rst_ni) begin
//         if (!rst_ni) state_d1 <= OPENED;
//         else state_d1 <= state;
//     end

//     assign reset_counter = (state_d1 != state);  // 状态跳变时重启计数器

//     // --------------------------------------------------
//     // 计数器逻辑：倒计数，ZERO 时 reload
//     // --------------------------------------------------
//     always @(posedge clk_i or negedge rst_ni) begin
//         if (!rst_ni) counter <= 16'd0;
//         else if (reset_counter) counter <= load_val;
//         else if (mode0) begin
//             if (counter == 16'd0) counter <= load_val;
//             else counter <= counter - 1;
//         end
//     end

//     // --------------------------------------------------
//     // PWM 输出逻辑
//     // --------------------------------------------------
//     always @(posedge clk_i or negedge rst_ni) begin
//         if (!rst_ni) begin
//             pwm_opening <= 1'b0;
//             pwm_closing <= 1'b0;
//         end else begin
//             pwm_opening <= (state == OPENING) && (counter > match1_val);
//             pwm_closing <= (state == CLOSING) && (counter > match1_val);
//         end
//     end

// endmodule



module C2000_FSM (
    input            clk_i,
    input            rst_ni,
    input            e0,
    input            e1,
    output reg [1:0] out
);

    // 状态编码
    parameter OPENED = 2'b00;
    parameter CLOSING = 2'b01;
    parameter CLOSED = 2'b11;
    parameter OPENING = 2'b10;

    reg [1:0] current_state, next_state;

    // 状态寄存器
    always @(posedge clk_i or negedge rst_ni) begin
        if (!rst_ni) current_state <= OPENED;
        else current_state <= next_state;
    end

    // 状态转移逻辑
    always @(*) begin
        case (current_state)
            OPENED: begin
                next_state = (e0 == 1'b0) ? OPENED : CLOSING;
            end
            CLOSING: begin
                next_state = (e1 == 1'b0) ? CLOSING : (e0 == 1'b0) ? CLOSED : OPENING;
            end
            CLOSED: begin
                next_state = (e0 == 1'b0) ? CLOSED : OPENING;
            end
            OPENING: begin
                next_state = (e1 == 1'b0) ? OPENING : (e0 == 1'b0) ? OPENED : CLOSING;
            end
            default: next_state = OPENED;
        endcase
    end

    // 输出逻辑（Moore型，输出只与当前状态有关）
    always @(*) begin
        case (current_state)
            OPENED:  out = 2'b00;
            CLOSING: out = 2'b01;
            CLOSED:  out = 2'b11;
            OPENING: out = 2'b10;
            default: out = 2'b00;
        endcase
    end

endmodule
