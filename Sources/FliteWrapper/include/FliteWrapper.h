#pragma once
#ifdef __cplusplus
extern "C" {
#endif

#include "Flite.h"

/// Initialize the embedded Flite runtime (`flite_init`).
///
/// Call exactly once near process startup before invoking other Flite entry
/// points. The underlying initializer configures global allocators, audio
/// backends, logging, and registry structures, but it does *not* load any
/// languages or voices. Follow up with language/voice registration helpers such
/// as `flitew_register_eng_lang` and `flitew_add_voice` prior to synthesis.
void flitew_init(void);

/// Print the voices currently registered in Flite's global list.
///
/// Traverses `flite_voice_list` and logs each entry’s name feature. Useful when
/// validating that calls to `flitew_add_voice` (or other registration paths) are
/// completing as expected. Intended for diagnostics; thread-safety matches the
/// underlying global list (read safely after registration settles).
void flitew_print_voices(void);

/// Register the CMU English language/lexicon pair with Flite.
///
/// Wraps `flite_add_lang("eng", usenglish_init, cmulex_init)` so `.flitevox`
/// models produced for CMU English can resolve their language hooks and
/// dictionary lookups. Safe to call more than once; additional calls simply
/// return the existing registration.
void flitew_register_eng_lang(void);

/// Load a serialized `.flitevox` voice via `flite_voice_load`.
///
/// Requires that the target language/lexicon (e.g., `eng`) has been registered
/// beforehand. On success the returned voice owns heap allocations that remain
/// valid until the process ends or the caller explicitly deletes the voice via
/// core Flite APIs. Call `flitew_add_voice` if you need the voice discoverable by
/// name.
/// - Parameter path: UTF-8 encoded filesystem path to the `.flitevox` file.
/// - Returns: Newly constructed `cst_voice` pointer, or `NULL` if the file
///   cannot be opened, parsed, or validated.
cst_voice *flitew_voice_load(const char *path);

/// Register a voice in Flite's global registry (`flite_add_voice`).
///
/// The global registry enables lookups by symbolic name (`flite_voice_select`)
/// and populates `flite_voice_list`. Flite's own guidance is to add voices up
/// front—before concurrent synthesis begins—because the registry is not designed
/// for multi-threaded mutation. This wrapper first scans the existing registry
/// and skips insertion when a voice with the same `name` feature is already
/// present (falling back to pointer comparison only if the name is absent).
/// - Parameter voice: Voice pointer produced by `flitew_voice_load` or another
///   constructor. Passing `NULL` is ignored.
void flitew_add_voice(cst_voice *voice);

/// Synthesize text to mono 16-bit PCM using `flite_text_to_wave`.
///
/// Internally performs a blocking synthesis, copies the resulting `cst_wave`
/// data into a freshly `malloc`'d buffer, and returns ownership to the caller.
/// Most Flite voices emit 22050 Hz single-channel audio, but the actual rate is
/// voice-dependent. The wrapper surfaces coarse error codes: `1` for invalid
/// arguments, `2` when synthesis fails, `3` for malformed wave metadata, and `4`
/// when memory allocation fails.
/// - Parameters:
///   - text: UTF-8 encoded string to synthesize.
///   - voice: Voice handle obtained from `flitew_voice_load` (must stay alive for
///     the duration of the call).
///   - out_samples: Receives the allocated buffer of signed 16-bit samples (mono).
///   - out_sample_count: Receives the number of samples in `out_samples`.
///   - out_sample_rate: Receives the sample rate, in Hz, associated with the buffer.
/// - Returns: `0` on success; non-zero error code if synthesis or allocation fails.
int flitew_text_to_pcm(const char *text,
                       cst_voice *voice,
                       short **out_samples,
                       int *out_sample_count,
                       int *out_sample_rate);

/// Release PCM buffers produced by `flitew_text_to_pcm`.
///
/// Simply forwards to `free`. Always pair successful synthesis calls with a
/// matching release once playback or processing completes.
/// - Parameter p: Buffer to release. `NULL` is accepted and ignored.
void flitew_free_pcm(short *p);

//int flitew_say(const char *text,
//               float rate_multiplier,
//               float pitch_shift_semitones,
//               short **out_samples,
//               int *out_num_samples,
//               int *out_sample_rate);
//void flitew_free(short *samples);
//
//void flitew_set_feature_float(const char *key, float value);
//void flitew_set_feature_int(const char *key, int value);
//void flitew_set_feature_string(const char *key, const char *value);
//void flitew_set_prosody(float rate, float basePitchHz, float pitchVarHz);

#ifdef __cplusplus
}
#endif
