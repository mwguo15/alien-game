`default_nettype none

// This module checks the result of guess and returns the new round number,
// whether the game is won, and whether the game is finished
module checkResult
    (input logic [3:0] Znarly,
     input logic clock, C_chk_clr,
     output logic [3:0] RoundNumber,
     output logic GameWon, GameFinished);

    logic cmp;

    Comparator #(4) c1 (.A(Znarly), .B(4'd4), .AeqB(GameWon));
    Comparator #(4) c2 (.A(RoundNumber), .B(4'd7), .AeqB(cmp));

    // GameFinished when NewRoundNumber == 8
    assign GameFinished = GameWon | cmp;

    Counter #(4) cnt (.clock(clock), .clear(C_chk_clr), .en(~C_chk_clr),
                      .up(1), .load(), .D(), .Q(RoundNumber));

endmodule: checkResult

module checkResult_test;
    logic [3:0] Znarly, RoundNumber;
    logic clock, C_chk_clr;
    logic GameWon, GameFinished;

    checkResult DUT(.*);

    initial begin
        clock = 0;
        forever #5 clock = ~clock;
    end

    initial begin
        $monitor($time,, 
        "Znarly=%d, RoundNum=%d, GameWon=%d, GameFinished=%d",
        Znarly, RoundNumber, GameWon, GameFinished);
        // initialize values
        Znarly <= 4'd0;
        C_chk_clr <= 1;
        @(posedge clock);
        C_chk_clr <= 0;
        @(posedge clock);
        @(posedge clock);
        Znarly <= 4'd4;

        @(posedge clock);
        Znarly <= 4'd3;
        C_chk_clr <= 1;

        @(posedge clock);
        C_chk_clr <= 0;

        @(posedge clock);

        @(posedge clock);

        @(posedge clock);

        @(posedge clock);

        @(posedge clock);

        @(posedge clock);

        @(posedge clock);
        
        @(posedge clock);
        C_chk_clr <= 1;

        @(posedge clock);
        #1 $finish;
    end

endmodule: checkResult_test