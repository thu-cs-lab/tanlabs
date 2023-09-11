`timescale 1ns / 1ps

module mig_ui_model
#(
    parameter ADDR_WIDTH = 10  // log2(# of 64-bit words)
)
(
    input wire clk,
    input wire reset,

    input wire [ADDR_WIDTH - 1:0] app_addr,
    input wire [2:0] app_cmd,
    input wire app_en,
    output reg app_rdy,
    input wire [511:0] app_wdf_data,
    input wire app_wdf_end,
    input wire app_wdf_wren,
    input wire [63:0] app_wdf_mask,
    output reg app_wdf_rdy,
    output reg [511:0] app_rd_data,
    output wire app_rd_data_end,
    output reg app_rd_data_valid
);

    localparam DRAM_READ = 3'b001;
    localparam DRAM_WRITE = 3'b000;

    assign app_rd_data_end = 1'b1;

    function [511:0] burst_shuffle;
        input wire [2:0] addr;
        input wire [511:0] data;
        reg [511:0] data_lo, data_hi;
    begin
        data_lo = {2{data[255:0]}};
        data_hi = {2{data[511:256]}};
        burst_shuffle = {data_hi[addr[1:0] * 64 +: 256], data_lo[addr[1:0] * 64 +: 256]};
        if (addr[2])
        begin
            burst_shuffle = {burst_shuffle[255:0], burst_shuffle[511:256]};
        end
    end
    endfunction

    reg [511:0] memory [0:(1 << (ADDR_WIDTH - 3)) - 1];

    longint i;

    reg dram_addr_recved, dram_wdata_recved;
    reg [ADDR_WIDTH - 1:0] dram_addr;
    reg [511:0] dram_wdata;
    reg [63:0] dram_wdata_mask;
    reg dram_wdata_end;
    wire dram_addr_fire = app_en && app_rdy;
    wire dram_wdata_fire = app_wdf_wren && app_wdf_rdy;
    wire dram_addr_recv = dram_addr_recved || (dram_addr_fire && app_cmd == DRAM_WRITE);
    wire dram_wdata_recv = dram_wdata_recved || dram_wdata_fire;
    wire [ADDR_WIDTH - 1:0] dram_addr_mux = dram_addr_recved ? dram_addr : app_addr;
    wire [511:0] dram_wdata_mux = dram_wdata_recved ? dram_wdata : app_wdf_data;
    wire [63:0] dram_wdata_mask_mux = dram_wdata_recved ? dram_wdata_mask : app_wdf_mask;
    wire dram_wdata_end_mux = dram_wdata_recved ? dram_wdata_end : app_wdf_end;

    always @ (posedge clk or posedge reset)
    begin
        if (reset)
        begin
            app_rdy <= 1'b1;
            app_wdf_rdy <= 1'b1;
            app_rd_data <= 0;
            app_rd_data_valid <= 1'b0;
            dram_addr_recved <= 1'b0;
            dram_wdata_recved <= 1'b0;
            dram_addr <= 0;
            dram_wdata <= 0;
            dram_wdata_mask <= 0;
            dram_wdata_end <= 1'b0;

            for (i = 0; i < (1 << (ADDR_WIDTH - 3)); i += 1)
            begin
                memory[i] <= 'bx;
            end
        end
        else
        begin
            app_rd_data_valid <= 1'b0;

            if (dram_addr_fire && app_cmd == DRAM_READ)
            begin
                app_rd_data <= burst_shuffle(app_addr[2:0], memory[app_addr[ADDR_WIDTH - 1:3]]);
                app_rd_data_valid <= 1'b1;
            end

            if (dram_addr_fire && app_cmd == DRAM_WRITE)
            begin
                dram_addr <= app_addr;
                dram_addr_recved <= 1'b1;
                app_rdy <= 1'b0;
            end

            if (dram_wdata_fire)
            begin
                dram_wdata <= app_wdf_data;
                dram_wdata_mask <= app_wdf_mask;
                dram_wdata_end <= app_wdf_end;
                dram_wdata_recved <= 1'b1;
                app_wdf_rdy <= 1'b0;
            end

            if (dram_addr_recv && dram_wdata_recv)
            begin
                for (i = 0; i < 64; i += 1)
                begin
                    if (!dram_wdata_mask_mux[i])
                    begin
                        memory[dram_addr_mux[ADDR_WIDTH - 1:3]][8 * i +: 8] <= dram_wdata_mux[8 * i +: 8];
                    end
                end

                if (dram_wdata_end_mux)
                begin
                    dram_addr_recved <= 1'b0;
                    app_rdy <= 1'b1;
                end
                else
                begin
                    // Burst.
                    dram_addr <= dram_addr_mux + 8;
                end

                dram_wdata_recved <= 1'b0;
                app_wdf_rdy <= 1'b1;
            end
        end
    end

endmodule
