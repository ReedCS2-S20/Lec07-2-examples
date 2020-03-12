##CSCI 221 S20
###Lec 07-2

This contains supplemental materials and information for Wednesday's
lecture to help you prepare for Thursday's lab programming in MIPS32
assembly. The top part of this page gives the circuit and design of a
simple programmable processor, the MINICS2, that was invented for
teaching this class.  We focus on the instructions that make up
the programs that it can execute, and there is one sample program
that can be loaded and run on it.

The second part gives a brief overview of the MIPS32 processor, mostly
pointing out the differences between it and the MINICS32.  It also
gives a sample program and some downloads for tomorrow's lab.


Instruction set for the MINICS2 computer
---

* [MINICS2.circ](MININCS2.circ): LogiSim circuit for the MINICS2 processor
* [sum1to3.dat](sum1to3.dat): sample ROM image

Below is an assembly/machine language that can be used to program the
MINICS2 computer. That computer has eight 8-bit instructions that
operate on four 4-bit registers named R0, R1, R2, and R3.  All
operations operate on the registers. Below I give a summary of all the
instructions as a table of their byte codes. Since a byte code is made
up of 8 bits, there are 256 different instructions possible.

For example, to set the register R2's value to the value 7, the
instruction you use has the byte code `00100111`. The first two bits
`00` describe which kind of operation it is ("load the register with
an *immediate* value"), the next two bits `10` describe which register
is being changed (the register R2), and the last four bits `0111`
describe the value that it should be changed to (the value 7).
You can think of `00100111` as the instruction

    LI $R2,7

This stands for "load immediate" and it has the meaning

    R2 := 7

Load immediate is one of a family of instruction types. You can also
perform an addition or a subtraction of two registers' values,
compare two registers' values to see if one is equal or less than
another, and jump (or "branch") to some other instruction
conditionally, based on the result of a comparison. So, for example,
the byte code `01110001` is for the instruction

    ADDU $R3, $R0, $R1

which means

    R3 := R0 + R1

This is because the first two bits are `01` to indicate the instruction
type (`ADDU`), and the next three pairs of bits indicate which three
registers are being operated on. `11` is the "destination register"
R3. `00` and `01` indicate the addition's two "source registers" R0 and R1.

The comparison instruction

    CMP $R3,$R2

performs a subtraction of R2 from R3. Rather than store that result,
instead the processor records whether the result of that subtraction
was zero, or was negative. There are two additional "condition code" 
registers, each storing only one bit. The bit `Z` condition code
is set to `1` if the result of the comparison's subtraction is 0.
That would happen if R3 and R2 held the same value.  The bit `Z1
condition code is set to `1` id the result of the comparison's 
subtraction is negative. That would happen iof R3 is less than 
R2.

Programs are laid out as a series of consecutive instructions in
memory. The processor starts at the 0th instruction, executes it, then
runs the 1st instruction, then the 2nd, and so forth. The processor
keeps track of which instruction it is executing with something called
the "instruction pointer" or "program counter" (abbreviated `IP` or
`PC`). You can think of this as an address. Since instructions for
the MINICS2 are just 1 byte long, then the program counter is
simply executed by 1 so as to run through each of the instructions
in order. (Were they 32-bit instructions, the `PC` would instead be
incremented by 4.)

You can use "branch" instructions to "jump: to another instruction.
This is how you mimic `if` statements and `while` loops in MINICS2.
If your program jumps back to an earlier instruction, one that was
executed earlier, then your program is looping. If it skips a
series of instructions, jumping ahead, then this is like an `if`
where the "then" was skipped.

These jumps can be perfomed conditionally.  The `BCCZ` instruction
makes the processor jump to some other instruction, but only if the
`Z` condition was set. If `Z` is not set, then the processor just
executes the next instruction. It does not jump to that other "target"
instruction.  The `BCCN` does the same if `N` is set. The `B`
instruction jumps to another instruction, regardless of the condition
code registers' values. It's an unconditional branch.

The target instruction of a jump/branch instruction is specified by
an offset.  For example

    BCCZ +3

tells the processor to next run the instruction specified three bytes 
below the next instruction. But only if your last comparison found
that the two register's held the same value. The possibility of 
going to the next instruction, or instead three beyond it, based
on a condition, is why that instruction is called a "branch within
the program." There are two different ways the processor could go.

The instruction

    B -1

tells it to just stay at that same instruction, run it again. (You
can think of it as a halt/stop instruction.)

Programs are loaded into the MINICS2 "read only" instruction
memory (an instruction ROM) and then executed, starting at the
instruction at line 0.

The complete set of MINICS2 instructions is summarized below:

    instruction, mnemonic  ||i76|i54|i32|i10|| meaning
    -----------------------++---+---+---+---++---------     
    load immediate  | LI   || 00| Rz| vH  vL|| Rz := v
    add (untrapped) | ADDU || 01| Rz| Rx| Ry|| Rz := Rx + Ry
    subtract (untrp)| SUBU || 10| Rz| Rx| Ry|| Rz := Rx - Ry
    -----------------------++---+---+---+---||
    compare (set CC)| CMP  || 11  00| Rx| Ry|| CC := NZ(Rx - Ry)
    -----------------------++---+---+---+---||
    branch if neg   | BCCN || 11  01| oH  oL|| if N(CC): PC := PC + o
    branch if zero  | BCCZ || 11  10| oH  oL|| if Z(CC): PC := PC + o 
    branch          | B    || 11  11| oH  oL|| PC := PC + o 
    -----------------------++---+---+---+---||---------     

Below is a sample MINICS2 program that loops, summing the values 1+2+3.
It uses R0 to keep track of the sum, and R2 as a count. R3 is used
to keep track of the last count (the value 3). We need an extra R1
set to 1 in order to increment the counter.

    #
    # A MINICS2 assembly program that sums 1+2+3, storing
    # the result in register $R0.
    #
    L0: LI   $R0, $0        # sum = 0
    L1: LI   $R1, $1        # inc = 1
    L2: LI   $R2, $0        # count = 0
    L3: LI   $R3, $3        # last = 3
    L4: CMP  $R3, $R2       # if last - count == 0 go to L9
    L5: BCCZ +3             # 
    L6: ADDU $R2, $R2, $R1  # count += inc
    L7: ADDU $R0, $R0, $R2  # sum += count
    L8: B    -5             # go to L4
    L9: B    -1             # go to L9


Here is that same program's code, assembled as a sequence of bytes
to be stored in the "instruction ROM memory", or "I-memory":

    L#   bits        | hex value
    0x0: 00 00 00 00 | 00
    0x1: 00 01 00 01 | 11
    0x2: 00 10 00 00 | 20
    0x3: 00 11 00 11 | 33
    0x4: 11 00 11 10 | CE
    0x5: 11 10 00 11 | E3
    0x6: 01 10 10 01 | 69
    0x7: 01 00 00 10 | 42
    0x8: 11 11 10 11 | FB
    0x9: 11 11 11 11 | FF

You can run this program on a MINICS2 processor implemented as a LogiSim circuit.
Here are some files to do that:

* [MINICS2.circ](MININCS2.circ): the circuit for the processor
* [sum1to3.dat](sum1to3.dat): the ROM image that can be loaded into I-memory

These programs are called "assembly programs" because, traditionally,
the (somewhat) human-readable code we wrote (using `LI`, `ADDU`, etc.)
would be "assembled" by a tool that converted our program's text into
the byte code sequence so that they could then be "imaged" into the
instruction memory. An "assembler" assembles your program instruction
into a sequence of bytes.

It's normal in assembly programs to not number every line of the
program. Instead, you put "labels" above lines of code that might be
targets of jumps, or generally to organize the code and make its
structure more readable. The code below labels three lines: `MAIN` is
the first instruction of the program, `END` is the last instruction of
the program, and `LOOP` is the terget line we jump back to so as to
repeat the activity of the summing loop.

    #
    # A MINICS2 assembly program that sums 1+2+3, storing
    # the result in register $R0.
    #
    MAIN:
        LI   $R0, $0        # sum = 0
        LI   $R1, $1        # inc = 1
        LI   $R2, $0        # count = 0
        LI   $R3, $3        # last = 3

    LOOP:
        CMP  $R3, $R2       # if last - count == 0 go to END
        BCCZ END             # 
        ADDU $R2, $R2, $R1  # count += inc
        ADDU $R0, $R0, $R2  # sum += count
        B    LOOP           # go to LOOP

    END:
        B    END             # go to END


MIPS32 assembly programming
---

In lab tomorrow we'll work together writing programs for a different
processor family named **MIPS32**. This has a larger set of
instructions, the instructions' codes are wider, they can access more
registers, and the registers hold larger values. Instructions are
32-bits wide. There are 32 integer registers and each holds 32 bits of
data. It also has several other condition code registers and also
registers that store floating point values. 

For the most part, programming a MIPS32 is similar to what you saw
with the MINICS2 just above.  The biggest difference is that the
registers are divided up and named for different kinds of uses, and
these names/uses are taken by convention.  Some of these are reserved
for use by the system, not to be used by the programmer. The registers
are `v0`, `v1`, `a0-a3`, `t0-t9`, `s0-s7`, `gp`, `sp`, `fp`, and
`ra`. For now, we'll only use `t0-t9` in our programs, with some
others used when following specific conventions for specific other
instructions.

We'll also be able to define functions and procedures, just as we did
in C++. Here, for example, is a `main` procedure that loops and
sums of the values from 1 to 100. It tracks that sum in register
`t0`:

    	.globl main
    	.text
    
    main:
    	li	$t0, 0		# sum = 0    
    	li	$t1, 1		# inc = 1    
    	li	$t2, 0          # count = 0  
    	li 	$t3, 100        # last = 100 
    loop:	
    	beq	$t3, $t2, done  # if last == count goto done    
    	addu	$t2, $t2, $t1   # count += inc
    	addu	$t0, $t0, $t2   # sum += count
    	b	loop
    
    done:	
    	li	$v0, 0		# return 0
    	jr	$ra		#

We won't have direct access to a MIPS32 processor, nor do we have a
LogiSim circuit for it.  Instead we will run MIPS32 programs using a
simulator named SPIM. Tomorrow's lab will ask you to download,
compile, and install the SPIM command-line tool. We'll then work to
write a few MIPS32 programs.


