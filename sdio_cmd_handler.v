`timescale 1ns / 1ps

module sdio_cmd_handler (
    input wire sd_clk,
    input wire sd_cmd,
    output reg sd_cmd_out,
    output reg sd_cmd_dir, // 1: output, 0: input
    output reg [47:0] cmd_reg,
    output reg cmd_valid,
    output reg crc_error,
    output reg timeout_error
);

    // Internal signals
    reg [3:0] cmd_state;
    reg [6:0] crc7;
    reg [15:0] timeout_counter;

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

    // Timeout Counter
    always @(posedge sd_clk) begin
        if (!timeout_error) begin
            timeout_counter <= 16'h0;
        end else if (cmd_state == 4'b0001) begin
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

    // SDIO Command Handling
    always @(posedge sd_clk) begin
        cmd_reg <= {cmd_reg[46:0], sd_cmd};
        case (cmd_state)
            4'b0000: if (cmd_reg[47:46] == 2'b01) cmd_state <= 4'b0001; // Start bit detected
            4'b0001: begin
                        if (cmd_reg[45:40] == 6'b000000) begin // CMD0: GO_IDLE_STATE
                            cmd_valid <= 1'b1;
                            cmd_state <= 4'b0010;
                        end else if (cmd_reg[45:40] == 6'b000010) begin // CMD8: SEND_IF_COND
                            cmd_valid <= 1'b1;
                            cmd_state <= 4'b0010;
                        end else if (cmd_reg[45:40] == 6'b001010) begin // ACMD41: SD_SEND_OP_COND
                            cmd_valid <= 1'b1;
                            cmd_state <= 4'b0010;
                        end else if (cmd_reg[45:40] == 6'b001011) begin // CMD17: READ_SINGLE_BLOCK
                            cmd_valid <= 1'b1;
                            cmd_state <= 4'b0010;
                        end else if (cmd_reg[45:40] == 6'b001110) begin // CMD24: WRITE_BLOCK
                            cmd_valid <= 1'b1;
                            cmd_state <= 4'b0010;
                        end else begin
                            cmd_state <= 4'b0000; // Invalid command, reset state
                        end
                     end
            4'b0010: if (cmd_valid) begin
                        sd_cmd_out <= 1'b0; // Example response
                        sd_cmd_dir <= 1'b1; // Set direction to output
                        cmd_state <= 4'b0011;
                     end
            4'b0011: begin
                        sd_cmd_dir <= 1'b0; // Reset direction to input
                        cmd_valid <= 1'b0;
                        cmd_state <= 4'b0000;
                     end
            default: cmd_state <= 4'b0000;
        endcase
    end

endmodule