# TTSVoiceLibrary

## Available Voices

| Voice ID        | Gender | Accent / Notes                               | Characteristic Sound |
|-----------------|--------|----------------------------------------------|----------------------|
| `cmu_us_slt`    | Female | US English (Sue); flagship CMU SLT voice.    | Cleanest female option with clear articulation and stable prosody. |
| `cmu_us_rms`    | Male   | US English (RMS); companion to SLT.          | Strong male presence; steady pacing and clarity. |
| `cmu_us_bdl`    | Male   | US English; recorded with pro voice talent.  | Deep, resonant tone; good fallback when RMS feels too neutral. |
| `cmu_us_jmk`    | Male   | Canadian English.                            | Warm tone with softer consonants than RMS. |
| `cmu_us_rxr`    | Male   | US English.                                  | Slight nasal quality; prosody can sound a bit mechanical. |
| `cmu_us_axb`    | Male   | US English.                                  | Light, breathy delivery; more background noise, so a little grainier. |
| `cmu_us_awb`    | Male   | Scottish English.                            | Distinct Scots vowels; pick when you need a Scottish accent. |
| `cmu_us_aup`    | Male   | Australian English.                          | Noticeable Aussie diphthongs; intonation can be more erratic. |
| `cmu_us_gka`    | Male   | Indian English.                              | Clear speech with Indian English vowel reductions. |
| `cmu_us_ksp`    | Male   | Indian English (different speaker).          | Slightly huskier tone; light buzz in the output. |
| `cmu_us_aew`    | Female | US English.                                  | Smooth, slightly breathy; softer than SLT. |
| `cmu_us_eey`    | Female | US English.                                  | Bright, energetic; can accentuate sibilants. |
| `cmu_us_fem`    | Female | US English.                                  | Noticeable vibrato/nasal resonance; intelligible but less polished. |
| `cmu_us_ljm`    | Female | US English.                                  | Clear consonants with a touch of hiss; strong midrange presence. |

### Quick Recommendations

- **Highest fidelity**: `cmu_us_slt` (female) and `cmu_us_rms` (male).
- **Neutral alternates**: `cmu_us_bdl` (male) and `cmu_us_jmk` (male) if you want a different timbre without losing clarity.
- **Accent-specific**: use `cmu_us_awb` (Scottish), `cmu_us_aup` (Australian), `cmu_us_gka`/`cmu_us_ksp` (Indian) when you want those dialects.
- **Lower-polish options**: `cmu_us_fem`, `cmu_us_axb`, and `cmu_us_rxr` still work but expect more hiss or robotic phrasing compared to SLT/RMS.
