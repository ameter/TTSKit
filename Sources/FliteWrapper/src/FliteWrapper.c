#include "Flite.h"
#include <string.h>

extern cst_val *flite_voice_list;
extern void usenglish_init(cst_voice *v);
extern cst_lexicon *cmulex_init(void);
extern cst_voice *register_cmu_us_rms(const char *voxdir);
extern cst_voice *register_cmu_us_slt(const char *voxdir);

void flitew_init(void) {
    flite_init();
}

void flitew_register_eng_lang(void) {
    // Make the "eng" language+lexicon available to flite_voice_load(...)
    flite_add_lang("eng", usenglish_init, cmulex_init);
}

cst_voice *flitew_voice_load(const char *path) {
    if (!path) return NULL;
    return flite_voice_load(path);
}

cst_voice *flitew_register_cmu_us_rms(void) {
    return register_cmu_us_rms(NULL);
}

cst_voice *flitew_register_cmu_us_slt(void) {
    return register_cmu_us_slt(NULL);
}

void flitew_voice_set_duration_stretch(cst_voice *voice, float value) {
    if (!voice || !voice->features) return;
    static const char key[] = "duration_stretch";
    feat_set_float(voice->features, key, value);
}

void flitew_voice_set_f0_shift(cst_voice *voice, float value) {
    if (!voice || !voice->features) return;
    static const char key[] = "f0_shift";
    feat_set_float(voice->features, key, value);
}

void flitew_voice_set_f0_target_mean(cst_voice *voice, float value) {
    if (!voice || !voice->features) return;
    static const char key[] = "int_f0_target_mean";
    feat_set_float(voice->features, key, value);
}

void flitew_voice_set_f0_target_stddev(cst_voice *voice, float value) {
    if (!voice || !voice->features) return;
    static const char key[] = "int_f0_target_stddev";
    feat_set_float(voice->features, key, value);
}

void flitew_voice_clear_feature(cst_voice *voice, const char *name) {
    if (!voice || !voice->features || !name) return;
    feat_remove(voice->features, name);
}

/// Synthesize `text` with `voice` and return 16-bit mono PCM via malloc.
/// On success returns 0 and fills out pointers. Call `flitew_free_pcm` to free.
int flitew_text_to_pcm(const char *text,
                       cst_voice *voice,
                       short **out_samples,
                       int *out_sample_count,
                       int *out_sample_rate)
{
    if (!text || !voice || !out_samples || !out_sample_count || !out_sample_rate) return 1;
    
    cst_wave *w = flite_text_to_wave(text, voice);
    if (!w) return 2;
    
    const int ns = w->num_samples;
    const int sr = w->sample_rate;
    if (ns <= 0 || sr <= 0) { delete_wave(w); return 3; }
    
    short *buf = (short *)malloc((size_t)ns * sizeof(short));
    if (!buf) { delete_wave(w); return 4; }
    
    memcpy(buf, (const short *)w->samples, (size_t)ns * sizeof(short));
    delete_wave(w);
    
    *out_samples = buf;
    *out_sample_count = ns;
    *out_sample_rate = sr;
    return 0;
}

void flitew_free_pcm(short *p) {
    if (p) free(p);
}
