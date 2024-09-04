`default_nettype none

module checkResult_test;
    logic [3:0] Znarly, RoundNumber;
    logic clock;
    logic [3:0] NewRoundNumber;
    logic GameWon, GameFinished;

    checkResult DUT(.*);

    initial begin
        clock = 0;
        forever #5 clock = ~clock;
    end

    initial begin
        $monitor($time,, 
        "Znarly=%d, RoundNum=%d, NewRoundNum=%d, GameWon=%d, GameFinished=%d",
        Znarly, RoundNumber, NewRoundNumber, GameWon, GameFinished);
        // initialize values
        Znarly <= 4'd0;
        RoundNumber <= 4'd0;
        @(posedge clock);
        @(posedge clock);
        Znarly <= 4'd4;

        @(posedge clock);
        Znarly <= 4'd3;

        @(posedge clock);

        @(posedge clock);

        @(posedge clock);

        @(posedge clock);

        @(posedge clock);

        @(posedge clock);

        @(posedge clock);

        @(posedge clock);
        
        @(posedge clock);
        #1 $finish;
    end

endmodule: checkResult_test

module test_top
    logic clock,
    logic reset,
    logic [1:0] CoinValue,
    logic StartGame, CoinInserted, GradeIt,
    logic [11:0] Guess,
    logic [2:0] LoadShape,
    logic [1:0] ShapeLocation,
    logic LoadShapeNow, debug,
    logic [3:0] Znarly, Zood, RoundNumber, NumGames,
    logic [11:0] masterPattern, 
    logic GameWon,
    logic loadNumGames, loadGuess, loadZnarlyZood, displayMasterPattern;

    top DUT(.*);

    initial begin
        clock = 0;
        forever #5 clock = ~clock;
    end

    initial begin
        $monitor($time,, 
        "Guess(%b), masterPattern(%b), GameWon(%b), 
        RoundNumber(%b), NumGames(%b), Znarly(%d), Zood(%d)", 
        Guess, masterPattern, GameWon, RoundNumber, NumGames,
        Znarly, Zood);

        $monitor($time,, 
        "CoinValue(%b), Credit(%b), CoinInserted(%b)", 
        CoinValue, DUT.credit, CoinInserted);

        // initialize values
        reset <= 1;
        reset = 0;
        @(posedge clock);

        CoinValue <= 2'b01;
        CoinInserted <= 1'b1;
        @(posedge clock);
        CoinValue <= 2'b01;
        @(posedge clock);
        CoinValue <= 2'b11;
        @(posedge clock);
        StartGame <= 1;
        
        @(posedge clock);

        @(posedge clock);

        @(posedge clock);

        @(posedge clock);

        @(posedge clock);

        @(posedge clock);

        @(posedge clock);

        @(posedge clock);

        @(posedge clock);
        
        @(posedge clock);
        #1 $finish;
    end


endmodule: test_top