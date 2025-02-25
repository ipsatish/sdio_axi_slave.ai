`timescale 1ns / 1ps

module cdc_sync #(
    parameter WIDTH = 1
)(
    input wire clk_out,
    input wire rst_n,
    input wire [WIDTH-1:0] data_in,
    output reg [WIDTH-1:0] data_out
);

    reg [WIDTH-1:0] sync_reg1;
    reg [WIDTH-1:0] sync_reg2;

    always @(posedge clk_out or negedge rst_n) begin
        if (!rst_n) begin
            sync_reg1 <= {WIDTH{1'b0}};
            sync_reg2 <= {WIDTH{1'b0}};
            data_out <= {WIDTH{1'b0}};
        end else begin
            sync_reg1 <= data_in;
            sync_reg2 <= sync_reg1;
            data_out <= sync_reg2;
        end
    end

endmodule