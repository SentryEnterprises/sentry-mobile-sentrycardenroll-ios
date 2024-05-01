//
//  Header.h
//  
//
//  Created by John Ayres on 4/29/24.
//

#ifndef __lib_sdk_enroll__

#include "stdint.h"
#include "string.h"

int lib_enroll_select(void);
int lib_enroll_init(uint8_t* pin, int len);
int lib_enroll_status(uint8_t* max_num_fingers, uint8_t* enrolled_touches, uint8_t* remaining_touches, uint8_t* biometric_mode);
int lib_enroll_process(int num_finger, uint8_t* enrolled_touches, uint8_t* remaining_touches, uint8_t* biometric_mode);
int lib_enroll_reprocess(int num_finger, uint8_t* enrolled_touches, uint8_t* remaining_touches, uint8_t* biometric_mode);
int lib_enroll_verify(void);

#endif
