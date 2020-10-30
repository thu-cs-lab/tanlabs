`timescale 1ns / 1ps
`include "frame_datapath.vh"

module frame_datapath_push_vlan
#(
    parameter ID_WIDTH = 3
)
(
    input eth_clk,
    input reset,

    input frame_data in,
    output wire in_ready,

    output frame_data out,
    input out_ready
);

    // Track frames and figure out when it is the first beat.
    always @ (posedge eth_clk or posedge reset)
    begin
        if (reset)
        begin
            in.is_first <= 1'b1;
        end
        else
        begin
            if (in.valid && in_ready)
            begin
                in.is_first <= in.last;
            end
        end
    end

    typedef enum
    {
        ST_SEND_RECV,
        ST_SEND_LAST
    } state_t;

    frame_data out0_reg, out0;
    state_t state;
    reg [VLAN_WIDTH - 1:0] leftover_data;
    reg [VLAN_WIDTH / 8 - 1:0] leftover_keep, leftover_user;
    wire out0_ready;
    assign in_ready = (out0_ready && state == ST_SEND_RECV) || !in.valid;

    vlan_tag_t in_vlan;
    assign in_vlan.ethertype = ETHERTYPE_VLAN;
    assign in_vlan.id = {4'h0, 1'b0, in.id, 8'h01};

    always @ (*)
    begin
        out0 = out0_reg;
    end

    always @ (posedge eth_clk or posedge reset)
    begin
        if (reset)
        begin
            out0_reg <= 0;
            state <= ST_SEND_RECV;
            leftover_data <= 0;
            leftover_keep <= 0;
            leftover_user <= 0;
        end
        else
        begin
            case (state)
            ST_SEND_RECV:
            begin
                if (out0_ready)
                begin
                    out0_reg.valid <= 1'b0;
                    if (in.valid)
                    begin
                        out0_reg.valid <= 1'b1;
                        if (in.is_first)
                        begin
                            {leftover_data, out0_reg.data} <= {in.data[DATAW_WIDTH - 1:96], in_vlan, in.data[95:0]};
                            {leftover_keep, out0_reg.keep} <= {in.keep[DATAW_WIDTH / 8 - 1:12], {(VLAN_WIDTH / 8){1'b1}}, in.keep[11:0]};
                            {leftover_user, out0_reg.user} <= {in.user[DATAW_WIDTH / 8 - 1:12], {(VLAN_WIDTH / 8){1'b0}}, in.user[11:0]};
                        end
                        else
                        begin
                            {leftover_data, out0_reg.data} <= {in.data, leftover_data};
                            {leftover_keep, out0_reg.keep} <= {in.keep, leftover_keep};
                            {leftover_user, out0_reg.user} <= {in.user, leftover_user};
                        end
                        out0_reg.last <= in.last;
                        if (in.last)
                        begin
                            if (in.keep[(DATAW_WIDTH - VLAN_WIDTH) / 8])
                            begin
                                state <= ST_SEND_LAST;
                                out0_reg.last <= 1'b0;
                            end
                        end
                    end
                end
            end
            ST_SEND_LAST:
            begin
                if (out0_ready)
                begin
                    out0_reg.data <= {{(DATAW_WIDTH - VLAN_WIDTH){1'b0}}, leftover_data};
                    out0_reg.keep <= {{((DATAW_WIDTH - VLAN_WIDTH) / 8){1'b0}}, leftover_keep};
                    out0_reg.user <= {{((DATAW_WIDTH - VLAN_WIDTH) / 8){1'b0}}, leftover_user};
                    out0_reg.last <= 1'b1;
                    state <= ST_SEND_RECV;
                end
            end
            default:
            begin
                state <= ST_SEND_RECV;
            end
            endcase
        end
    end

    assign out = out0;
    assign out0_ready = out_ready || !out0.valid;
endmodule