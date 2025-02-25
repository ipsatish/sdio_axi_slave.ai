`timescale 1ns / 1ps

module axi_slave_interface (
    input wire axi_clk,
    input wire axi_resetn,
    input wire [31:0] axi_awaddr,
    input wire axi_awvalid,
    output reg axi_awready,
    input wire [31:0] axi_wdata,
    input wire [3:0] axi_wstrb,
    input wire axi_wvalid,
    output reg axi_wready,
    output reg [1:0] axi_bresp,
    output reg axi_bvalid,
    input wire axi_bready,
    input wire [31:0] axi_araddr,
    input wire axi_arvalid,
    output reg axi_arready,
    output reg [31:0] axi_rdata,
    output reg [1:0] axi_rresp,
    output reg axi_rvalid,
    input wire axi_rready
);

    // Internal signals
    reg [31:0] reg_data;

    // AXI write address channel
    always @(posedge axi_clk) begin
        if (!axi_resetn) begin
            axi_awready <= 1'b0;
        end else if (axi_awvalid && !axi_awready) begin
            axi_awready <= 1'b1;
        end else begin
            axi_awready <= 1'b0;
        end
    end

    // AXI write data channel
    always @(posedge axi_clk) begin
        if (!axi_resetn) begin
            axi_wready <= 1'b0;
        end else if (axi_wvalid && !axi_wready) begin
            axi_wready <= 1'b1;
        end else begin
            axi_wready <= 1'b0;
        end
    end

    // AXI write response channel
    always @(posedge axi_clk) begin
        if (!axi_resetn) begin
            axi_bvalid <= 1'b0;
            axi_bresp <= 2'b00;
        end else if (axi_awready && axi_awvalid && axi_wready && axi_wvalid && !axi_bvalid) begin
            axi_bvalid <= 1'b1;
            axi_bresp <= 2'b00; // OKAY response
        end else if (axi_bvalid && axi_bready) begin
            axi_bvalid <= 1'b0;
        end
    end

    // AXI read address channel
    always @(posedge axi_clk) begin
        if (!axi_resetn) begin
            axi_arready <= 1'b0;
        end else if (axi_arvalid && !axi_arready) begin
            axi_arready <= 1'b1;
        end else begin
            axi_arready <= 1'b0;
        end
    end

    // AXI read data channel
    always @(posedge axi_clk) begin
        if (!axi_resetn) begin
            axi_rvalid <= 1'b0;
            axi_rresp <= 2'b00;
            axi_rdata <= 32'b0;
        end else if (axi_arready && axi_arvalid && !axi_rvalid) begin
            axi_rvalid <= 1'b1;
            axi_rresp <= 2'b00; // OKAY response
            axi_rdata <= reg_data;
        end else if (axi_rvalid && axi_rready) begin
            axi_rvalid <= 1'b0;
        end
    end

    // AXI write operation
    always @(posedge axi_clk) begin
        if (axi_awready && axi_awvalid && axi_wready && axi_wvalid) begin
            reg_data <= axi_wdata;
        end
    end

endmodule