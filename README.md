# pcgbasic
Permuted Congruential Generator (PCG) Random Number Generation (RNG) for Nim.

This implementation Nim was based on the minimal implementation written in C.

More information: http://www.pcg-random.org/

C implementation: https://github.com/imneme/pcg-c-basic

# Install
Run the Nimble install command

``nimble install pcgbasic``

# Basic usage

```nim
import pcgbasic, pcgbasic/utils

let seedseq = genSeeds()

var rng: Pcg32Random

# Start an rng
pcg32SRandomR(rng, seedseq.seed, seedseq.seq)

# Return a unit32
echo pcg32RandomR(rng)

# Pick a number between 0 and 99
echo pcg32BoundedRandR(rng, 100'u32)

# Roll a six-sided dice
echo pcg32BoundedRandR(rng, 6'u32) + 1
```
