`timescale 1ns / 1ps

module mdio_ctrl(
    input clk,
    input reset,

    input mdi,
    output reg mdc,
    output reg mdo,
    output reg mdio_oe,
    output reg eth_rstn
);

    typedef enum
    {
        ST_RESET,
        ST_RESET_WAIT,
        ST_CONFIG,
        ST_SEND,
        ST_SEND_WAIT,
        ST_SEND_IDLE,
        ST_SEND_IDLE_WAIT,
        ST_DELAY,
        ST_HALT
    } state_t;
    state_t state, ret_state, next_config;

    reg [31:0] delay_counter, send_counter;

    // Disable GTXCLK Clock Delay.
    wire [63:0] mdio_frame = {32'hffffffff, 2'b01, 2'b01 /* write */, 5'd1 /* phy addr */,
                              5'h1c /* reg addr */, 2'b10, 16'b1000110000000000 /* reg value */};
    reg [63:0] shift_reg;

    always @ (posedge clk or posedge reset)
    begin
        if (reset)
        begin
            state <= ST_HALT; //ST_RESET;
            ret_state <= ST_HALT; //ST_RESET;
            delay_counter <= 0;
            send_counter <= 64;
            next_config <= ST_HALT;

            mdc <= 1'b1;
            mdo <= 1'b1;
            mdio_oe <= 1'b0;
            eth_rstn <= 1'b0;
            shift_reg <= 0;
        end
        else
        begin
            case (state)
            ST_RESET:
            begin
                if (delay_counter != 1250000)  // 10ms
                begin
                    delay_counter <= delay_counter + 1;
                end
                else
                begin
                    delay_counter <= 0;
                    eth_rstn <= 1'b1;
                    state <= ST_RESET_WAIT;
                end
            end
            ST_RESET_WAIT:
            begin
                if (delay_counter != 2500)  // 20us
                begin
                    delay_counter <= delay_counter + 1;
                end
                else
                begin
                    delay_counter <= 0;
                    state <= ST_CONFIG;
                end
            end
            ST_CONFIG:
            begin
                shift_reg <= mdio_frame;
                state <= ST_SEND;
                next_config <= ST_HALT;
            end
            ST_SEND:
            begin
                mdc <= 1'b0;
                mdio_oe <= 1'b1;
                mdo <= shift_reg[63];
                shift_reg <= {shift_reg[62:0], 1'b0};
                state <= ST_DELAY;
                ret_state <= ST_SEND_WAIT;
            end
            ST_SEND_WAIT:
            begin
                mdc <= 1'b1;
                state <= ST_DELAY;
                ret_state <= ST_SEND;
                if (send_counter == 1)
                begin
                    send_counter <= 64;
                    ret_state <= ST_SEND_IDLE;
                end
                else
                begin
                    send_counter <= send_counter - 1;
                end
            end
            ST_SEND_IDLE:
            begin
                mdc <= 1'b0;
                mdio_oe <= 1'b0;
                state <= ST_DELAY;
                ret_state <= ST_SEND_IDLE_WAIT;
            end
            ST_SEND_IDLE_WAIT:
            begin
                mdc <= 1'b1;
                state <= ST_DELAY;
                ret_state <= next_config;
            end
            ST_DELAY:
            begin
                if (delay_counter != 100)
                begin
                    delay_counter <= delay_counter + 1;
                end
                else
                begin
                    delay_counter <= 0;
                    state <= ret_state;
                end
            end
            ST_HALT:
            begin
                state <= ST_HALT;
            end
            default:
            begin
                state <= ST_RESET;
            end
            endcase
        end
    end
endmodule
