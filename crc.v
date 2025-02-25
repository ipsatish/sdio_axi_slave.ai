`timescale 1ns / 1ps

module crc (
    input wire [45:0] data_in,
    output reg [6:0] crc7_out,
    input wire [3:0] data,
    output reg [15:0] crc16_out
);

    // CRC7 Calculation Function
    function [6:0] crc7_next;
        input [45:0] data;
        reg [6:0] crc;
        integer i;
        begin
            crc = 7'h0;
            for (i = 45; i >= 0; i = i - 1) begin
                crc = {crc[5:0], data[i]} ^ (crc[6] ? 7'h09 : 7'h00);
            end
            crc7_next = crc;
        end
    endfunction

    // CRC16 Calculation Function
    function [15:0] crc16_next;
        input [3:0] data;
        reg [15:0] crc;
        integer i;
        begin
            crc = 16'h0;
            for (i = 3; i >= 0; i = i - 1) begin
                crc = {crc[14:0], data[i]} ^ (crc[15] ? 16'h1021 : 16'h0);
            end
            crc16_next = crc;
        end
    endfunction

    always @(*) begin
        crc7_out = crc7_next(data_in);
        crc16_out = crc16_next(data);
    end

endmodule