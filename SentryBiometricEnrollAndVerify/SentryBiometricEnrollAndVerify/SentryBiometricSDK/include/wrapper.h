//
//  wrapper.h
//
//
//  Created by John Ayres on 4/29/24.
//

#ifndef __WRAPPER_C__
#include "stdint.h"

extern int ApduIsSecureChannel;
typedef int (*SmartCardApduCallBack)(uint8_t* DataIn, uint32_t DataInLen, uint8_t* DataOut, uint32_t* DataOutLen);

extern SmartCardApduCallBack pSmartCardApduCallBack;

int apdu_secure_channel(uint8_t* DataIn, uint32_t DataInLen, uint8_t* DataOut, uint32_t* DataOutLen);
void wrapper_init(uint8_t* chaining);
void wrap(uint8_t* apdu_in, uint32_t in_len, uint8_t* apdu_out, uint32_t* out_len, uint8_t* key_enc, uint8_t* key_cmac);
int unwrap(uint8_t* apdu_in, uint32_t in_len, uint8_t* apdu_out, uint32_t* out_len, uint8_t* key_enc, uint8_t* key_rmac);


#endif // !__WRAPPER_C__

