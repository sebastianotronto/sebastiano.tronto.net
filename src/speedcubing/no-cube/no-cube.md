# Solving a cube... without a cube

*In this page you can find the full text of a message I posted on the
[speedsolving forum](https://www.speedsolving.com/forum/threads/the-3x3x3-example-solve-thread.14345/page-273#post-1173067)
in 2016. It is the explanation of how I managed to write down a solution
for a 3x3x3 Rubik's Cube scramble using just pen an paper, without
a cube.*

**Scramble**: B R2 B2 R' U2 R2 D2 L B2 F2 R2 D R' U' R U' L2 R D2 B'

For this scramble, I have tried something I have had in my mind for
quite a long time.  I have found this solution without using any cube
(physical nor simulator).  As I would do in a blind solve, I solved edges
and corners separately with commutators.  First, I tracked every edge
to see the permutation cycle (and check if there were any flipped). This
was easier than I had thought.  I have found this.

(UR BU DR FL LB FR BD DF UF UL)(DL RB)

Now I use commutators to "solve" these cycles. Actually I "copy" these
cycle, so I am matching the scramble instead of solving it. No big deal,
I just have to invert the final solution to get one for this scramble.
The easiest way would be to just do a blind solve, but I struggled
I little bit to save moves, in order to see if I could get under the
80HTM limit for a legal FMC solve.  I could break the first big cycle
into 3-cycles in any order, and I choose this one. There are probably
better ways to solve edges, but I didn't want to think to much about it.

(A) (UF UL UR) = [F2 U: M', U2] = F2 U R' L F2 R L' U F2  
(B) (UF BU DR) = [M', B' R B] = R' L U' R' U R L' B' R B  
\(C\) (UF FL LB) = [L' U L, E] = L' U L U D' B' U' B U' D  
(D) (UF FR BD) = [U2: M, U R U'] = U2 R L' B R B' R' L U R' U

Then I solve the 2-2 cycle left.

(E) (UF DF)(DL RB) = [U B U': (L2 F2)3] = U B U' L2 F2 L2 F2 L2 F2 U B' U'

Same thing for corners. One was twisted, so I use a different notation
for the permutation.

UBL->BLU
UFL->LFD->DBR->UFR->RFD->LBD->URB->FUL

(1) (UBL UFL LFD) = [U', L D L] = U' L D L' U L D' L'  
(2) (URB FUL UBL) = [F R' F', L] = F R' F' L F R F' L'  
(3) (UFR RFD LBD) = [R U R', D2] = R U R' D2 R U' R' D2  
(4) (DBR UFR URB) = [D: B2, D F2 D'] = D B2 D F2 D' B2 D F2 D2

Now I can use this commutators in any order, as long as the relative
order of the pieces of the same kind remains the same (i.e. I cannot use
(2) before (1), but I can do either (A) (B) (1), (A) (1) (B), (1) (A)
(B)). To cancel more moves, I used this order:

(1) (A) (2) (B) \(C\) (D) (E) (3) (4)

At this point I checked the solution on my cube and it was extremely
satisfactory to see everything going as I expected :) Inverting and
cancelling gives the following solution:

D2 F2 D' B2 D F2 D' B2 D R U R' D2 R U' R' U B U' F2  
L2 F2 L2 F2 L2 U B' U2 R U' L' R B R' B' L R' U' D' B'  
U B D U' L' U' L B' R' B L R' U' R U R F R' F' L'  
F R F U' L R' F2 L' R U' F2 L D L' U' L D' L' U

alg.cubing.net

79 HTM, just under the limit :) There are many ways to improve this
"method", but I just wanted a success, and I am satisfied with the result.
