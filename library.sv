`default_nettype none

// Takes in an variable width input (based on output width) 
// and an enable bit to enable a certain bit of the
// variable bit output. If not enabled, return all 0s
module Decoder
    #(parameter WIDTH = 8)
    (output logic [(WIDTH - 1):0] D,
     input logic [($clog2 (WIDTH) - 1):0] I, input logic en);
     
     always_comb begin
        D = 0;
        if (en) 
            D[I] = 1'b1;
     end

endmodule: Decoder

// Takes in 16 bit input and a 4 bit shift variable. Shifts the input left
// by the value given in "by"
module BarrelShifter
    (output logic [15:0] S,
     input logic [15:0] V, [3:0] by);
    
    assign S = V << by;

endmodule: BarrelShifter

// Takes in an variable width input and variable width selection vector 
// (based on input width). Returns I[S]
module Multiplexer
    #(parameter WIDTH = 8)
    (output logic Y,
     input logic [(WIDTH - 1):0] I, [($clog2 (WIDTH) - 1):0] S);
    
     assign Y = I[S];

endmodule: Multiplexer

// Given two variable bit inputs and a selection bit, this returns one of the 
// input vectors based on S
module Mux2to1
    #(parameter WIDTH = 7)
    (output logic [(WIDTH - 1):0] Y,
     input logic [(WIDTH - 1):0] I0, I1, input logic S);
    
     assign Y = S ? I1 : I0;

endmodule: Mux2to1

// Takes in two variable width inputs and returns their comparison -- 
// if they are equal in magnitude, A less than B, or A greater than B
module MagComp
    #(parameter WIDTH = 8)
    (output logic AltB, AeqB, AgtB,
     input logic [(WIDTH - 1):0] A, [(WIDTH - 1):0] B);
    
     assign AltB = (A < B);
     assign AeqB = (A === B);
     assign AgtB = (A > B);

endmodule: MagComp

// Takes in two variable width inputs and returns whether they are equal or not
module Comparator
    #(parameter WIDTH = 4)
    (output logic AeqB,
     input logic [(WIDTH - 1):0] A, [(WIDTH - 1):0] B);
    
    assign AeqB = (A === B);

endmodule: Comparator

// Takes in two variable width inputs and a carry in bit to return 
// the sum and the carry out bit
module Adder
    #(parameter WIDTH = 8)
    (output logic cout, output logic [(WIDTH - 1):0] sum,
     input logic [(WIDTH - 1):0] A, B, input logic cin);

    assign {cout, sum} = A + B + cin;

endmodule: Adder

// Takes in two variable width inputs and a borrow in bit to return the 
// difference and the borrow out bit
module Subtracter
    #(parameter WIDTH = 8)
    (output logic bout, output logic [(WIDTH - 1):0] diff,
    input logic [(WIDTH - 1):0] A, B, input logic bin);

    assign {bout, diff} = A - B - bin;

endmodule: Subtracter

// Stores a single bit with it being asynchronously set when preset_L is active
// and asynchronously cleared to 0 when reset_L is active
module DFlipFlop
    (output logic Q,
    input logic D, input logic clock, preset_L, reset_L);

    always_ff @(posedge clock, negedge preset_L, negedge reset_L)
        if (~reset_L && preset_L)
            Q <= 0;
        else begin
            if (~preset_L && reset_L)
                Q <= 1;
            else
                Q <= D;
                
        end

endmodule: DFlipFlop

// Stores a variable width vector with it being synchronously cleared when 
// clear is active and maintains the previous value when en is not asserted
module Register
    #(parameter WIDTH = 32)
    (output logic [(WIDTH - 1): 0] Q,
    input logic [(WIDTH - 1): 0] D, input logic clock, en, clear);

    always_ff @(posedge clock) begin
        if (en)
            Q <= D;
        else if (clear)
            Q <= 0;
    end

endmodule: Register

// Counting module that incremenets or decrements the input based on the
// value of up. Clear takes priority over load, which takes priority over
// counting/enable.
module Counter
    #(parameter WIDTH = 4)
    (input logic [(WIDTH - 1):0] D, input logic en, clear, load, up, clock,
    output logic [(WIDTH - 1):0] Q);

    always_ff @(posedge clock)
        if (clear)
            Q <= 0;
        else begin
            if (load)
                Q <= D;
            else begin
                if (en) begin
                    if (up)
                        Q <= Q + 1;
                    else 
                        Q <= Q - 1;
                end
            end
        end
        
endmodule: Counter


// The Synchronizer is the circuitry that protects an FSM or hardware thread 
// from an asynchronous input signal, which could be asserted at any time and 
// thus cause setup/hold violations or metastable situations. 
// The result is a signal synchronized to the local clock (the clock input).
module Synchronizer
    (input logic async, clock,
    output logic sync);

    logic ff_buf;
    always_ff @(posedge clock) begin
        ff_buf <= async;
        sync <= ff_buf;
    end

endmodule: Synchronizer

// The ShiftRegisterSIPO is a SIPO register that logically shifts either left 
// or right. It will consume the bit on the serial input and place it in either 
// the MSB or LSB position of the output. When not enabled, nothing will change.
module ShiftRegisterSIPO
    #(parameter WIDTH = 8)
    (input logic en, left, serial, clock,
    output logic [(WIDTH - 1):0] Q);

    always_ff @(posedge clock) 
        if (en) begin
            if (left)
                Q <= {serial, Q[(WIDTH - 2):0]};
            else
                Q <= {Q[(WIDTH - 1):1], serial};
        end
endmodule: ShiftRegisterSIPO

// The ShiftRegisterPIPO is a PIPO register that logically shifts either left 
// or right depending on the left control input. It only shifts when enabled 
// and load is not active.
module ShiftRegisterPIPO
    #(parameter WIDTH = 32)
    (input logic [(WIDTH - 1):0] D, input logic en, left, load, clock,
    output logic [(WIDTH - 1):0] Q);

    always_ff @(posedge clock) 
        if (load)
            Q <= D;
        else begin
            if (en) begin
                if (left)
                    Q <= D << 1;
                else
                    Q <= D >> 1;
            end
        end

endmodule: ShiftRegisterPIPO

// The BarrelShiftRegister is a PIPO register that shifts left. 
// It shifts left either 0, 1, 2 or 3 positions based on the 2-bit by input 
// (short for "shift by this amount"). It only shifts when
// enabled, of course. Load has priority over shifting.
module BarrelShiftRegister
    #(parameter WIDTH = 32)
    (input logic [(WIDTH - 1):0] D, input logic [1:0] by, 
    input logic en, load, clock,
    output logic [(WIDTH - 1):0] Q);

    always_ff @(posedge clock) 
        if (load)
            Q <= D;
        else begin
            if (en) 
                Q <= D << by;
        end

endmodule: BarrelShiftRegister

// The BusDriver is used to control access to a shared wire or bus. When enabled, 
// whatever value of data will be driven onto the bus, 
// otherwise the bus driver will not drive anything.
module BusDriver
    #(parameter WIDTH = 16)
    (input logic en, input logic [(WIDTH - 1):0] data,
    output logic [(WIDTH - 1):0] buff, bus);

    always_comb begin
        if (en)
            bus = data;
        else
            bus = 'bz;
    end

    always_comb
        buff = data;



endmodule: BusDriver

// The Memory is a combinational-read, synchronous-write memory, just like 
// we saw in Lecture 14.
module Memory
    #(parameter DW = 16, W = 256, AW = $clog2(W))
    (input logic re, we, clock, input logic [AW-1:0] addr,
    inout tri [DW-1:0] data);

    logic [DW-1:0] M[W];
    logic [DW-1:0] rData;

    assign data = (re) ? rData: 'bz;

    always_ff @(posedge clock)
        if (we)
            M[addr] <= data;

    always_comb
        rData = M[addr];

endmodule: Memory