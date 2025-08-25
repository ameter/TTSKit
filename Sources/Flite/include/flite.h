/*************************************************************************/
/*                                                                       */
/*                  Language Technologies Institute                      */
/*                     Carnegie Mellon University                        */
/*                        Copyright (c) 1999                             */
/*                        All Rights Reserved.                           */
/*                                                                       */
/*  Permission is hereby granted, free of charge, to use and distribute  */
/*  this software and its documentation without restriction, including   */
/*  without limitation the rights to use, copy, modify, merge, publish,  */
/*  distribute, sublicense, and/or sell copies of this work, and to      */
/*  permit persons to whom this work is furnished to do so, subject to   */
/*  the following conditions:                                            */
/*   1. The code must retain the above copyright notice, this list of    */
/*      conditions and the following disclaimer.                         */
/*   2. Any modifications must be clearly marked as such.                */
/*   3. Original authors' names are not deleted.                         */
/*   4. The authors' names are not used to endorse or promote products   */
/*      derived from this software without specific prior written        */
/*      permission.                                                      */
/*                                                                       */
/*  CARNEGIE MELLON UNIVERSITY AND THE CONTRIBUTORS TO THIS WORK         */
/*  DISCLAIM ALL WARRANTIES WITH REGARD TO THIS SOFTWARE, INCLUDING      */
/*  ALL IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS, IN NO EVENT   */
/*  SHALL CARNEGIE MELLON UNIVERSITY NOR THE CONTRIBUTORS BE LIABLE      */
/*  FOR ANY SPECIAL, INDIRECT OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES    */
/*  WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN   */
/*  AN ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION,          */
/*  ARISING OUT OF OR IN CONNECTION WITH THE USE OR PERFORMANCE OF       */
/*  THIS SOFTWARE.                                                       */
/*                                                                       */
/*************************************************************************/
/*             Author:  Alan W Black (awb@cs.cmu.edu)                    */
/*               Date:  December 1999                                    */
/*************************************************************************/
/*                                                                       */
/*  Light weight run-time speech synthesis system, public API            */
/*                                                                       */
/*************************************************************************/

// Many of the comments in this file were added by Chris Ameter in 2025.

#ifndef _FLITE_H__
#define _FLITE_H__

#ifdef __cplusplus
extern "C" {
#endif /* __cplusplus */

#include "cst_string.h"
#include "cst_regex.h"
#include "cst_val.h"
#include "cst_features.h"
#include "cst_item.h"
#include "cst_relation.h"
#include "cst_utterance.h"
#include "cst_wave.h"
#include "cst_track.h"

#include "cst_cart.h"
#include "cst_phoneset.h"
#include "cst_voice.h"
#include "cst_audio.h"

#include "cst_utt_utils.h"
#include "cst_lexicon.h"
#include "cst_synth.h"
#include "cst_units.h"
#include "cst_tokenstream.h"

#ifdef WIN32
/* For Visual Studio 2012 global variable definitions */
#define GLOBALVARDEF __declspec(dllexport)
#else
#define GLOBALVARDEF
#endif

/* NOTES
 • Always call flite_init() once at startup, and register the language/lexicon pair
   your voices need (e.g., eng with usenglish_init + cmulex_init) before flite_voice_load.
 
 • After flite_voice_load, call flite_add_voice(v) if you want the voice to
   appear in flite_voice_list / be found by flite_voice_select.
 
 • The outtype = "play" sink isn’t implemented for iOS; prefer flite_text_to_wave
   (or a small C shim that returns PCM) and play with AVAudioEngine.
 
 • The float result from the *_to_speech functions is the audio length in
   seconds (useful for timing/UI).
 */

/// Global registry of voices currently registered with Flite.
///
/// Each list node typically holds a voice-typed 'cst_val' (not a string) after calling
/// 'flite_add_voice(...)'. Some older builds may store strings. This list is consulted by
/// 'flite_voice_select(...)'. Not thread-safe for concurrent mutation.
extern GLOBALVARDEF cst_val *flite_voice_list;

/// Registry of available languages in this binary.
///
/// Each entry contains a short language code (e.g., "eng"), a language init hook,
/// and a lexicon factory. Populated via 'flite_add_lang(...)'. Bound by
/// 'flite_lang_list_length'.
extern GLOBALVARDEF cst_lang flite_lang_list[20];

/// Number of valid entries in 'flite_lang_list'.
extern GLOBALVARDEF int flite_lang_list_length;


// MARK: - Public functions

/// Initialize the Flite runtime.
///
/// Call this once early in app startup before using other Flite APIs. This sets up core
/// subsystems but does not register any languages or voices; add those explicitly via
/// 'flite_add_lang' and 'flite_add_voice'.
/// - Returns: 0 on success (some builds always return 0).
int flite_init();


// MARK: - General top level functions

/// Look up a registered voice by name.
///
/// - Parameters:
///   - name: The registered voice identifier (e.g., "cmu_us_kal16").
/// - Returns: A pointer to the registered 'cst_voice', or NULL if not found.
cst_voice *flite_voice_select(const char *name);

/// Load a serialized '.flitevox' model from disk and construct a 'cst_voice'.
///
/// Requires that the matching language and lexicon have been registered (e.g., for CMU
/// English voices call 'flite_add_lang("eng", usenglish_init, cmulex_init)' first).
/// Some builds do not auto-register the loaded voice; call 'flite_add_voice(v)' if you
/// want it selectable by name via 'flite_voice_select'.
/// - Parameters:
///   - voice_filename: UTF-8 path to a '.flitevox' file.
/// - Returns: The loaded voice pointer on success, or NULL on failure.
cst_voice *flite_voice_load(const char *voice_filename);

/// Serialize a compiled-in voice to a '.flitevox' file on disk.
///
/// - Parameters:
///   - voice: The voice object to serialize.
///   - voice_filename: Destination path for the file.
/// - Returns: 0 on success; non-zero on error.
int flite_voice_dump(cst_voice *voice, const char *voice_filename);

/// Synthesize speech from a text file using the given voice.
///
/// - Parameters:
///   - filename: Path to a UTF-8 encoded text file to read.
///   - voice: Voice to use for synthesis (must be loaded/registered).
///   - outtype: Output sink: "wav", "aiff", "raw", "none", or "play". On iOS, "play" is typically a no-op; prefer rendering to PCM and playing via AVAudioEngine.
/// - Returns: Approximate duration of generated audio in seconds.
float flite_file_to_speech(const char *filename,
                           cst_voice *voice,
                           const char *outtype);

/// Synthesize speech directly from a UTF-8 text string.
///
/// - Parameters:
///   - text: Input text to synthesize.
///   - voice: Voice to use for synthesis (must be loaded/registered).
///   - outtype: Output sink: "wav", "aiff", "raw", "none", or "play" (see iOS caveat above).
/// - Returns: Approximate duration of generated audio in seconds.
float flite_text_to_speech(const char *text,
                           cst_voice *voice,
                           const char *outtype);

/// Synthesize from a phoneme sequence instead of orthographic text.
///
/// - Parameters:
///   - text: Phone sequence (e.g., ARPAbet phones separated by spaces).
///   - voice: Voice to use for synthesis.
///   - outtype: Output sink ("wav", "aiff", "raw", "none", "play").
/// - Returns: Approximate duration of generated audio in seconds.
float flite_phones_to_speech(const char *text,
                             cst_voice *voice,
                             const char *outtype);

/// Synthesize from an SSML file, honoring supported tags (pauses, prosody cues, etc.).
///
/// - Parameters:
///   - filename: Path to an SSML document.
///   - voice: Voice to use for synthesis.
///   - outtype: Output sink ("wav", "aiff", "raw", "none", "play").
/// - Returns: Approximate duration of generated audio in seconds.
float flite_ssml_file_to_speech(const char *filename,
                                cst_voice *voice,
                                const char *outtype);

/// Synthesize from an in-memory SSML string.
///
/// - Parameters:
///   - text: SSML markup to synthesize.
///   - voice: Voice to use for synthesis.
///   - outtype: Output sink ("wav", "aiff", "raw", "none", "play").
/// - Returns: Approximate duration of generated audio in seconds.
float flite_ssml_text_to_speech(const char *text,
                                cst_voice *voice,
                                const char *outtype);

/// Attach a lexicon addenda file (custom word → pronunciation mappings) to a voice.
///
/// - Parameters:
///   - v: Target voice to receive the addenda.
///   - lexfile: Path to an addenda file understood by the voice's lexicon.
/// - Returns: 0 on success; non-zero on error.
int flite_voice_add_lex_addenda(cst_voice *v, const cst_string *lexfile);


// MARK: -  Lower lever user functions

/// Synthesize to an in-memory 'cst_wave' from a UTF-8 text string.
///
/// - Parameters:
///   - text: Input text to synthesize.
///   - voice: Voice to use for synthesis.
/// - Returns: Newly allocated wave buffer; caller owns it and must free with 'delete_wave(...)'.
cst_wave *flite_text_to_wave(const char *text,cst_voice *voice);

/// Build and return a full synthesis utterance graph from text.
///
/// - Parameters:
///   - text: Input text to synthesize.
///   - voice: Voice to use for synthesis.
/// - Returns: Newly allocated utterance; caller should free with 'delete_utterance(...)'.
cst_utterance *flite_synth_text(const char *text,cst_voice *voice);

/// Build an utterance by synthesizing from a phoneme sequence.
///
/// - Parameters:
///   - phones: ARPAbet (or voice-expected) phoneme sequence.
///   - voice: Voice to use for synthesis.
/// - Returns: Newly allocated utterance; caller should free with 'delete_utterance(...)'.
cst_utterance *flite_synth_phones(const char *phones,cst_voice *voice);

/// Tokenize-and-synthesize from an existing tokenstream.
///
/// - Parameters:
///   - ts: Tokenstream already positioned over input text.
///   - voice: Voice to use for synthesis.
///   - outtype: Output sink ("wav", "aiff", "raw", "none", "play").
/// - Returns: Approximate duration of generated audio in seconds.
float flite_ts_to_speech(cst_tokenstream *ts,
                         cst_voice *voice,
                         const char *outtype);

/// Run the synthesis pipeline on a pre-constructed utterance.
///
/// - Parameters:
///   - u: Utterance with initial structure/features to process.
///   - voice: Voice to use for synthesis.
///   - synth: Pipeline function to execute.
/// - Returns: The processed utterance (same pointer), or NULL on error.
cst_utterance *flite_do_synth(cst_utterance *u,
                              cst_voice *voice,
                              cst_uttfunc synth);

/// Render/output audio from an utterance according to 'outtype'.
///
/// - Parameters:
///   - u: Fully synthesized utterance containing waveform/features.
///   - outtype: Output sink ("wav", "aiff", "raw", "none", "play"). On iOS, "play" is typically a no-op.
///   - append: If non-zero, append to an existing output file where supported; otherwise overwrite.
/// - Returns: Approximate duration of rendered audio in seconds.
float flite_process_output(cst_utterance *u,
                           const char *outtype,
                           int append);


// MARK: - For voices with external voxdata

/// Memory-map CLUNIT voice data from a directory into the given voice (reduces RAM copy).
///
/// - Parameters:
///   - voxdir: Directory containing the voice's 'voxdata'.
///   - voice: Voice to attach mapped data to.
/// - Returns: 0 on success; non-zero on error.
int flite_mmap_clunit_voxdata(const char *voxdir, cst_voice *voice);

/// Unmap previously mmapped CLUNIT data from the voice.
///
/// - Parameters:
///   - voice: Voice whose mapped data should be released.
/// - Returns: 0 on success; non-zero on error.
int flite_munmap_clunit_voxdata(cst_voice *voice);


// MARK: - Flite public export wrappers for features access

/// Read an integer feature from a feature set, returning 'def' if missing.
///
/// - Parameters:
///   - f: Feature set to query.
///   - name: Feature key.
///   - def: Default value if the key is absent.
/// - Returns: The integer value.
int flite_get_param_int(const cst_features *f, const char *name,int def);

/// Read a float feature from a feature set, returning 'def' if missing.
///
/// - Parameters:
///   - f: Feature set to query.
///   - name: Feature key.
///   - def: Default value if the key is absent.
/// - Returns: The float value.
float flite_get_param_float(const cst_features *f, const char *name, float def);

/// Read a string feature from a feature set, returning 'def' if missing.
///
/// - Parameters:
///   - f: Feature set to query.
///   - name: Feature key.
///   - def: Default string if the key is absent.
/// - Returns: Pointer to a string owned by the feature set.
const char *flite_get_param_string(const cst_features *f, const char *name, const char *def);

/// Read a generic 'cst_val' feature from a feature set, returning 'def' if missing.
///
/// - Parameters:
///   - f: Feature set to query.
///   - name: Feature key.
///   - def: Default value if the key is absent.
/// - Returns: The value (do not free).
const cst_val *flite_get_param_val(const cst_features *f, const char *name, cst_val *def);

/// Set an integer feature value on a feature set.
///
/// - Parameters:
///   - f: Feature set to modify.
///   - name: Feature key.
///   - v: Integer value to store.
void flite_feat_set_int(cst_features *f, const char *name, int v);

/// Set a float feature value on a feature set.
///
/// - Parameters:
///   - f: Feature set to modify.
///   - name: Feature key.
///   - v: Float value to store.
void flite_feat_set_float(cst_features *f, const char *name, float v);

/// Set a string feature value on a feature set (stores an internal copy).
///
/// - Parameters:
///   - f: Feature set to modify.
///   - name: Feature key.
///   - v: UTF-8 string to store.
void flite_feat_set_string(cst_features *f, const char *name, const char *v);

/// Set a feature to an arbitrary 'cst_val'.
///
/// Ownership/retention follows Flite conventions for 'cst_val'.
/// - Parameters:
///   - f: Feature set to modify.
///   - name: Feature key.
///   - v: Value to store.
void flite_feat_set(cst_features *f, const char *name,const cst_val *v);

/// Remove a feature by name from a feature set.
///
/// - Parameters:
///   - f: Feature set to modify.
///   - name: Feature key to remove.
/// - Returns: Non-zero if a value was removed.
int flite_feat_remove(cst_features *f, const char *name);


/// Evaluate a feature-path on an item and return it as a string.
///
/// - Parameters:
///   - item: Starting item in the utterance structure.
///   - featpath: Path expression (e.g., relation traversal and attribute).
/// - Returns: A string pointer valid while the item/utterance is alive.
const char *flite_ffeature_string(const cst_item *item,const char *featpath);

/// Evaluate a feature-path on an item and return it as an integer.
///
/// - Parameters:
///   - item: Starting item.
///   - featpath: Path expression.
/// - Returns: Integer result.
int flite_ffeature_int(const cst_item *item,const char *featpath);

/// Evaluate a feature-path on an item and return it as a float.
///
/// - Parameters:
///   - item: Starting item.
///   - featpath: Path expression.
/// - Returns: Float result.
float flite_ffeature_float(const cst_item *item,const char *featpath);

/// Evaluate a feature-path on an item and return the raw 'cst_val'.
///
/// - Parameters:
///   - item: Starting item.
///   - featpath: Path expression.
/// - Returns: Value pointer owned by the utterance/item.
const cst_val *flite_ffeature(const cst_item *item,const char *featpath);

/// Resolve a feature-path to a specific item within the utterance graph.
///
/// - Parameters:
///   - item: Starting item.
///   - featpath: Path expression to follow.
/// - Returns: The resolved item, or NULL if not found.
cst_item* flite_path_to_item(const cst_item *item,const char *featpath);


// MARK: - These functions are *not* thread-safe, they are designed to be called before the initial synthesis occurs

/// Register a voice in the global registry so it can be selected by name.
///
/// - Parameters:
///   - voice: Voice to register.
/// - Returns: 0 on success; non-zero on error.
int flite_add_voice(cst_voice *voice);

/// Register a language under a short code (e.g., "eng").
///
/// - Parameters:
///   - langname: Short language code.
///   - lang_init: Function that initializes a voice for this language.
///   - lex_init: Factory for the language's lexicon.
/// - Returns: 0 on success; non-zero on error.
int flite_add_lang(const char *langname,
                   void (*lang_init)(cst_voice *vox),
                   cst_lexicon *(*lex_init)());

/// Initialize a voice for UTF-8 grapheme-based synthesis (no dictionary).
///
/// - Parameters:
///   - v: Voice to initialize.
void utf8_grapheme_lang_init(cst_voice *v);

/// Construct a minimal lexicon suitable for grapheme-driven voices.
///
/// - Returns: Newly constructed lexicon object.
cst_lexicon *utf8_grapheme_lex_init(void);


#ifdef __cplusplus
}  /* extern "C" */
#endif /* __cplusplus */

#endif
