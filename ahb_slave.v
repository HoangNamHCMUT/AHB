`include "/home/ftv_training/SFD/4_Intern/2024_Mar/tuan_huynh/verilog_introduction/verilog/parameters.vh"
module ahb_lite_slave #(parameter ADDR_WIDTH = `ADDR_WIDTH, parameter DATA_WIDTH = `DATA_WIDTH, parameter ERR_WIDTH = `ERR_WIDTH) (
  // Global and Control signals
  input HCLK, HRESETn,
  input [ADDR_WIDTH - 1 : 0] MaxAddr,
  // AHB - Lite master - slave interfaces
  input HSEL_slv_i,
  input [ADDR_WIDTH - 1 : 0] HADDR_slv_i,
  input [2:0] HSIZE_slv_i,
  input [2:0] HBURST_slv_i,
  input [1:0] HTRANS_slv_i,
  input HWRITE_slv_i,
  input [DATA_WIDTH - 1 : 0] HWDATA_slv_i,
  output reg HREADY_slv_o, HRESP_slv_o,
  output reg [DATA_WIDTH - 1 : 0] HRDATA_slv_o,
  // AHB - Lite slave - Memory interfaces
  output reg [ADDR_WIDTH - 1 : 0] ADDR_slv_o,
  output reg WRITE_slv_o,
  output reg [DATA_WIDTH - 1 : 0] WDATA_slv_o,
  output reg REQ_slv_o,
  input GRANT_slv_i,
  input [DATA_WIDTH - 1 : 0] RDATA_slv_i
);

  localparam IDLE = 0;
  localparam WDATA = 1;
  localparam WRITE = 2;
  localparam READ = 3;
  localparam DONE = 4;
  localparam FERR = 5;
  localparam SERR = 6;

  reg [2:0] state; // current state of FSM - synthesized to flip-flop
  reg [2:0] nstate; //next state of FSM - synthesized to wire

  // Pipelined variables - Synthesized to wires
  reg HREADY_slv_o_p;
  reg HRESP_slv_o_p;
  reg [DATA_WIDTH - 1 : 0] HRDATA_slv_o_p;
  reg [ADDR_WIDTH - 1 : 0] ADDR_slv_o_p;
  reg WRITE_slv_o_p;
  reg [DATA_WIDTH - 1 : 0] WDATA_slv_o_p;
  reg REQ_slv_o_p;

  // Variables for indicating either write or read operation
  wire ahb_read;
  wire ahb_write;

  assign ahb_read = (HSEL_slv_i) && (HTRANS_slv_i == 2'd2) && (!HWRITE_slv_i);
  assign ahb_write = (HSEL_slv_i) && (HTRANS_slv_i == 2'd2) && (HWRITE_slv_i);

  // Reset logic - Sequential logic
  always@(posedge HCLK or negedge HRESETn)
    begin
      if(!HRESETn)
        begin
          HREADY_slv_o <= 1;
          HRESP_slv_o <= 0;
          HRDATA_slv_o <= {DATA_WIDTH{1'b0}};
          ADDR_slv_o <= {ADDR_WIDTH{1'b0}};
          WRITE_slv_o <= 0;
          WDATA_slv_o <= {DATA_WIDTH{1'b0}};
          REQ_slv_o <= 0;
          state <= IDLE;
        end
      else
        begin
          HREADY_slv_o <= HREADY_slv_o_p;
          HRESP_slv_o <= HRESP_slv_o_p;
          HRDATA_slv_o <= HRDATA_slv_o_p;
          ADDR_slv_o <= ADDR_slv_o_p;
          WRITE_slv_o <= WRITE_slv_o_p;
          WDATA_slv_o <= WDATA_slv_o_p;
          REQ_slv_o <= REQ_slv_o_p;
          state <= nstate;
        end
    end

  // Next state logic - Combinational logic
  always@(*)
    begin
      nstate = state;
      case(state)
        IDLE:
          begin
            if((HADDR_slv_i > MaxAddr) && (!(HTRANS_slv_i == IDLE))) nstate = FERR; // Invalid address
            else if(ahb_write) nstate = WDATA; // Write operation
            else if(ahb_read) nstate = READ; // Read operation
            else nstate = IDLE;
          end
        WDATA:
          begin
            nstate = WRITE;
          end
        WRITE:
          begin
      if(!HSEL_slv_i) nstate = IDLE;
            else if(!GRANT_slv_i) nstate = WRITE;
            else nstate = DONE;
          end
        READ:
          begin
      if(!HSEL_slv_i) nstate = IDLE;
            else if(!GRANT_slv_i) nstate = READ;
            else nstate = DONE;
          end
        DONE:
          begin
            if(HTRANS_slv_i == 2'd1) nstate = DONE;
            else if(HTRANS_slv_i == 2'd0) nstate = IDLE;
            else // HTRANS = 2 or HTRANS = 3
              begin
                if(HWRITE_slv_i) nstate = WDATA; // Continue to perform write operation
                else nstate = READ; // Continue to perform read operation
              end
          end
        FERR:
          begin
            nstate = SERR;
          end
        SERR:
          begin
            nstate = IDLE;
          end
        default:
          begin
            nstate = IDLE;
          end
      endcase
    end

  // Ouput logic - Combinational logic
  always@(*)
    begin
      HREADY_slv_o_p = HREADY_slv_o;
      HRESP_slv_o_p = HRESP_slv_o;
      HRDATA_slv_o_p = HRDATA_slv_o;
      ADDR_slv_o_p = ADDR_slv_o;
      WRITE_slv_o_p = WRITE_slv_o;
      WDATA_slv_o_p = WDATA_slv_o;
      REQ_slv_o_p = REQ_slv_o;
      case(nstate)
        IDLE: // Keep the HREADY signal HIGH to indicate that the slave is now free
          begin
            HREADY_slv_o_p = 1;
            REQ_slv_o_p = 0;
            HRESP_slv_o_p = 0;
          end
        WDATA: // Waiting for one clock cycle to sample the write data from the master
          begin
            HREADY_slv_o_p = 0;
            ADDR_slv_o_p = HADDR_slv_i;
            REQ_slv_o_p = 0;
          end
        WRITE: // Sending the write request to the memory then waiting for the response
          begin
            WRITE_slv_o_p = 1; // Write request
            WDATA_slv_o_p = HWDATA_slv_i;
            HREADY_slv_o_p = 0;
            REQ_slv_o_p = 1;
          end
        READ: // Sending the read request to the memory then waiting for the response
          begin
            ADDR_slv_o_p = HADDR_slv_i;
            WRITE_slv_o_p = 0; // Read request
            HREADY_slv_o_p = 0;
            REQ_slv_o_p = 1;
          end
        DONE: // Having gained the response from the memory, sending the ready signal to the master
          begin
            HRDATA_slv_o_p = RDATA_slv_i;
            HREADY_slv_o_p = 1;
            REQ_slv_o_p = 0;
          end
        FERR:
          begin
            HREADY_slv_o_p = 0;
            HRESP_slv_o_p = 1;
          end
        SERR:
          begin
            HREADY_slv_o_p = 1;
            HRESP_slv_o_p = 1;
          end
        default:
          begin
            HREADY_slv_o_p = 1;
            HRESP_slv_o_p = 0;
            HRDATA_slv_o_p = {DATA_WIDTH{1'b0}};
            ADDR_slv_o_p = {ADDR_WIDTH{1'b0}};
            WRITE_slv_o_p = 0;
            WDATA_slv_o_p = {DATA_WIDTH{1'b0}};
            REQ_slv_o_p = 0;
          end
      endcase
    end

endmodule

