import unittest
import pcgbasic

var rng: Pcg32Random

pcg32SRandomR(rng, 2019u64, 9102u64)

test "test proc pcg32RandomR() - local rng":
  check pcg32RandomR(rng) == 1168481923'u32
  check pcg32RandomR(rng) == 755420727'u32
  check pcg32RandomR(rng) == 1278129725'u32

test "test proc pcg32BoundedRandR() - local rng":
  check pcg32BoundedRandR(rng, 100'u32) == 63'u32
  check pcg32BoundedRandR(rng, 100'u32) == 16'u32
  check pcg32BoundedRandR(rng, 100'u32) == 61'u32

test "test proc pcg32Random() - global rng":
  check pcg32Random() == 355248013'u32
  check pcg32Random() == 41705475'u32
  check pcg32Random() == 3406281715'u32

test "test proc pcg32BoundedRand() - global rng":
  check pcg32BoundedRand(100'u32) == 10'u32
  check pcg32BoundedRand(100'u32) == 79'u32
  check pcg32BoundedRand(100'u32) == 48'u32