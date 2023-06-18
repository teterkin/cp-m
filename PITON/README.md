# PITON

> Snake like game

This program demostrates direct access to CP/M video memory (wich is located at absolute address `$f800`) using *Turbo Pascal 3.0* code.

Also it uses *Move* procedure in *MakeSpace* sub-program to in order to update video memory as fast as possible: in single operation.

Also it uses text file *piton.rec* (include Russian characters) to store table of records.

Game has 5 levels, you need to grow to that size of 100 meters to win. Each level encreese the speed of snake, but you have to grow the snake each level. My snake eat apples, not rabbits.
