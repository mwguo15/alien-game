`default_nettype none

// Determines which shape has been inputted
module ProcessShape 
(input logic [2:0] shape,
output logic T, C, O, D, I, Z);

    Comparator #(3) C_T(.AeqB(T), .A(3'b001), .B(shape));
    Comparator #(3) C_C(.AeqB(C), .A(3'b010), .B(shape));
    Comparator #(3) C_O(.AeqB(O), .A(3'b011), .B(shape));
    Comparator #(3) C_D(.AeqB(D), .A(3'b100), .B(shape));
    Comparator #(3) C_I(.AeqB(I), .A(3'b101), .B(shape));
    Comparator #(3) C_Z(.AeqB(Z), .A(3'b110), .B(shape));

endmodule: ProcessShape 

// Calls ProcessShape to count the shapes in masterPattern
module CountShapes 
(input logic [11:0] masterPattern, 
output logic [2:0] INIT_T, INIT_C, INIT_O, INIT_D, INIT_I, INIT_Z);
logic S1_T, S1_C, S1_O, S1_D, S1_I, S1_Z,
      S2_T, S2_C, S2_O, S2_D, S2_I, S2_Z,
      S3_T, S3_C, S3_O, S3_D, S3_I, S3_Z,
      S4_T, S4_C, S4_O, S4_D, S4_I, S4_Z;

    ProcessShape S1(masterPattern[2:0], S1_T, S1_C, S1_O, S1_D, S1_I, S1_Z);
    ProcessShape S2(masterPattern[5:3], S2_T, S2_C, S2_O, S2_D, S2_I, S2_Z);
    ProcessShape S3(masterPattern[8:6], S3_T, S3_C, S3_O, S3_D, S3_I, S3_Z);
    ProcessShape S4(masterPattern[11:9], S4_T, S4_C, S4_O, S4_D, S4_I, S4_Z);

    assign INIT_T = S1_T + S2_T + S3_T + S4_T;
    assign INIT_C = S1_C + S2_C + S3_C + S4_C;
    assign INIT_O = S1_O + S2_O + S3_O + S4_O;
    assign INIT_D = S1_D + S2_D + S3_D + S4_D;
    assign INIT_I = S1_I + S2_I + S3_I + S4_I;
    assign INIT_Z = S1_Z + S2_Z + S3_Z + S4_Z;

endmodule: CountShapes

// Takes a shape and the current shape count and then decrements shape count
module SubtractShape
(input logic [2:0] shape, num_T, num_C, num_O, num_D, num_I, num_Z,
input logic found, output logic [2:0] T, C, O, D, I, Z);

    always_comb begin
        T = num_T; C = num_C; O = num_O; D = num_D; I = num_I; Z = num_Z;
        if (found) begin
            case (shape)
                3'b001: T = (T > 0) ? num_T - 1 : num_T;
                3'b010: C = (C > 0) ? num_C - 1 : num_C;
                3'b011: O = (O > 0) ? num_O - 1 : num_O;
                3'b100: D = (D > 0) ? num_D - 1 : num_D;
                3'b101: I = (I > 0) ? num_I - 1 : num_I;
                3'b110: Z = (Z > 0) ? num_Z - 1 : num_Z;
            endcase
        end
    end
endmodule: SubtractShape

// Compares each part of Guess to masterPattern count Znarly
module ZnarlySearch
    (input logic [11:0] Guess, masterPattern,
    output logic [3:0] ZnarlyResult);
    
    Comparator #(3) S0(ZnarlyResult[0], Guess[2:0], masterPattern[2:0]);
    Comparator #(3) S1(ZnarlyResult[1], Guess[5:3], masterPattern[5:3]);
    Comparator #(3) S2(ZnarlyResult[2], Guess[8:6], masterPattern[8:6]);
    Comparator #(3) S3(ZnarlyResult[3], Guess[11:9], masterPattern[11:9]);

endmodule: ZnarlySearch

module ZoodSearch
    (input logic [2:0] Guess, input logic ZnarlyResult,
    input logic [2:0] T, C, O, D, I, Z,
    output logic Zood, 
    output logic [2:0] num_T, num_C, num_O, num_D, num_I, num_Z);

    SubtractShape Sub(Guess, T, C, O, D, I, Z, ~ZnarlyResult,
                      num_T, num_C, num_O, num_D, num_I, num_Z);

    always_comb begin
        Zood = 0;
        if (~ZnarlyResult)
            case (Guess)
                3'b001: Zood = T ? 1 : 0;
                3'b010: Zood = C ? 1 : 0;
                3'b011: Zood = O ? 1 : 0;
                3'b100: Zood = D ? 1 : 0;
                3'b101: Zood = I ? 1 : 0;
                3'b110: Zood = Z ? 1 : 0;
            endcase
    end

endmodule: ZoodSearch

// Counts shapes then counts Znarly, subtracting shapes that have been accounted 
// for. Counts Zoods by seeing if the shape represented by Guess is still
// within masterPattern - if so, subtract the shape and add to Zood. Uses 
// Mux2to1 to choose between default values and graded values.
module Grader
    (input logic [11:0] Guess, masterPattern, 
    input logic GradeIt, CLOCK_50, reset,
    output logic [3:0] Znarly, Zood);

    logic [3:0] ZnarlyResult, ZoodResult, Zood_G, Znarly_G;
    logic [2:0] INIT_T, INIT_C, INIT_O, INIT_D, INIT_I, INIT_Z, 
                T1, C1, O1, D1, I1, Z1,
                T2, C2, O2, D2, I2, Z2,
                T3, C3, O3, D3, I3, Z3,
                T, C, O, D, I, Z,
                Tz_1, Cz_1, Oz_1, Dz_1, Iz_1, Zz_1,
                Tz_2, Cz_2, Oz_2, Dz_2, Iz_2, Zz_2,
                Tz_3, Cz_3, Oz_3, Dz_3, Iz_3, Zz_3;

    CountShapes Count(.*);

    ZnarlySearch Check(.*);

    SubtractShape ZnarlyS0(Guess[2:0], 
                            INIT_T, INIT_C, INIT_O, INIT_D, INIT_I, INIT_Z, 
                            ZnarlyResult[0], 
                            T1, C1, O1, D1, I1, Z1);
    SubtractShape ZnarlyS1(Guess[5:3], 
                            T1, C1, O1, D1, I1, Z1, 
                            ZnarlyResult[1], 
                            T2, C2, O2, D2, I2, Z2);
    SubtractShape ZnarlyS2(Guess[8:6], 
                            T2, C2, O2, D2, I2, Z2, 
                            ZnarlyResult[2], 
                            T3, C3, O3, D3, I3, Z3);
    SubtractShape ZnarlyS3(Guess[11:9], 
                            T3, C3, O3, D3, I3, Z3, 
                            ZnarlyResult[3], 
                            T, C, O, D, I, Z);

    ZoodSearch CalcZood0(Guess[2:0], ZnarlyResult[0], T, C, O, D, I, Z,
                         ZoodResult[0], Tz_1, Cz_1, Oz_1, Dz_1, Iz_1, Zz_1);
    ZoodSearch CalcZood1(Guess[5:3], ZnarlyResult[1], 
                         Tz_1, Cz_1, Oz_1, Dz_1, Iz_1, Zz_1,
                         ZoodResult[1], Tz_2, Cz_2, Oz_2, Dz_2, Iz_2, Zz_2);
    ZoodSearch CalcZood2(Guess[8:6], ZnarlyResult[2], 
                         Tz_2, Cz_2, Oz_2, Dz_2, Iz_2, Zz_2,
                         ZoodResult[2], Tz_3, Cz_3, Oz_3, Dz_3, Iz_3, Zz_3);
    ZoodSearch CalcZood3(Guess[11:9], ZnarlyResult[3], 
                         Tz_3, Cz_3, Oz_3, Dz_3, Iz_3, Zz_3,
                         ZoodResult[3], , , , , , );

    assign Znarly_G = ZnarlyResult[3] + ZnarlyResult[2] + 
                      ZnarlyResult[1] + ZnarlyResult[0];
    
    assign Zood_G = ZoodResult[3] + ZoodResult[2] + 
                    ZoodResult[1] + ZoodResult[0];

    Mux2to1 #(4) Zn(.Y(Znarly), .I0(4'b0000), .I1(Znarly_G), .S(GradeIt));
    Mux2to1 #(4) Zo(.Y(Zood), .I0(4'b0000), .I1(Zood_G), .S(GradeIt));

endmodule: Grader


module test_grader();
    logic [11:0] Guess, masterPattern;
    logic GradeIt, CLOCK_50, reset;
    logic [3:0] Znarly, Zood;


    Grader DUT(.*);

    initial begin 
        $monitor($time,,
        "Guess = %b, masterPattern = %b, gradeit = %b, Znarly = %d, Zood = %d",
        Guess, masterPattern, GradeIt, Znarly, Zood);
        // T = 001, C = 010, O = 011, D = 100, I = 101, Z = 110
        GradeIt = 1;
        masterPattern = 12'b101_110_100_001; // IZDT
        #5 Guess = 12'b001_001_010_010; // TTCC 0 1
        #5 Guess = 12'b011_011_100_100; // OODD 1 0
        #5 Guess = 12'b101_101_010_010; // IICC 1 0 
        #5 Guess = 12'b101_011_001_110; // IOTZ 1 2
        #5 Guess = 12'b001_101_110_100; // TIZD 0 4
        #5 Guess = 12'b101_110_100_001; // IZDT 4 0
        #5 Guess = 12'b101_110_110_110; // IZZZ 2 0
        #5 Guess = 12'b101_110_101_010; // IZIC 2 0
        #10 masterPattern = 12'b001_110_010_001; // TZCT
        Guess = 12'b001_001_101_100; // TTID 1 1
        #5 Guess = 12'b001_110_010_010; // TZCC 3 0
        #10 masterPattern = 12'b110_010_110_110; // ZCZZ
        Guess = 12'b010_001_010_001; // CTCT
        #5 Guess = 12'b010_010_110_110; // CCZZ
        #5 Guess = 12'b110_110_001_001; // ZZTT
        #5 $finish;
    end


endmodule: test_grader