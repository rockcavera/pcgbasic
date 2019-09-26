import times

proc genSeeds*(): tuple[seed, seq: uint64] =
  ## Generate a seed and seq for the RNG.
  let
    t = getTime()
    iTime = epochTime()

  var x: uint64 = 0
  
  while epochTime() == iTime: inc(x)

  ((x * 1_000_000_000'u64 + uint64(getTime().nanosecond)) * 65497'u64,
    uint64(convert(Seconds, Nanoseconds, t.toUnix) + t.nanosecond))