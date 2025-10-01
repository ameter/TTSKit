#include "Flite.h"

void flitew_init(void) {
    flite_init();
}

extern cst_val *flite_voice_list;

void flitew_register_voices() {
    //    register_cmu_us_rms();
}

void flitew_print_voices(void) {
    printf("printing voices\n");
    for (const cst_val *it = flite_voice_list; it; it = val_cdr(it)) {
        const cst_val *node = val_car(it);
        cst_voice *vv = val_voice(node);
        if (vv && vv->features) {
            const char *nm = feat_string(vv->features, "name");
            printf("voice: %s\n", nm ? nm : "(unnamed)");
        } else {
            // Older builds may store strings; try best-effort without crashing/logging.
            // Only attempt val_string if node is actually a string in your build.
            // If your build doesn’t use strings here, this branch will be skipped.
            // (Intentionally not calling val_string() blindly to avoid error spam.)
        }
    }
}

extern void usenglish_init(cst_voice *v);
extern cst_lexicon *cmulex_init(void);

void flitew_register_eng_lang(void) {
    // Make the "eng" language+lexicon available to flite_voice_load(...)
    flite_add_lang("eng", usenglish_init, cmulex_init);
}

cst_voice *flitew_voice_load(const char *path) {
    if (!path) return NULL;
    return flite_voice_load(path);
}

void flitew_add_voice(cst_voice *voice) {
    if (!voice) return;
    flite_add_voice(voice);
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


//#include <stdlib.h>
//#include <string.h>
//#include <math.h>
//#include "flite.h"
//
//// Choose the higher‑quality SLT voice. If you prefer another, change both lines to that register_… symbol.
////extern cst_voice *register_cmu_us_slt(void);
//extern cst_voice *register_cmu_us_rms(void);
//
//static cst_voice *g_voice = NULL;
//
//void flitew_init(void) {
//    flite_init();
////    g_voice = register_cmu_us_slt();
//    g_voice = register_cmu_us_rms();
//}
//
//int flitew_say(const char *text,
//               float rate_multiplier,
//               float pitch_shift_semitones,
//               short **out_samples,
//               int *out_num_samples,
//               int *out_sample_rate)
//{
//    if (!g_voice || !text || !out_samples || !out_num_samples || !out_sample_rate)
//        return 1;
//    
//    if (rate_multiplier <= 0.f) rate_multiplier = 1.f;
//    // Flite uses duration_stretch (>1 = slower). Our API's rate>1 means faster, so invert.
//    feat_set_float(g_voice->features, "duration_stretch", 1.0f / rate_multiplier);
//    
//    if (pitch_shift_semitones != 0.0f) {
//        float ratio = powf(2.0f, pitch_shift_semitones / 12.0f);
//        feat_set_float(g_voice->features, "f0_shift", ratio);
//    }
//    
//    cst_wave *w = flite_text_to_wave(text, g_voice);
//    if (!w) return 2;
//    
//    int nsamp = w->num_samples;
//    int srate = w->sample_rate;
//    int bytes = nsamp * (int)sizeof(int16_t);
//    
//    int16_t *copy = (int16_t *)malloc(bytes);
//    if (!copy) { delete_wave(w); return 3; }
//    memcpy(copy, (int16_t *)w->samples, bytes);
//    
//    *out_samples = copy;
//    *out_num_samples = nsamp;
//    *out_sample_rate = srate;
//    
//    delete_wave(w);
//    return 0;
//}
//
//void flitew_free(short *samples) {
//    if (samples) free(samples);
//}
//
//// --- Runtime feature controls exposed to Swift ---
//void flitew_set_feature_float(const char *key, float value) {
//    if (!g_voice || !key) return;
//    feat_set_float(g_voice->features, key, value);
//}
//
//void flitew_set_feature_int(const char *key, int value) {
//    if (!g_voice || !key) return;
//    feat_set_int(g_voice->features, key, value);
//}
//
//void flitew_set_feature_string(const char *key, const char *value) {
//    if (!g_voice || !key || !value) return;
//    feat_set_string(g_voice->features, key, value);
//}
//
//void flitew_set_prosody(float rate, float basePitchHz, float pitchVarHz) {
//    if (!g_voice) return;
//    if (rate <= 0.f) rate = 1.f;
//    feat_set_float(g_voice->features, "duration_stretch", 1.0f / rate);
//    feat_set_float(g_voice->features, "int_f0_target_mean", basePitchHz);
//    feat_set_float(g_voice->features, "int_f0_target_stddev", pitchVarHz);
//}
