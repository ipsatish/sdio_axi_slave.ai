`timescale 1ns / 1ps

module sdio_axi_slave (
    // SDIO Interface
    input wire sd_clk,
    input wire sd_cmd,
    output wire sd_cmd_out,
    output wire sd_cmd_dir, // 1: output, 0: input
    inout wire [3:0] sd_data,

    // AXI Slave Interface
    input wire axi_clk,
    input wire axi_resetn,
    input wire [31:0] axi_awaddr,
    input wire axi_awvalid,
    output wire axi_awready,
    input wire [31:0] axi_wdata,
    input wire [3:0] axi_wstrb,
    input wire axi_wvalid,
    output wire axi_wready,
    output wire [1:0] axi_bresp,
    output wire axi_bvalid,
    input wire axi_bready,
    input wire [31:0] axi_araddr,
    input wire axi_arvalid,
    output wire axi_arready,
    output wire [31:0] axi_rdata,
    output wire [1:0] axi_rresp,
    output wire axi_rvalid,
    input wire axi_rready
);

    // Internal signals
    wire [47:0] cmd_reg;
    wire cmd_valid;
    wire [3:0] data_in_reg;
    wire [3:0] data_out_reg;
    wire data_dir_reg;
    wire data_valid;
    wire crc_error;
    wire timeout_error;

    // Instantiate AXI Slave Interface
    axi_slave_interface u_axi_slave_interface (
        .axi_clk(axi_clk),
        .axi_resetn(axi_resetn),
        .axi_awaddr(axi_awaddr),
        .axi_awvalid(axi_awvalid),
        .axi_awready(axi_awready),
        .axi_wdata(axi_wdata),
        .axi_wstrb(axi_wstrb),
        .axi_wvalid(axi_wvalid),
        .axi_wready(axi_wready),
        .axi_bresp(axi_bresp),
        .axi_bvalid(axi_bvalid),
        .axi_bready(axi_bready),
        .axi_araddr(axi_araddr),
        .axi_arvalid(axi_arvalid),
        .axi_arready(axi_arready),
        .axi_rdata(axi_rdata),
        .axi_rresp(axi_rresp),
        .axi_rvalid(axi_rvalid),
        .axi_rready(axi_rready)
    );

    // Instantiate SDIO Command Handler
    sdio_cmd_handler u_sdio_cmd_handler (
        .sd_clk(sd_clk),
        .sd_cmd(sd_cmd),
        .sd_cmd_out(sd_cmd_out),
        .sd_cmd_dir(sd_cmd_dir),
        .cmd_reg(cmd_reg),
        .cmd_valid(cmd_valid),
        .crc_error(crc_error),
        .timeout_error(timeout_error)
    );

    // Instantiate SDIO Data Handler
    sdio_data_handler u_sdio_data_handler (
        .sd_clk(sd_clk),
        .sd_data(sd_data),
        .data_in_reg(data_in_reg),
        .data_out_reg(data_out_reg),
        .data_dir_reg(data_dir_reg),
        .data_valid(data_valid),
        .crc_error(crc_error),
        .timeout_error(timeout_error)
    );

endmodule