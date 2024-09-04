`default_nettype none

/*
This abstract FSM builds upon the soda machine from Task 2 by adding three 
waiting states (one for each CoinValue input) for each credit state that wait 
until the asserted CoinValue is deasserted before moving to the next state. 
This allows the soda machine to work with circle/triangle/pentagon inputs 
remaining asserted over a random amount of clock edges. 

We decided to assert drop on these waiting states as well as the actual
credit states to ensure drop can be easily observed.
*/

module myAbstractFSM (
  output logic [1:0] credit,
  output logic drop,
  input logic [1:0] CoinValue,
  input logic clock, reset);

// Nomenclature - CRED{from credit}_{to credit}_{asserted CoinValue}
enum logic [5:0] {CRED0, CRED0_1_C, CRED0_3_T, CRED0_5_P, 
                  CRED1, CRED1_2_C, CRED1_4_T, CRED1_6_P,
                  CRED2, CRED2_3_C, CRED2_5_T, CRED2_7_P,
                  CRED3, CRED3_4_C, CRED3_6_T, CRED3_8_P,
                  CRED4, CRED4_1_C, CRED4_3_T, CRED4_5_P,
                  CRED5, CRED5_2_C, CRED5_4_T, CRED5_6_P,
                  CRED6, CRED6_3_C, CRED6_5_T, CRED6_7_P,
                  CRED7, CRED7_4_C, CRED7_6_T, CRED7_8_P,
                  CRED8, CRED8_1_C, CRED8_3_T, CRED8_5_P} currState, nextState;

always_comb begin
  // Assign a value to nextState based on input
  case (currState)
    CRED0: begin
      case (CoinValue)
        2'b01: nextState = CRED0_1_C;
        2'b10: nextState = CRED0_3_T;
        2'b11: nextState = CRED0_5_P;
        default: nextState = currState;
      endcase
    end

    CRED0_1_C: begin
      case (CoinValue)
        2'b01: nextState = currState;
        default: nextState = CRED1;
      endcase
    end

    CRED0_3_T: begin
      case (CoinValue)
        2'b10: nextState = currState;
        default: nextState = CRED3;
      endcase
    end

    CRED0_5_P: begin
      case (CoinValue)
        2'b11: nextState = currState;
        default: nextState = CRED5;
      endcase
    end

    CRED1: begin
      case (CoinValue)
        2'b01: nextState = CRED1_2_C;
        2'b10: nextState = CRED1_4_T;
        2'b11: nextState = CRED1_6_P;
        default: nextState = currState;
      endcase
    end
  
    CRED1_2_C: begin
      case (CoinValue)
        2'b01: nextState = currState;
        default: nextState = CRED2;
      endcase
    end

    CRED1_4_T: begin
      case (CoinValue)
        2'b10: nextState = currState;
        default: nextState = CRED4;
      endcase
    end

    CRED1_6_P: begin
      case (CoinValue)
        2'b11: nextState = currState;
        default: nextState = CRED6;
      endcase
    end

    CRED2: begin
      case (CoinValue)
        2'b01: nextState = CRED2_3_C;
        2'b10: nextState = CRED2_5_T;
        2'b11: nextState = CRED2_7_P;
        default: nextState = currState;
      endcase
    end

    CRED2_3_C: begin
      case (CoinValue)
        2'b01: nextState = currState;
        default: nextState = CRED3;
      endcase
    end

    CRED2_5_T: begin
      case (CoinValue)
        2'b10: nextState = currState;
        default: nextState = CRED5;
      endcase
    end

    CRED2_7_P: begin
      case (CoinValue)
        2'b11: nextState = currState;
        default: nextState = CRED7;
      endcase
    end


    CRED3: begin
      case (CoinValue)
        2'b01: nextState = CRED3_4_C;
        2'b10: nextState = CRED3_6_T;
        2'b11: nextState = CRED3_8_P;
        default: nextState = currState;
    endcase
    end

    CRED3_4_C: begin
      case (CoinValue)
        2'b01: nextState = currState;
        default: nextState = CRED4;
      endcase
    end

    CRED3_6_T: begin
      case (CoinValue)
        2'b10: nextState = currState;
        default: nextState = CRED6;
      endcase
    end

    CRED3_8_P: begin
      case (CoinValue)
        2'b11: nextState = currState;
        default: nextState = CRED8;
      endcase
    end
    
    CRED4: begin
      case (CoinValue)
        2'b01: nextState = CRED4_1_C;
        2'b10: nextState = CRED4_3_T;
        2'b11: nextState = CRED4_5_P;
        default: nextState = currState;
      endcase
    end

    CRED4_1_C: begin
      case (CoinValue)
        2'b01: nextState = currState;
        default: nextState = CRED1;
      endcase
    end

    CRED4_3_T: begin
      case (CoinValue)
        2'b10: nextState = currState;
        default: nextState = CRED3;
      endcase
    end

    CRED4_5_P: begin
      case (CoinValue)
        2'b11: nextState = currState;
        default: nextState = CRED5;
      endcase
    end

    CRED5: begin
      case (CoinValue)
        2'b01: nextState = CRED5_2_C;
        2'b10: nextState = CRED5_4_T;
        2'b11: nextState = CRED5_6_P;
        default: nextState = currState;
      endcase
    end

    CRED5_2_C: begin
      case (CoinValue)
        2'b01: nextState = currState;
        default: nextState = CRED2;
      endcase
    end

    CRED5_4_T: begin
      case (CoinValue)
        2'b10: nextState = currState;
        default: nextState = CRED4;
      endcase
    end

    CRED5_6_P: begin
      case (CoinValue)
        2'b11: nextState = currState;
        default: nextState = CRED6;
      endcase
    end

    CRED6: begin
        case (CoinValue)
        2'b01: nextState = CRED6_3_C;
        2'b10: nextState = CRED6_5_T;
        2'b11: nextState = CRED6_7_P;
        default: nextState = currState;
      endcase
    end

    CRED6_3_C: begin
      case (CoinValue)
        2'b01: nextState = currState;
        default: nextState = CRED3;
      endcase
    end

    CRED6_5_T: begin
      case (CoinValue)
        2'b10: nextState = currState;
        default: nextState = CRED5;
      endcase
    end

    CRED6_7_P: begin
      case (CoinValue)
        2'b11: nextState = currState;
        default: nextState = CRED7;
      endcase
    end

    CRED7: begin
        case (CoinValue)
        2'b01: nextState = CRED7_4_C;
        2'b10: nextState = CRED7_6_T;
        2'b11: nextState = CRED7_8_P;
        default: nextState = currState;
      endcase
    end

    CRED7_4_C: begin
      case (CoinValue)
        2'b01: nextState = currState;
        default: nextState = CRED4;
      endcase
    end

    CRED7_6_T: begin
      case (CoinValue)
        2'b10: nextState = currState;
        default: nextState = CRED6;
      endcase
    end

    CRED7_8_P: begin
      case (CoinValue)
        2'b11: nextState = currState;
        default: nextState = CRED8;
      endcase
    end

    CRED8: begin
        case (CoinValue)
        2'b01: nextState = CRED8_1_C;
        2'b10: nextState = CRED8_3_T;
        2'b11: nextState = CRED8_5_P;
        default: nextState = currState;
      endcase
    end
    
    CRED8_1_C: begin
      case (CoinValue)
        2'b01: nextState = currState;
        default: nextState = CRED1;
      endcase
    end

    CRED8_3_T: begin
      case (CoinValue)
        2'b10: nextState = currState;
        default: nextState = CRED3;
      endcase
    end

    CRED8_5_P: begin
      case (CoinValue)
        2'b11: nextState = currState;
        default: nextState = CRED5;
      endcase
    end

    default: begin
      nextState = currState;
    end
  endcase
end



// Output logic defined here. The waiting states have the same 
// output values as the states they are transitioning to i.e
// CRED2_3_C and CRED4_3_T both have the same drop and credit values
// as CRED3 (drop = 0 and credit = 3)
always_comb begin
  credit = 4'b0000; drop = 1'b0;
  unique case (currState)
    CRED0: begin 
      drop = 1'b0;
      credit = 4'b00;
    end



    CRED1: begin
      drop = 1'b0;
      credit = 4'b01;
    end 
    
    CRED0_1_C: begin
      drop = 1'b0;
      credit = 4'b01;
    end

    CRED4_1_C: begin
      drop = 1'b0;
      credit = 4'b01;
    end

    CRED8_1_C: begin
      drop = 1'b0;
      credit = 4'b01;
    end




    CRED2: begin
      drop = 1'b0;
      credit = 4'b10;
    end 
          
    CRED1_2_C: begin
      drop = 1'b0;
      credit = 4'b10;
    end 
    
    CRED5_2_C: begin
      drop = 1'b0;
      credit = 4'b10;
    end 
    


    
    CRED3: begin
      drop = 1'b0;
      credit = 4'b11;
    end   
    
    CRED0_3_T: begin
      drop = 1'b0;
      credit = 4'b11; 
    end   

    CRED2_3_C: begin
      drop = 1'b0;
      credit = 4'b11;
    end   

    CRED4_3_T: begin
      drop = 1'b0;
      credit = 4'b11;
    end   

    CRED6_3_C: begin
      drop = 1'b0;
      credit = 4'b11;
    end  
    
    CRED8_3_T: begin
      drop = 1'b0;
      credit = 4'b11;
    end   

    
  


    
    CRED4: begin
        drop = 1'b1;
        credit = 4'b00;
      end    

    CRED1_4_T: begin
        drop = 1'b1;
        credit = 4'b00;
      end      

    CRED3_4_C: begin
        drop = 1'b1;
        credit = 4'b00;
      end    
    
    CRED5_4_T: begin
        drop = 1'b1;
        credit = 4'b00;
      end    

    CRED7_4_C: begin
        drop = 1'b1;
        credit = 4'b00;
      end    




    CRED5: begin
        drop = 1'b1;
        credit = 4'b01;
    end   
    
    CRED0_5_P: begin 
        drop = 1'b1;
        credit = 4'b01;
    end
    
    CRED2_5_T: begin 
        drop = 1'b1;
        credit = 4'b01;
    end

    CRED4_5_P: begin 
        drop = 1'b1;
        credit = 4'b01;
    end

    CRED6_5_T: begin 
        drop = 1'b1;
        credit = 4'b01;
    end

    CRED8_5_P: begin 
      drop = 1'b1;
      credit = 4'b01;
    end




    CRED6: begin
          drop = 1'b1;
          credit = 4'b10;
       end   
       
    CRED1_6_P: begin
          drop = 1'b1;
          credit = 4'b10;
       end 

    CRED3_6_T: begin
          drop = 1'b1;
          credit = 4'b10;
       end
    CRED5_6_P: begin
          drop = 1'b1;
          credit = 4'b10;
       end  
  
    CRED7_6_T: begin
          drop = 1'b1;
          credit = 4'b10;
       end 




    CRED7: begin
          drop = 1'b1;
          credit = 4'b11;
       end   

    CRED2_7_P: begin
          drop = 1'b1;
          credit = 4'b11;
       end  

    CRED6_7_P: begin
          drop = 1'b1;
          credit = 4'b11;
       end



    CRED8: begin
          drop = 1'b1;
          credit = 4'b00;
        end   
    
    CRED3_8_P: begin
          drop = 1'b1;
          credit = 4'b00;
        end  

    CRED7_8_P: begin
          drop = 1'b1;
          credit = 4'b00;
        end 
  
  endcase
end

// Synchronous state update described here as an always_ff block.
// In essence, these are your flip flops that will hold the state
// This doesn't do anything interesting except to capture the new
// state value on each clock edge. Also, synchronous reset.
always_ff @(posedge clock)
  if (reset)
    currState <= CRED0; 
  else
    currState <= nextState;


endmodule: myAbstractFSM