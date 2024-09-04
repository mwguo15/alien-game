`default_nettype none

module BCDtoSevenSegment
    // This module is from hw2, where it takes a BCD value from 0-9 and
    // determines which segments are lighted up
    (input logic [3:0] bcd,
     output logic [6:0] segment);

    always_comb
        casez (bcd)
            4'b0000: segment = 7'b011_1111;
            4'b0001: segment = 7'b000_0110;
            4'b0010: segment = 7'b101_1011;
            4'b0011: segment = 7'b100_1111;
            4'b0100: segment = 7'b110_0110;
            4'b0101: segment = 7'b110_1101;
            4'b0110: segment = 7'b111_1101;
            4'b0111: segment = 7'b000_0111;
            4'b1000: segment = 7'b111_1111;
            4'b1001: segment = 7'b110_0111;
            default: segment = 7'bxxx_xxxx;
        endcase

endmodule : BCDtoSevenSegment

module SevenSegmentDisplay
    // This module is from hw2, where it takes 8 BCD values each from 0-9 and
    // blank which indicates whether the digit should be lighted, and returns
    // 8 HEX digits with the correct segments lighted up
    (input logic [3:0] BCD7, BCD6, BCD5, BCD4, BCD3, BCD2, BCD1, BCD0,
     input logic [7:0] blank,
     output logic [6:0] HEX7, HEX6, HEX5, HEX4, HEX3, HEX2, HEX1, HEX0);

    logic [6:0] HEX7_not, HEX6_not, HEX5_not, HEX4_not, HEX3_not, HEX2_not, 
                HEX1_not, HEX0_not;

    BCDtoSevenSegment o7(BCD7, HEX7_not);
    BCDtoSevenSegment o6(BCD6, HEX6_not);
    BCDtoSevenSegment o5(BCD5, HEX5_not);
    BCDtoSevenSegment o4(BCD4, HEX4_not);
    BCDtoSevenSegment o3(BCD3, HEX3_not);
    BCDtoSevenSegment o2(BCD2, HEX2_not);
    BCDtoSevenSegment o1(BCD1, HEX1_not);
    BCDtoSevenSegment o0(BCD0, HEX0_not);

    assign HEX7 = (blank[7] == 1) ? 7'b111_1111 : ~HEX7_not;
    assign HEX6 = (blank[6] == 1) ? 7'b111_1111 : ~HEX6_not;
    assign HEX5 = (blank[5] == 1) ? 7'b111_1111 : ~HEX5_not;
    assign HEX4 = (blank[4] == 1) ? 7'b111_1111 : ~HEX4_not;
    assign HEX3 = (blank[3] == 1) ? 7'b111_1111 : ~HEX3_not;
    assign HEX2 = (blank[2] == 1) ? 7'b111_1111 : ~HEX2_not;
    assign HEX1 = (blank[1] == 1) ? 7'b111_1111 : ~HEX1_not;
    assign HEX0 = (blank[0] == 1) ? 7'b111_1111 : ~HEX0_not;

endmodule : SevenSegmentDisplay