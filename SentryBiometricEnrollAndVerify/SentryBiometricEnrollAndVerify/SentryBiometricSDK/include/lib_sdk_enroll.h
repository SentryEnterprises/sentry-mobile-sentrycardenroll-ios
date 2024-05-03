//
//  Header.h
//  
//
//  Created by John Ayres on 4/29/24.
//

#ifndef __lib_sdk_enroll__

#include "stdint.h"
#include "string.h"

// we may not need this to be exposed, selection by itself is useless and a PIN needs to be verified before anything else can happen; use lib_enroll_init instead
int lib_enroll_select(void);


int lib_enroll_verify_pin(uint8_t* pin, int len);
int lib_enroll_set_pin(uint8_t* pin, int len);
int lib_enroll_init(uint8_t* pin, int len);
int lib_enroll_status(uint8_t* max_num_fingers, uint8_t* enrolled_touches, uint8_t* remaining_touches, uint8_t* biometric_mode);
int lib_enroll_process(uint8_t* remaining_touches);
int lib_enroll_reprocess(int num_finger, uint8_t* enrolled_touches, uint8_t* remaining_touches, uint8_t* biometric_mode);
int lib_enroll_verify(void);
int lib_enroll_validate(void);
//int lib_verify_enrollment(uint8_t* pin, int len);

// Defines SDK level error codes. SDK methods may return error codes from the swift callback, so start at -100 (0 to -99 are reserved for swift callback error codes)
#define _SDK_ERROR_PIN_LENGTH_INVALID_      (-100)
#define _SDK_ERROR_PIN_DIGIT_INVALID_       (-101)
#define _SDK_ERROR_NULL_CALLBACK_           (-102)

#endif
