`include "parameters.vh"

module AHB_Lite_master
  (
    //  Global signals
    input             HCLK    ,
    input             HRESETn   ,

    //  JTAG interface
    input   [`ADDR_WIDTH-1:0] ADDR_t_h  ,
    input             RW_t_h    ,
    input             TRANSFER_t_h,
    input   [`DATA_WIDTH-1:0] WDATA_t_h ,

    output  reg [`ERR_WIDTH-1:0]  FAIL_h_t  ,
    output  reg           DONE_h_t  ,
    output  reg [`DATA_WIDTH-1:0] RDATA_h_t ,

    input             timeout   ,

    //  Master signals
    output  reg           HSEL_m_s  ,
    output  reg [`ADDR_WIDTH-1:0] HADDR_m_s ,
    output  reg           HWRITE_m_s  ,
    output  reg [2:0]       HSIZE_m_s ,
    output  reg [2:0]       HBURST_m_s  ,
    output  reg [1:0]       HTRANS_m_s  ,
    output  reg [`DATA_WIDTH-1:0] HWDATA_m_s  ,

    //  Slave signals
    input             HREADY_s_m  ,
    input             HRESP_s_m ,
    input   [`DATA_WIDTH-1:0] HRDATA_s_m
  );

//  Pipeline variables
reg   [`ERR_WIDTH-1:0]  FAIL_h_t_p  ;
reg             DONE_h_t_p  ;
reg   [`DATA_WIDTH-1:0] RDATA_h_t_p ;

reg             HSEL_m_s_p  ;
reg   [`ADDR_WIDTH-1:0] HADDR_m_s_p ;
reg             HWRITE_m_s_p;
reg   [2:0]       HSIZE_m_s_p ;
reg   [2:0]       HBURST_m_s_p;
reg   [1:0]       HTRANS_m_s_p;
reg   [`DATA_WIDTH-1:0] HWDATA_m_s_p;

reg   [`DATA_WIDTH-1:0] DATA_tmp, DATA_tmp_p  ;

//  State variables
reg   [1:0]       cs, ns          ;

wire            timeout_flag      ;
wire  [`ERR_WIDTH-1:0]  error_rp        ;

assign  timeout_flag  = timeout           ;
assign  error_rp    = {timeout_flag, HRESP_s_m} ;

//  State definition
parameter IDLE  = 2'b00 ,
      ADDR  = 2'b01 ,
      DATA  = 2'b10 ,
      DONE  = 2'b11 ;

//  FSM
always @(posedge HCLK, negedge HRESETn)
begin
  if (!HRESETn)
  begin
    cs      <=  IDLE        ;

    HSEL_m_s  <=  1'b0        ;
    HADDR_m_s <=  {`ADDR_WIDTH{1'b0}} ;
    HWRITE_m_s  <=  1'b0        ;
    HSIZE_m_s <=  3'b010        ;
    HBURST_m_s  <=  3'b000        ;
    HTRANS_m_s  <=  2'b00       ;
    HWDATA_m_s  <=  {`DATA_WIDTH{1'b0}} ;

    FAIL_h_t  <=  {`ERR_WIDTH{1'b0}}  ;
    DONE_h_t  <=  1'b0        ;
    RDATA_h_t <=  {`DATA_WIDTH{1'b0}} ;

    DATA_tmp  <=  {`DATA_WIDTH{1'b0}} ;
  end
  else
  begin
    cs      <=  ns          ;

    HSEL_m_s  <=  HSEL_m_s_p      ;
    HADDR_m_s <=  HADDR_m_s_p     ;
    HWRITE_m_s  <=  HWRITE_m_s_p    ;
    HSIZE_m_s <=  HSIZE_m_s_p     ;
    HBURST_m_s  <=  HBURST_m_s_p    ;
    HTRANS_m_s  <=  HTRANS_m_s_p    ;
    HWDATA_m_s  <=  HWDATA_m_s_p    ;

    FAIL_h_t  <=  FAIL_h_t_p      ;
    DONE_h_t  <=  DONE_h_t_p      ;
    RDATA_h_t <=  RDATA_h_t_p     ;

    DATA_tmp  <=  DATA_tmp_p      ;
  end
end

//  FSM - Transition
always @(*)
begin
  case (cs)
    //  IDLE
    IDLE:
    begin
      ns  = TRANSFER_t_h ? ADDR : IDLE;
    end

    //  ADDR
    ADDR:
    begin
      ns  = DATA;
    end

    //  DATA
    DATA:
    begin
      ns  = ((!timeout_flag) && (!HREADY_s_m)) ? DATA : DONE;
    end

    //  DONE
    DONE:
    begin
      ns  = IDLE;
    end

    //DEFAULT
    default:
    begin
      ns  = IDLE;
    end
  endcase
end

//  FSM - Logic
always @(*)
begin
  HSEL_m_s_p    = HSEL_m_s  ;
  HADDR_m_s_p   = HADDR_m_s ;
  HWRITE_m_s_p  = HWRITE_m_s  ;
  HSIZE_m_s_p   = HSIZE_m_s ;
  HBURST_m_s_p  = HBURST_m_s  ;
  HTRANS_m_s_p  = HTRANS_m_s  ;
  HWDATA_m_s_p  = HWDATA_m_s  ;

  FAIL_h_t_p      = FAIL_h_t  ;
  DONE_h_t_p      = DONE_h_t    ;
  RDATA_h_t_p     = RDATA_h_t ;

  DATA_tmp_p    = DATA_tmp  ;

  case (ns)
    //  IDLE
    IDLE:
    begin
      FAIL_h_t_p    = {`ERR_WIDTH{1'b0}}  ;
      DONE_h_t_p    = 1'b0        ;

      DATA_tmp_p    = {`DATA_WIDTH{1'b0}} ;
    end

    //  ADDR
    ADDR:
    begin
      HSEL_m_s_p    = 1'b1        ; //  enable slave
      HADDR_m_s_p   = ADDR_t_h      ; //  sample addr
      HWRITE_m_s_p  = RW_t_h        ; //  sample write direction
      HSIZE_m_s_p   = 3'b010        ; //  fixed WORD size
      HBURST_m_s_p  = 3'b000        ; //  fixed SINGLE transfer
      HTRANS_m_s_p  = 2'b10       ; //  fixed NONSEQ mode

      DATA_tmp_p    = WDATA_t_h     ; //  sample write data from JTAG and hold
    end

    //  DATA
    DATA:
    begin
      HTRANS_m_s_p  = 2'b00       ;
      if (HWRITE_m_s_p)
        HWDATA_m_s_p  = DATA_tmp_p      ;
    end

    //  DONE
    DONE:
    begin
      if (!HWRITE_m_s_p)
        RDATA_h_t_p   = HRDATA_s_m      ;

      DONE_h_t_p    = 1'b1        ;
      FAIL_h_t_p    = error_rp      ;

      HSEL_m_s_p    = 1'b0        ;
    end

    //  DEFAULT
    default:
    begin
      FAIL_h_t_p    = {`ERR_WIDTH{1'b0}}  ;
      DONE_h_t_p    = 1'b0        ;

      DATA_tmp_p    = {`DATA_WIDTH{1'b0}} ;
    end

  endcase

end

endmodule

