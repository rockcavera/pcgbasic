## Permuted Congruential Generator (PCG) Random Number Generation (RNG) for Nim.
##
## This implementation Nim was based on the minimal implementation written in C.
## More information: http://www.pcg-random.org/
## C implementation: https://github.com/imneme/pcg-c-basic
##
## Basic usage
## ===========
##
## .. code-block::
##
##   import pcgbasic, pcgbasic/utils
##
##   let seedseq = genSeeds()
##
##   var rng: Pcg32Random
##
##   # Start an rng
##   pcg32SRandomR(rng, seedseq.seed, seedseq.seq)
##
##   # Return a unit32
##   echo pcg32RandomR(rng)
##
##   # Pick a number between 0 and 99
##   echo pcg32BoundedRandR(rng, 100'u32)
##
##   # Roll a six-sided dice
##   echo pcg32BoundedRandR(rng, 6'u32) + 1

type
  Pcg32Random* = object
    state: uint64 # RNG state.  All values are possible.
    inc: uint64 # Controls which RNG sequence (stream) is selected. Must
                # *always* be odd.

# If you *must* statically initialize it, here's one.
let pcg32Initializer* = Pcg32Random(state: 0x853c49e6748fea9b'u64,
                                    inc: 0xda3e39cb94b95bdb'u64)

var pcg32Global = pcg32Initializer # state for global RNGs

# Operator unary minus
proc `-`(a: uint32): uint32 {.inline.} =
  not(a) + 1

{.push rangeChecks: off.}
proc pcg32RandomR*(rng: var Pcg32Random): uint32 {.discardable, inline.} =
  ## Generate a uniformly distributed 32-bit random number.
  let oldstate = rng.state

  rng.state = oldstate * 6364136223846793005'u64 + rng.inc

  let
    xorshifted: uint32 = uint32(((oldstate shr 18) xor oldstate) shr 27)
    rot: uint32 = uint32(oldstate shr 59)
  
  (xorshifted shr rot) or (xorshifted shl (-rot and 31))
{.pop.}

proc pcg32SRandomR*(rng: var Pcg32Random, initstate, initseq: uint64) =
  ## Seed the rng.  Specified in two parts, state initializer and a sequence
  ## selection constant (a.k.a. stream id).
  rng.state = 0
  rng.inc = (initseq shl 1) or 1
  pcg32RandomR(rng)
  rng.state += initstate
  pcg32RandomR(rng)

proc pcg32BoundedRandR*(rng: var Pcg32Random, bound: uint32): uint32 {.inline.} =
  ## Generate a uniformly distributed number, r, where 0 <= r < bound.
  let threshold: uint32 = -bound mod bound

  while true:
    let r = pcg32RandomR(rng)

    if r >= threshold:
      return r mod bound

proc pcg32SRandom*(seed, seq: uint64) =
  ## Same as pcg32SRandomR(), but using global RNG.
  pcg32SRandomR(pcg32Global, seed, seq)

proc pcg32Random*(): uint32 {.inline.} =
  ## Same as pcg32RandomR(), but using global RNG.
  pcg32RandomR(pcg32Global)

proc pcg32BoundedRand*(bound: uint32): uint32 {.inline.} =
  ## Same as pcg32BoundedRandR(), but using global RNG.
  pcg32BoundedRandR(pcg32Global, bound)