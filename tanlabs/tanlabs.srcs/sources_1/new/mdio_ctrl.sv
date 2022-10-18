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
        ST_CONFIG1,
        ST_CONFIG2,
        ST_CONFIG3,
        ST_CONFIG4,
        ST_CONFIG5,
        ST_SEND,
        ST_SEND_WAIT,
        ST_SEND_IDLE,
        ST_SEND_IDLE_WAIT,
        ST_DELAY,
        ST_HALT
    } state_t;
    state_t state, ret_state, next_config;

    reg [31:0] delay_counter, send_counter;

    // Disable TXDLY for RTL8211E.
    wire [63:0] page_select_7 = {32'hffffffff, 2'b01, 2'b01 /* write */, 5'd1 /* phy addr */,
                                 5'h1f /* reg addr */, 2'b10, 16'd7 /* reg value */};
    wire [63:0] ext_page_select_a4 = {32'hffffffff, 2'b01, 2'b01 /* write */, 5'd1 /* phy addr */,
                                      5'h1e /* reg addr */, 2'b10, 16'ha4 /* reg value */};
    wire [63:0] read_config_reg = {32'hffffffff, 2'b01, 2'b10 /* read */, 5'd1 /* phy addr */,
                                   5'h1c /* reg addr */, 2'bxx, 16'hxxxx /* reg value */};
    // default: 8577
    wire [15:0] new_config;
    wire [63:0] config_reg = {32'hffffffff, 2'b01, 2'b01 /* write */, 5'd1 /* phy addr */,
                              5'h1c /* reg addr */, 2'b10, new_config /* reg value */};
    wire [63:0] page_select_0 = {32'hffffffff, 2'b01, 2'b01 /* write */, 5'd1 /* phy addr */,
                                 5'h1f /* reg addr */, 2'b10, 16'd0 /* reg value */};
    wire [63:0] send_oe = 64'hffffffffffffffff;
    wire [63:0] recv_oe = 64'hfffffffffffc0000;
    reg [63:0] oe_shift_reg;
    reg [63:0] send_shift_reg;
    reg [63:0] recv_shift_reg;

    assign new_config = (recv_shift_reg[15:0] & ~16'h3800) | 16'h3000;  // doesn't work :(

    always @ (posedge clk or posedge reset)
    begin
        if (reset)
        begin
            state <= ST_RESET;
            ret_state <= ST_RESET;
            delay_counter <= 0;
            send_counter <= 64;
            next_config <= ST_HALT;

            mdc <= 1'b1;
            mdo <= 1'b1;
            mdio_oe <= 1'b0;
            eth_rstn <= 1'b0;
            oe_shift_reg <= 0;
            send_shift_reg <= 0;
            recv_shift_reg <= 0;
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
                    state <= ST_CONFIG1;
                end
            end
            ST_CONFIG1:
            begin
                oe_shift_reg <= send_oe;
                send_shift_reg <= page_select_7;
                state <= ST_SEND;
                next_config <= ST_CONFIG2;
            end
            ST_CONFIG2:
            begin
                oe_shift_reg <= send_oe;
                send_shift_reg <= ext_page_select_a4;
                state <= ST_SEND;
                next_config <= ST_CONFIG3;
            end
            ST_CONFIG3:
            begin
                oe_shift_reg <= recv_oe;
                send_shift_reg <= read_config_reg;
                state <= ST_SEND;
                next_config <= ST_CONFIG4;
            end
            ST_CONFIG4:
            begin
                oe_shift_reg <= send_oe;
                send_shift_reg <= config_reg;
                state <= ST_SEND;
                next_config <= ST_CONFIG5;
            end
            ST_CONFIG5:
            begin
                oe_shift_reg <= send_oe;
                send_shift_reg <= page_select_0;
                state <= ST_SEND;
                next_config <= ST_HALT;
            end
            ST_SEND:
            begin
                mdc <= 1'b0;
                mdio_oe <= oe_shift_reg[63];
                mdo <= send_shift_reg[63];
                oe_shift_reg <= {oe_shift_reg[62:0], 1'b0};
                send_shift_reg <= {send_shift_reg[62:0], 1'b0};
                state <= ST_DELAY;
                ret_state <= ST_SEND_WAIT;
            end
            ST_SEND_WAIT:
            begin
                mdc <= 1'b1;
                recv_shift_reg <= {recv_shift_reg[62:0], mdi};
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
