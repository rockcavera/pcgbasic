import strutils
import os
import pcgbasic, pcgbasic/utils

# Run the program with the "-r" parameter to use random seeds.

# Read command-line options
var 
  rounds = 5
  nondeterministicSeed = false

if paramCount() > 0:
  if paramStr(1) == "-r":
    nondeterministicSeed = true
  else:
    rounds = parseInt(paramStr(1))


# In this version of the code, we'll use a local rng, rather than the global one.
var rng: Pcg32Random

# You should *always* seed the RNG.  The usual time to do it is the point in
# time when you create RNG (typically at the beginning of the program).

# pcg32SRandomR takes two 64-bit constants (the initial state, and the rng
# sequence selector; rngs with different sequence selectors will *never* have
# random sequences that coincide, at all).

if nondeterministicSeed:
  # Random seeds.
  let entropy = genSeeds()
  pcg32SRandomR(rng, entropy.seed, entropy.seq)
else:
  # Seed with a fixed constant.
  pcg32SRandomR(rng, 42u64, 54u64)

echo("      -  result:      32-bit unsigned int (uint32)\n",
     "      -  period:      2^64   (* 2^63 streams)\n",
     "      -  state type:  Pcg32Random (", sizeof(Pcg32Random), " bytes)\n",
     "      -  output func: XSH-RR")

for round in 1 .. rounds:
  # Make some 32-bit numbers
  var text: seq[string] = @[]

  echo "Round ", round, ":"
  
  for i in 0 ..< 6:
    add(text, "0x" & toHex(pcg32RandomR(rng)))
  echo "  32bit: ", join(text, " ")

  # Toss some coins
  text = @[]

  for i in 0 ..< 65:
    if pcg32BoundedRandR(rng, 2u32) == 1:
      add(text, "H")
    else:
      add(text, "T")
  echo "  Coins: ", join(text, "")

  # Roll some dice
  text = @[]

  for i in 0 ..< 33:
    add(text, $(pcg32BoundedRandR(rng, 6u32) + 1))
  echo "  Rolls: ", join(text, " ")

  # Deal some cards
  text = @["  Cards:"]

  const
    SUITS = 4
    # NUMBERS = 13
    CARDS = 52
  
  var cards = newSeq[int](CARDS)

  for i in 0 ..< CARDS:
    cards[i] = i
  
  for i in countdown(CARDS, 2):
    let
      chosen = int(pcg32BoundedRandR(rng, uint32(i)))
      card = cards[chosen]
    
    cards[chosen] = cards[i - 1]
    cards[i - 1] = card
  
  let
    number = ['A', '2', '3', '4', '5', '6', '7', '8', '9', 'T', 'J', 'Q', 'K']
    suit = ['h', 'c', 'd', 's']

  for i in 0 ..< CARDS:
    add(text, number[cards[i] div SUITS] & suit[cards[i] mod SUITS])
    if (i + 1) mod 22 == 0:
      echo join(text, " ")
      text = @["        "]

  echo join(text, " ")