
`timescale 1ns / 1ps

module sdio_data_handler (
    input wire sd_clk,
    inout wire [3:0] sd_data,
    output reg [3:0] data_in_reg,
    output reg [3:0] data_out_reg,
    output reg data_dir_reg,
    output reg data_valid,
    output reg crc_error,
    output reg timeout_error
);

    // Internal signals
    reg [3:0] data_state;
    reg [15:0] crc16;
    reg [15:0] timeout_counter;

    // Transmit (TX) and Receive (RX) buffers
    reg [3:0] tx_buffer;
    reg [3:0] rx_buffer;

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

    // Timeout Counter
    always @(posedge sd_clk) begin
        if (!timeout_error) begin
            timeout_counter <= 16'h0;
        end else if (data_state == 4'b0001) begin
            if (timeout_counter < 16'hFFFF) begin
                timeout_counter <= timeout_counter + 1;
            end else begin
                timeout_error <= 1'b1;
                timeout_counter <= 16'h0;
            end
        end else begin
            timeout_counter <= 16'h0;
            timeout_error <= 1'b0;
        end
    end

    // SDIO Data Handling
    always @(posedge sd_clk) begin
        case (data_state)
            4'b0000: if (data_dir_reg == 1'b0) begin
                        data_state <= 4'b0001;
                     end else begin
                        data_dir_reg <= 1'b1; // Set direction to output for write
                        tx_buffer <= 4'b0101; // Example data to write
                        data_state <= 4'b0001;
                     end
            4'b0001: if (data_dir_reg == 1'b0) begin
                        rx_buffer <= sd_data;
                        data_in_reg <= rx_buffer;
                        data_valid <= 1'b1;
                        data_state <= 4'b0010;
                     end else begin
                        data_out_reg <= tx_buffer;
                        data_state <= 4'b0010;
                     end
            4'b0010: if (data_valid) begin
                        data_state <= 4'b0000; // Data processing done
                     end
            default: data_state <= 4'b0000;
        endcase
    end

endmodule