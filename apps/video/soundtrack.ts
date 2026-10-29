/**
 * Writes the soundtrack into public/soundtrack.wav: a slow pad of sine chords under the whole
 * video, and a sonar ping with its echoes wherever the timeline has one. Run with `pnpm soundtrack`.
 */
import { writeFile } from "node:fs/promises";
import { duration, pings, type Scene, starts } from "./src/timeline.ts";

const rate = 48_000;
const length = Math.ceil(duration * rate);
const left = new Float32Array(length);
const right = new Float32Array(length);

// A minor, F major, C major and E minor, each held 8 seconds and crossfaded over 3.
const chords = [
  [110, 164.81, 246.94, 261.63],
  [87.31, 130.81, 164.81, 220],
  [130.81, 196, 293.66, 329.63],
  [82.41, 123.47, 146.83, 196],
];
const hold = 8;
const crossfade = 3;

function chordLevel(chord: number, time: number): number {
  const cycle = hold * chords.length;
  const start = chord * hold;
  // The distance from the chord's own stretch of the cycle, in seconds, looping round.
  const offset = (((time - start) % cycle) + cycle) % cycle;
  if (offset < hold) return 1;
  if (offset < hold + crossfade) return 1 - (offset - hold) / crossfade;
  if (offset > cycle - crossfade) return (offset - (cycle - crossfade)) / crossfade;
  return 0;
}

for (let i = 0; i < length; i++) {
  const time = i / rate;
  let l = 0;
  let r = 0;
  chords.forEach((chord, c) => {
    const level = chordLevel(c, time);
    if (level === 0) return;
    chord.forEach((frequency, v) => {
      const swell = 0.75 + 0.25 * Math.sin(2 * Math.PI * (0.06 + 0.017 * v) * time + v * 1.7);
      const tone =
        Math.sin(2 * Math.PI * frequency * time) +
        Math.sin(2 * Math.PI * frequency * 1.003 * time + v) +
        0.12 * Math.sin(2 * Math.PI * frequency * 2 * time + 0.5 * v);
      const pan = 0.5 + (v - 1.5) * 0.18;
      const sample = (level * swell * tone) / (v === 0 ? 1.4 : 1);
      l += sample * (1 - pan);
      r += sample * pan;
    });
  });
  const fade = Math.min(1, time / 3, (duration - time) / 4);
  left[i] = l * fade * 0.11;
  right[i] = r * fade * 0.11;
}

/** A ping at `at` seconds, `gain` loud, leaning to `pan` (0 left, 1 right). */
function ping(at: number, gain: number, pan: number) {
  const start = Math.round(at * rate);
  const end = Math.min(length, start + 3 * rate);
  for (let i = start; i < end; i++) {
    const t = (i - start) / rate;
    const envelope = Math.min(1, t / 0.004) * Math.exp(-t / 0.45);
    const sample =
      gain *
      envelope *
      (Math.sin(2 * Math.PI * 1318.5 * t) +
        0.3 * Math.sin(2 * Math.PI * 659.25 * t) * Math.exp(-t / 0.2) +
        0.12 * Math.sin(2 * Math.PI * 2637 * t) * Math.exp(-t / 0.15));
    left[i] += sample * (1 - pan);
    right[i] += sample * pan;
  }
}

const at = starts();
for (const [scene, times] of Object.entries(pings) as [Scene, number[]][]) {
  for (const time of times) {
    ping(at[scene] + time, 0.4, 0.5);
    ping(at[scene] + time + 0.38, 0.15, 0.25);
    ping(at[scene] + time + 0.76, 0.06, 0.75);
  }
}

const data = Buffer.alloc(length * 4);
for (let i = 0; i < length; i++) {
  const clip = (value: number) => Math.max(-1, Math.min(1, value)) * 32767;
  data.writeInt16LE(clip(left[i] ?? 0), i * 4);
  data.writeInt16LE(clip(right[i] ?? 0), i * 4 + 2);
}
const header = Buffer.alloc(44);
header.write("RIFF", 0);
header.writeUInt32LE(36 + data.length, 4);
header.write("WAVEfmt ", 8);
header.writeUInt32LE(16, 16);
header.writeUInt16LE(1, 20);
header.writeUInt16LE(2, 22);
header.writeUInt32LE(rate, 24);
header.writeUInt32LE(rate * 4, 28);
header.writeUInt16LE(4, 32);
header.writeUInt16LE(16, 34);
header.write("data", 36);
header.writeUInt32LE(data.length, 40);
await writeFile(new URL("public/soundtrack.wav", import.meta.url), Buffer.concat([header, data]));
