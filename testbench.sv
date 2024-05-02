`timescale 1ns/100ps

`include "parameters.vh"

module tb_AHB;

  //  Global signals
  logic           HCLK      ;
  logic           HRESETn     ;

  //  MASTER SIDE
  logic [`ADDR_WIDTH-1:0]   ADDR_t_h    ;
    logic           RW_t_h      ;
    logic           TRANSFER_t_h  ;
    logic [`DATA_WIDTH-1:0]   WDATA_t_h   ;
  logic           timeout     ;

    logic [`ERR_WIDTH-1:0]  FAIL_h_t    ;
    logic             DONE_h_t    ;
    logic [`DATA_WIDTH-1:0]   RDATA_h_t   ;

    logic             HSEL_m_s    ;
    logic [`ADDR_WIDTH-1:0]   HADDR_m_s   ;
    logic             HWRITE_m_s    ;
    logic [2:0]         HSIZE_m_s   ;
    logic [2:0]         HBURST_m_s    ;
    logic [1:0]         HTRANS_m_s    ;
    logic [`DATA_WIDTH-1:0]   HWDATA_m_s    ;

    logic           HREADY_s_m    ;
    logic           HRESP_s_m   ;
    logic [`DATA_WIDTH-1:0]   HRDATA_s_m    ;


  //  SLAVE SIDE
  logic           HSEL_slv_i    ;
  logic [`ADDR_WIDTH-1:0] HADDR_slv_i   ;
  logic           HWRITE_slv_i  ;
  logic [2:0]       HSIZE_slv_i   ;
  logic [2:0]       HBURST_slv_i  ;
  logic [1:0]       HTRANS_slv_i  ;
  logic [`DATA_WIDTH-1:0] HWDATA_slv_i  ;
  logic [`ADDR_WIDTH-1:0] MaxAddr     ;

  logic           HREADY_slv_o  ;
  logic           HRESP_slv_o   ;
  logic [`DATA_WIDTH-1:0] HRDATA_slv_o  ;

  logic [`ADDR_WIDTH-1:0] ADDR_slv_o    ;
  logic           WRITE_slv_o   ;
  logic [`DATA_WIDTH-1:0] WDATA_slv_o   ;
  logic           REQ_slv_o   ;

  logic           GRANT_slv_i   ;
  logic [`DATA_WIDTH-1:0] RDATA_slv_i   ;

  //  INSTANCE
  AHB_Lite_master mAHB_0(
    .HCLK     (HCLK     ),
    .HRESETn    (HRESETn    ),

    .ADDR_t_h   (ADDR_t_h   ),
    .RW_t_h     (RW_t_h     ),
    .TRANSFER_t_h (TRANSFER_t_h ),
    .WDATA_t_h    (WDATA_t_h    ),
    .timeout    (timeout    ),

    .FAIL_h_t   (FAIL_h_t   ),
    .DONE_h_t   (DONE_h_t   ),
    .RDATA_h_t    (RDATA_h_t    ),

    .HSEL_m_s   (HSEL_m_s     ),
    .HADDR_m_s    (HADDR_m_s    ),
    .HWRITE_m_s   (HWRITE_m_s   ),
    .HSIZE_m_s    (HSIZE_m_s    ),
    .HBURST_m_s   (HBURST_m_s   ),
    .HTRANS_m_s   (HTRANS_m_s   ),
    .HWDATA_m_s   (HWDATA_m_s   ),

    .HREADY_s_m   (HREADY_s_m   ),
    .HRESP_s_m    (HRESP_s_m    ),
    .HRDATA_s_m   (HRDATA_s_m   )
  );

  ahb_lite_slave sAHB_0(
    .HCLK     (HCLK     ),
    .HRESETn    (HRESETn    ),
    .HSEL_slv_i   (HSEL_slv_i   ),
    .HADDR_slv_i  (HADDR_slv_i  ),
    .HWRITE_slv_i (HWRITE_slv_i ),
    .HSIZE_slv_i  (HSIZE_slv_i  ),
    .HBURST_slv_i (HBURST_slv_i ),
    .HTRANS_slv_i (HTRANS_slv_i ),
    .HWDATA_slv_i (HWDATA_slv_i ),
    .MaxAddr    (MaxAddr    ),

    .HREADY_slv_o (HREADY_slv_o ),
    .HRESP_slv_o  (HRESP_slv_o  ),
    .HRDATA_slv_o (HRDATA_slv_o ),

    .ADDR_slv_o   (ADDR_slv_o   ),
    .WRITE_slv_o  (WRITE_slv_o  ),
    .WDATA_slv_o  (WDATA_slv_o  ),
    .REQ_slv_o    (REQ_slv_o    ),

    .GRANT_slv_i  (GRANT_slv_i  ),
    .RDATA_slv_i  (RDATA_slv_i  )
  );

  //  Assign
  assign  HSEL_slv_i    = HSEL_m_s    ;
  assign  HADDR_slv_i   = HADDR_m_s   ;
  assign  HWRITE_slv_i  = HWRITE_m_s    ;
  assign  HSIZE_slv_i   = HSIZE_m_s   ;
  assign  HBURST_slv_i  = HBURST_m_s    ;
  assign  HTRANS_slv_i  = HTRANS_m_s    ;
  assign  HWDATA_slv_i  = HWDATA_m_s    ;

  assign  HREADY_s_m    = HREADY_slv_o  ;
  assign  HRESP_s_m   = HRESP_slv_o   ;
  assign  HRDATA_s_m    = HRDATA_slv_o  ;

  //  Testbench
  initial
  begin
    HCLK  = 1'b1;
    forever #5 HCLK = ~HCLK;
  end

  //  Helper file
  `include "./test_cases/helper.v"

  //  Load test cases
  initial
  begin

    RESET_AHB;

  end


  //  Waveform gen
  initial
  begin
    #500;
    $finish();
  end

  initial
  begin
    $fsdbDumpfile("dump.fsdb");
    $fsdbDumpvars;
  end


endmodule