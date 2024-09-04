`default_nettype none

// FSM for the top module which controls the state and control points
module fsm
    (input logic reset, clock,
    input logic [3:0] NumGames,
    input logic StartGame, LoadDone, GradeIt, GameFinished, drop, CoinInserted,
    output logic game_cnt_en, R_C_en, R_C_clr, R_M_en, R_M_clr, C_chk_clr,
    output logic loadNumGames, loadGuess, loadZnarlyZood, displayMasterPattern);

    enum logic [1:0] {INIT = 2'b00, LOAD = 2'b01, GUESS = 2'b10, CHECK = 2'b11} 
        cur_state, n_state;
    logic GameNotReady;
    logic game_limit_reached;

    Comparator #(4) cmp (.A(NumGames), .B(4'd0), .AeqB(GameNotReady));
     
    Comparator #(4) cmp_gm (.A(NumGames), .B(4'd7), .AeqB(game_limit_reached));

    // Prevents overflow of game count
    assign game_cnt_en = ~(game_limit_reached) & 
                        (CoinInserted & drop | GameFinished);

    assign loadNumGames = 1;

    always_comb begin
        case (cur_state)
            // if necessary, add another state to clear game count
            INIT: begin
                n_state = (~StartGame | GameNotReady) ? INIT : LOAD;
                R_C_en = (~StartGame | GameNotReady) ? 0 : 1;
                R_C_clr = (~StartGame | GameNotReady) ? 1 : 0;
                R_M_en = (~StartGame | GameNotReady) ? 0 : 1;
                R_M_clr = (~StartGame | GameNotReady) ? 1 : 0;
                C_chk_clr = 1;
                loadGuess = 0;
                loadZnarlyZood = 0;
                displayMasterPattern = 0;
            end
            LOAD: begin
                n_state = LoadDone ? GUESS : LOAD;
                R_C_en = LoadDone ? 0 : 1;
                R_C_clr = LoadDone ? 1 : 0;
                R_M_en = LoadDone ? 0 : 1;
                R_M_clr = LoadDone ? 1 : 0;
                C_chk_clr = 1;
                loadGuess = 0;
                loadZnarlyZood = 0;
                displayMasterPattern = 0;
            end
            GUESS: begin
                n_state = (GradeIt) ? CHECK : GUESS;
                R_C_en = 0;
                R_C_clr = 1;
                R_M_en = 0;
                R_M_clr = 1;
                C_chk_clr = 0;
                displayMasterPattern = 0;
                loadGuess = (GradeIt) ? 1 : 0; // ???
                loadZnarlyZood = 0;
            end
            CHECK: begin
                n_state = (GameFinished) ? INIT : GUESS;
                R_C_en = 0;
                R_C_clr = 1;
                R_M_en = 0;
                R_M_clr = 1;
                C_chk_clr = (GameFinished) ? 1 : 0;
                loadGuess = 0;
                loadZnarlyZood = 1;
                displayMasterPattern = (GameFinished) ? 1 : 0;
            end
        endcase
    end

    always_ff @(posedge clock, posedge reset) begin
        if (reset) cur_state <= INIT;
        else       cur_state <= n_state;
    end
    
endmodule: fsm

// top modules that connect everything together
module top
    (input logic clock,
    input logic reset,
    input logic [1:0] CoinValue,
    input logic StartGame, CoinInserted, GradeIt,
    input logic [11:0] Guess,
    input logic [2:0] LoadShape,
    input logic [1:0] ShapeLocation,
    input logic LoadShapeNow, debug,
    output logic [3:0] Znarly, Zood, RoundNumber, NumGames,
    output logic [11:0] masterPattern, 
    output logic GameWon,
    output logic loadNumGames, loadGuess, loadZnarlyZood, displayMasterPattern);

    logic [1:0] credit;
    logic drop;
    logic game_cnt_en;
    logic R_C_en, R_C_clr, R_M_en, R_M_clr; // for buildMaster
    logic C_chk_clr; // for checkResult
    logic GameFinished; // for game counter
    logic LoadDone;

    fsm ctrl (.*);

    myAbstractFSM maf (.*);

    Counter game_cnt (.clock, .clear(reset), .en(game_cnt_en), .load(0), 
        .up(drop), .D(), .Q(NumGames));

    buildMaster bm (.*);

    Grader g (.*, .CLOCK_50(clock));

    checkResult check (.*);

endmodule: top