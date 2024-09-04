`default_nettype none

module chipInterface
    (output logic [7:0] LEDG,
    output logic [6:0] HEX0, HEX1, HEX2, HEX3,
    input logic [17:0] SW,
    input logic [3:0] KEY,
    input logic CLOCK_50);

    logic [3:0] NumGames, RoundNumber, Zood, Znarly;
    logic [7:0] blank;
    logic [11:0] masterPattern;
    logic GameWon;
    logic loadNumGames, loadGuess, loadZnarlyZood, displayMasterPattern;
    
    // all digits blank/off
    assign blank = 8'b1111_0000; 
    assign LEDG = GameWon ? 8'b0000_0001 : 8'b0;
    
    SevenSegmentDisplay disp1 (.BCD0(NumGames), 
                               .BCD1(RoundNumber), 
                               .BCD2(Zood), 
                               .BCD3(Znarly), 
                               .BCD4(),
                               .BCD5(),
                               .BCD6(),
                               .BCD7(),
                               .HEX0, 
                               .HEX1, 
                               .HEX2, 
                               .HEX3, 
                               .HEX4(),
                               .HEX5(),
                               .HEX6(),
                               .HEX7(),
                               .blank);
  
    top A(.CoinValue(SW[17:16]), .CoinInserted(KEY[1]), .StartGame(KEY[2]), 
          .Guess(SW[11:0]), .GradeIt(KEY[3]), .LoadShape(SW[2:0]), 
          .ShapeLocation(SW[4:3]), .LoadShapeNow(KEY[3]), .Znarly, .Zood, 
          .RoundNumber, .NumGames, .GameWon(GameWon), .masterPattern, 
          .reset(KEY[0]), .clock(CLOCK_50), .debug(SW[15]), .loadNumGames, 
          .loadGuess, .loadZnarlyZood, .displayMasterPattern);
    
  endmodule: chipInterface