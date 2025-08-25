#pragma once
#ifdef __cplusplus
extern "C" {
#endif

#include "flite.h"  

void flitew_init(void);

void flitew_print_voices(void);

void flitew_register_eng_lang(void);

int flitew_text_to_pcm(const char *text,
                       cst_voice *voice,
                       short **out_samples,
                       int *out_sample_count,
                       int *out_sample_rate);

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
