load "~/github/petal/petal.rb"

cps 1.0
d9
$spc = get_seconds_per_cycle

use_bpm get_bpm

live_loop :l0 do
  use_bpm get_bpm
  sync :d0
end

$sa1 = :ambi_choir
$sa2 = :ambi_piano
$sa3 = dirt_sample("ade",7)
$sa4 = dirt_sample("ade",8)
$sa5 = :ambi_drone

$sg5 = :guit_e_fifths
$sg9 = :guit_em9

$sb1 = dirt_sample("pebbles",0)
$sb2 = :loop_3d_printer
$sb3 = dirt_sample("ade",1)
$sb4 = dirt_sample("ade",3)

$sl2 = :loop_breakbeat
$sl3 = :loop_amen_full
$sl4 = :loop_mehackit1

def ff(amp = 0.2, tonics = [:e3, :b3], num = 8, synth = :hollow)
  num.times do
    synth synth, amp: amp, note: scale(tonics.choose, :dorian, num_octaves: 2).choose, attack: [2, 3].choose
    sleep [1, 2].choose
  end
  sleep [1, 2].choose
end


def ec(amp = 0.2, tonics = [:b2, :e2], num = 8, synth = :saw)
  ##| def ec(amp = 0.05, synth = :beep, tonics = [:b2, :b4, :e2, :b4], num = 12)
  num.times do
    sleep [0.25, 0.5, 0.75, 1, 1.25].choose
    rnote = chord(tonics.choose, :M).choose
    rel = rrand(1.5, 3)
    synth synth, note: rnote,
      amp: amp * 0.1, pan: rrand(-0.2, 0.2),
      attack: 0.25, release: rel
  end
end

##| define :echoes do |num, tonics, co=100, res=0.9, amp=1|
##|   num.times do
##|     play chord(tonics.choose, :minor).choose, res: res, cutoff: rrand(co - 20, co + 20), amp: 0.5 * amp, attack: 0, release: rrand(0.5, 1.5), pan: rrand(-0.7, 0.7)
##|     sleep [0.25, 0.5, 0.5, 0.5, 1, 1].choose
##|   end
##| end

def ec2(amp = 0.2, tonics = [:e2], num = 4, synth = :fm)
  num.times do
    synth synth, note: chord(tonics.choose, [:m11, :m9, :major, :major7].choose),
      attack: [1, 0.75, 1.25, 1.5, 2].choose, cutoff: 80,
      amp: amp, pan: rrand(-0.2,0.2)
    sleep 1
  end
end

def gss(sample_name = :guit_e_fifths, amp = 0.05, window_size_list = [0.001, 0.005, 0.01],
        pitch_list = [12, 13, 14], rate_list = [pitch_to_ratio([5, 12].choose) * -1],
        pan = 1, s_end = 0.05, t_end = 0.3)
  gs(sample_name, amp, window_size_list, pitch_list, rate_list, pan, s_end, t_end)
end

def gsl(sample_name = :ambi_piano, amp = 0.1, window_size_list = [0.001, 0.005, 0.01],
        pitch_list = [12, 13, 14], rate_list = [pitch_to_ratio([-5, -12].choose) * -1],
        pan = 1, s_end = 0.1, t_end = 1.0)
  gs(sample_name, amp, window_size_list, pitch_list, rate_list, pan, s_end, t_end)
end

def gs(sample_name = :guit_e_fifths, amp = 0.05, window_size_list = [0.001],
       pitch_list = [12], rate_list = [-1], pan = 1, s_end = 0.2, t_end = 0.3)
  with_fx :reverb, room: 1 do
    32.times do
      s = rrand(0.0, s_end)
      t = rrand(0.02, t_end)
      e = s + t
      e = 1 if e > 1
      a = rrand(0.6, 1.0) * amp
      r = rate_list.choose
      pan = rrand(-1 * pan, pan)
      ws = window_size_list.choose
      ws = 0.000051 if ws <= 0.00005
      ps = pitch_list.choose
      ps = -72 if ps < -72
      ps = 24 if ps > 24
      rev = one_in(4) ? 1 : -1
      sample sample_name, pitch: ps, window_size: ws, amp: a, rate: r, start: s, finish: e, attack: t/2.0, decay: 0, sustain: 0, release: t/2.0, pan: pan
      sample sample_name, amp: a * 0.8, rate: rev * r, start: s, finish: e, attack: t/2.0, decay: 0, sustain: 0, release: t/2.0, pan: pan * -1
      sleep t / 2.0
    end
  end
end

def with_pfx(window_size_list = [0.001, 0.005, 0.01], pitch_list = [12])
  ws = window_size_list.choose
  ws = 0.000051 if ws <= 0.00005
  ps = pitch_list.choose
  ps = -72 if ps < -72
  ps = 24 if ps > 24
  with_fx :pitch_shift, pitch: ps, window_size: ws do
    with_fx :distortion do
      yield
    end
  end
end

def tt(amp = 0.2, pan = 0)
  lb :tri, 120, 0.125, 0.3 * amp, pan
end

def sd(amp = 0.2)
  with_fx :distortion do
    lb :saw, 100, 0.125, amp
  end
end

def bd(amp = 0.2)
  lb :beep, 35, 1, amp * 0.5
  lb :fm, 80, 0.125, amp * 1.0
end

def lb(synth, note, dur = 0.1, amp = 0.2, pan=0)
  use_synth synth
  pp = play note, amp: amp, pan: pan,
    release: dur, note_slide_shape: 7
  control pp, note: 12, note_slide: dur
end

def cl(loop_name, duration = 2, amp = 0.2, rate = 2.0,
       prob_chop = 2, prob_rev = 2,
       pick = true)
  if duration == 0
    dur = sample_duration(loop_name)
    rr = 1.0
  else
    dur = duration
    rr = sample_duration(loop_name) / duration
  end

  onsets = sample_buffer(loop_name).onset_slices
  onsets = onsets.shuffle if pick
  onsets.each do |onset|
    start = onset[:start]
    finish = onset[:finish]
    idx = onset[:index]
    s = dur * (finish - start)
    r =  (one_in(prob_rev) ? 1.0 : -1.0) * rate * rr

    in_thread do
      unless one_in(prob_chop)
        d = rrand_i(1, 4)
        sd = s / d
        d.times do
          sample loop_name, onset: idx, amp: 0.25 * amp, rate: r
          sleep sd
        end
      else
        sample loop_name, amp: 1.0 * amp, start: start, finish: finish, rate: r
      end
    end
    sleep s
  end
end

def cln(n, loop_name, duration = 2, amp = 0.2, rate = 2.0,
        prob_chop = 2, prob_rev = 2,
        pick = true, prob_deg = 16)
  onsets = line(0, 1, steps: n)
  if pick
    onsets = onsets.shuffle
  end
  sl = duration.to_f / n
  onsets.each do |onset|
    s = onsets.tick
    f = s + (1.0 / n)
    f = 1 if f > 1
    r =  (one_in(prob_rev) ? 1.0 : -1.0) * rate
    in_thread do
      unless one_in(prob_deg)
        unless one_in(prob_chop)
          d = rrand_i(1, 6)
          sd = sl / d
          f = s + (1.0 / (n * d))
          f = 1 if f > 1
          d.times do
            sample loop_name, rate: r, beat_stretch: duration, start: s, finish: f, amp: amp * 0.5
            sleep sd
          end
        else
          sample loop_name, rate: r, beat_stretch: duration, start: s, finish: f, amp: amp
        end
      end
    end
    sleep sl
  end
end
