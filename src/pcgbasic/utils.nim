import std/times

proc genSeeds*(): tuple[seed, seq: uint64] =
  ## Generate a seed and seq for the RNG.
  let
    t = getTime()
    s = uint64(toUnix(t))
    n = uint64(nanosecond(t))
    seed = s xor n

  result.seed = seed xor ((seed shl 48'i32) or (seed shr 16'i32))
  result.seq = seed * 65497'u64
