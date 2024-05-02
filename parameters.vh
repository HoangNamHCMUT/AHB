`ifndef _PARAMETERS_VH_
`define _PARAMETERS_VH_

  //  AHB and APB
    `define DATA_WIDTH          32
    `define ADDR_WIDTH      32
    `define ERR_WIDTH       2

  //  AHB and APB test - will be deleted later
  `define pre_reset     11
  `define pos_reset     15

  //  SYNC
  `define DATA_SYNC_WIDTH   32
    `define SHIFT_REG_WIDTH     2


    // Timeout
    `define TIME_OUT_VALUE      10


  //
    `define IR_WIDTH      10
    `define CMD_WIDTH     10
    `define MEM_WIDTH       32
    `define MEM_DEPTH       10
    `define REQ_NUM                 2
    `define COUNTER_W     1
    `define TEST_NUM      1

  //  TAP
    `define IDLE      4'd0
    `define DR_SELECT     4'd1
    `define DR_CAPTURE      4'd2
    `define DR_SHIFT      4'd3
    `define DR_EXIT1      4'd4
    `define DR_PAUSE      4'd5
    `define DR_EXIT2      4'd6
    `define DR_UPDATE     4'd7
    `define IR_SELECT     4'd8
    `define IR_CAPTURE      4'd9
    `define IR_SHIFT      4'd10
    `define IR_EXIT1      4'd11
    `define IR_PAUSE      4'd12
    `define IR_EXIT2      4'd13
    `define IR_UPDATE     4'd14
    `define RESET     4'd15

  //
    `define RESULT_WIDTH    32
    `define AHB_READ      10'h200
    `define AHB_WRITE_ADDR    10'h201
    `define APB_READ      10'h300
    `define APB_WRITE_ADDR    10'h301
    `define WRITE_STT     10'h380
    `define READ_STT      10'h381
    `define READ_DATA     10'h382
    `define AHB_WRITE_DATA    10'h383
    `define APB_WRITE_DATA    10'h384
    `define BYPASS      10'h3FF

    `define DONE      2'b00
    `define NOT_DONE      2'b01
    `define INVALID_ADDR    2'b10
    `define TIME_OUT      2'b11

`endif
