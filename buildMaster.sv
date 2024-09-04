`default_nettype none

// Builds the masterPattern until all spots have been filled, takes
// 4+ clock cycles depending on if spots are repeated or not
module buildMaster
    (input logic [2:0] LoadShape, input logic [1:0] ShapeLocation,
    input logic clock, reset, LoadShapeNow, 
                R_C_en, R_C_clr, R_M_en, R_M_clr, 
    output logic [11:0] masterPattern, output logic LoadDone);

    logic [3:0] old_checked, checked_mask, new_checked;
    logic [3:0] by;
    logic [11:0] init_master_mask, m_mask, master_mask, old_master, new_master;

    // Checked logic

    Decoder #(4) C_Mask(.D(checked_mask), .I(ShapeLocation), .en(1'b1));

    assign new_checked = LoadShapeNow ? 
                         (old_checked | checked_mask) : old_checked;

    Register #(4) StoreCheck(.Q(old_checked), .D(new_checked), 
                             .clock(clock), .en(R_C_en), .clear(R_C_clr));

    // Master logic

    always_comb begin
        case (ShapeLocation)
            2'd0: by = 4'd0;
            2'd1: by = 4'd3;
            2'd2: by = 4'd6;
            2'd3: by = 4'd9;
        endcase
    end

    assign init_master_mask = {9'd0, LoadShape};

    BarrelShifter M_Mask(.S(m_mask), .V(init_master_mask), .by(by));

    Mux2to1 #(12) Master(.I0(m_mask), .I1(12'd0), 
                  .S(old_checked[ShapeLocation]), .Y(master_mask));

    assign new_master = LoadShapeNow ? 
                        (old_master | master_mask) : old_master;
    
    Register #(12) StoreMaster(.Q(old_master), .D(new_master), 
                               .clock(clock), .en(R_M_en), .clear(R_M_clr));

    assign masterPattern = new_master;

    assign LoadDone = new_checked == 4'b1111;



endmodule: buildMaster

module test_buildMaster();
    logic [2:0] LoadShape;
    logic [1:0] ShapeLocation;
    logic clock, reset, LoadShapeNow, R_C_en, R_C_clr, R_M_en, R_M_clr;
    logic [11:0] masterPattern; 
    logic LoadDone;

    buildMaster DUT(.*);

    initial begin
        clock = 0;
        forever #5 clock = ~clock;
    end

    initial begin
        $monitor("masterPattern(%b), masterMask(%b), m_mask(%b), LoadDone(%d), LoadShape(%b), ShapeLocation(%d), old_checked(%b), new_checked(%b)",
        masterPattern, DUT.master_mask, DUT.m_mask, LoadDone, LoadShape, ShapeLocation, DUT.old_checked, DUT.new_checked);

        reset = 1;
        R_C_clr = 1;
        R_M_clr = 1;
        reset <= 0;
        @ (posedge clock)

        @ (posedge clock)

        R_C_en <= 1; R_M_en <= 1; R_C_clr <= 0; R_M_clr <= 0; LoadShapeNow <= 1;

        LoadShape <= 3'b001;
        ShapeLocation <= 2'd3;
        @ (posedge clock); 

        ShapeLocation <= 2'd3;
        LoadShape <= 3'b110;
        @ (posedge clock); 

        LoadShape <= 3'b101;
        ShapeLocation <= 2'd1;
        @ (posedge clock);

        LoadShape <= 3'b110;
        ShapeLocation <= 2'd1;
        @ (posedge clock);

        LoadShape <= 3'b110;
        ShapeLocation <= 2'd0;        
        @ (posedge clock);

        LoadShape <= 3'b001;
        ShapeLocation <= 2'd0;        
        @ (posedge clock);

        LoadShapeNow <= 1'b0;
        LoadShape <= 3'b010;
        ShapeLocation <= 2'd2;
        @ (posedge clock);

        LoadShape <= 3'b110;
        ShapeLocation <= 2'd2;
        @ (posedge clock);

        // Should be 001_010_101_110

        #1 $finish;
    end
endmodule: test_buildMaster
