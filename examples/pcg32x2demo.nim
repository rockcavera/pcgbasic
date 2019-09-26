import strutils
import os
import pcgbasic, pcgbasic/utils

# Run the program with the "-r" parameter to use random seeds.

# This code shows how you can cope if you're on a 32-bit platform (or a 64-bit
# platform with a mediocre compiler) that doesn't support 128-bit math, or if
# you're using the basic version of the library which only provides 32-bit
# generation.

# Here we build a 64-bit generator by tying together two 32-bit generators. Note
# that we can do this because we set up the generators so that each 32-bit
# generator has a *totally different* different output sequence -- if you tied
# together two identical generators, that wouldn't be nearly as good.

# For simplicity, we keep the period fixed at 2^64.  The state space is
# approximately 2^254 (actually  2^642^642^63(2^63 - 1)), which is huge.

proc `-`(a: uint64): uint64 {.inline.} =
  not(a) + 1

type
  Pcg32x2Random = object
    gen: array[2, Pcg32Random]

proc pcg32x2RandomR(rng: var Pcg32x2Random): uint64 =
  (uint64(pcg32RandomR(rng.gen[0])) shl 32) or pcg32RandomR(rng.gen[1])

proc pcg32x2SRandomR(rng: var Pcg32x2Random, seed1, seed2, seq1, seq2: uint64):
                    void =
  var seq2x = seq2
  let mask: uint64 = not(0'u64) shr 1

  # The stream for each of the two generators *must* be distinct
  if (seq1 and mask) == (seq2x and mask):
    seq2x = not(seq2x)
  
  pcg32SRandomR(rng.gen[0], seed1, seq1)
  pcg32SRandomR(rng.gen[1], seed2, seq2x)

# See other definitons of ...BoundedRandR for an explanation of this code.

proc pcg32x2BoundedRandR(rng: var Pcg32x2Random, bound: uint64): uint64 =
  let threshold: uint64 = -bound mod bound

  while true:
    let r = pcg32x2RandomR(rng)

    if r >= threshold:
      return r mod bound

# Read command-line options

var 
  rounds = 5
  nondeterministicSeed = false

if paramCount() > 0:
  if paramStr(1) == "-r":
    nondeterministicSeed = true
  else:
    rounds = parseInt(paramStr(1))

# In this version of the code, we'll use our custom rng rather than one of the
# provided ones.
var rng: Pcg32x2Random

# You should *always* seed the RNG.  The usual time to do it is the point in
# time when you create RNG (typically at the beginning of the program).

# Pcg32x2SRandomR takes four 64-bit constants (the initial state, and the rng
# sequence selector; rngs with different sequence selectors will *never* have
# random sequences that coincide, at all)

if nondeterministicSeed:
  # Random seeds.
  let
    entropy = genSeeds()
    entropy2 = genSeeds()
  pcg32x2SRandomR(rng, entropy.seed, not(entropy2.seed), entropy.seq, entropy2.seq)
else:
  # Seed with a fixed constant
  pcg32x2SRandomR(rng, 42u64, 42u64, 54u64, 54u64)

echo("      -  result:      64-bit unsigned int (uint64_t)\n",
     "      -  period:      2^64   (* ~2^126 streams)\n",
     "      -  state space: ~2^254\n      -  state type:  pcg32x2_random_t (",
     sizeof(Pcg32x2Random), " bytes)\n",
     "      -  output func: XSH-RR (x 2)\n")

for round in 1 .. rounds:
  # Make some 64-bit numbers
  var text: seq[string] = @[]

  echo "Round ", round, ":"
  
  for i in 0 ..< 6:
    add(text, "0x" & toHex(pcg32x2RandomR(rng)))
  echo "  64bit: ", join(text, " ")

  # Toss some coins
  text = @[]

  for i in 0 ..< 65:
    if pcg32x2BoundedRandR(rng, 2u64) == 1:
      add(text, "H")
    else:
      add(text, "T")
  echo "  Coins: ", join(text, "")

  # Roll some dice
  text = @[]

  for i in 0 ..< 33:
    add(text, $(pcg32x2BoundedRandR(rng, 6u64) + 1))
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
      chosen = int(pcg32x2BoundedRandR(rng, uint32(i)))
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