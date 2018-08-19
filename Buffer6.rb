# Algorave Tokyo 2018-08-19
#  Kenichi Kanai @kn1kn1
#
set_volume! 1.0
d9; use_bpm get_bpm; live_loop :l0 do use_bpm get_bpm; sync :d0; end
#

live_loop :l1 do
  stop
  gsl $sa5, 0.5, [0.012], [12], [0.25, 0.125]
  sleep 1
end

live_loop :l2 do
  stop
  gsl $sa1, 0.5, [0.008], [12], [0.25, 0.5, 0.125]
  sleep 3
end

live_loop :l3 do
  stop
  gsl $sa2, 1.0, [0.001], [12], [0.25, 0.5]
  sleep rrand 0.25, 0.5
end


live_loop :l4 do
  stop
  gsl $sa4, 0.5, [0.001], [12], [0.125, 0.25]
  sleep 1
end

live_loop :l5, sync: :l0 do
  hush
  stop
  ##| sleep 8
  with_pfx [2], [24] do
    ##| d1 #"pebbles/4", amp: 0.5, rate: "rand -2 -1"
    ##| d2 #"d(5,8,2)", slow: 4, n: "irand 0 1", amp: 0.3
    ##| d3 #"ade/4", n: "irand 0 1", amp: 0.1, rate: -1
    d1 "tech(11,16)", n: "irand 64", amp: 1, rate: 1, slow: 2
    d2 "sf(7,16,1)", n: "irand 64", amp: 0.8, rate: 1, slow: 2, pan: "rand -0.5, 0.5"
    d3 "peri(3,16,1)", n: "irand 64", amp: 0.8, rate: 1, slow: 2, pan: "rand -0.5, 0.5"
    d4 "perc(5,16,2)", n: "irand 64", amp: 0.8, rate: 1, slow: 2, pan: "rand -0.5, 0.5"
    d5 "jazz(3,16,1)", n: "irand 64", amp: 0.8, rate: 1, slow: 2, pan: "rand -0.5, 0.5"
    d6 "ul(3,16,1)", n: "irand 64", amp: 0.8, rate: 1, slow: 2, pan: "rand -0.5, 0.5"
    d7 :bd_haus, slow: 4
  end
  sleep 7
end

live_loop :l8 do
  use_bpm get_bpm / 4.0
  with_fx :reverb do
    ec2 0.2, [:e2, :b2, :e3, :b3]
  end
  stop
end

live_loop :l9 do
  use_bpm get_bpm / 2.0
  with_fx :echo do
    ec 0.2, [:e2, :b2, :e3]
  end
  stop
end

live_loop :l6, sync: :l0 do
  stop
  with_pfx do
    cl $sl4, 4, 1, 1.5, 8
  end
end

live_loop :l7, sync: :l0 do
  stop
  use_random_seed 2456
  with_pfx do
    ##| in_thread do
    ##|   bd 1
    ##|   sleep 0.5
    ##|   bd 1 if one_in(8)
    ##| end
    cln 1, :loop_amen, 1/8.0, 1.0, 1.0, 8, 4, !one_in(8), 32
  end
end
