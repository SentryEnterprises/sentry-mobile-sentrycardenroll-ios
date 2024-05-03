//
//  lib_sdk_enroll.c
//  
//
//  Created by John Ayres on 4/29/24.
//

#include "lib_sdk_enroll.h"
#include "secure.h"
#include "wrapper.h"

uint8_t     apdu_enroll_out[300];
uint32_t    apdu_enroll_out_len = 0;

static uint8_t Max_num_fingers, Enrolled_touches, Remaining_touches, Biometric_mode;


/// verified
///
/// internal methods (not exposed in the header)
/// Gets the last 2 bytes from the indicated buffer and returns that as a 16 bit integer.
uint16_t lib_get_status_word(uint8_t* pout, int len)
{
    uint16_t statusWord;
    if (len < 2) return 0;
    statusWord = (pout[len - 2] << 8) + (pout[len - 1]);
    return statusWord;
}


/// public methods (exposed in the header)
//----------------------------------------------------------------------------------------------------------------------
// TODO: may not expose this
int lib_enroll_select(void)
{
    int returnValue;
    uint8_t apdu_select[] = { 0x00, 0xA4, 0x04, 0x00, 0x09, 0x49, 0x44, 0x45, 0x58, 0x5F, 0x4C, 0x5F, 0x01, 0x01, 0x00 };
    apdu_enroll_out_len = 0;
    //int Ret = apdu_secure_channel(apdu_sel, sizeof(apdu_sel), apdu_enroll_out, &apdu_enroll_out_len);
    //if (Ret != 0) return Ret;
    returnValue = apdu_secure_channel(apdu_select, sizeof(apdu_select), apdu_enroll_out, &apdu_enroll_out_len);
//Ret = apdu_secure_channel(apdu_select, sizeof(apdu_select), apdu_enroll_out, &apdu_enroll_out_len);
  //  if (Ret != 0) return _SDK_ERROR_EXCHANGE_;
   // Ret = lib_check_sw_err(apdu_enroll_out, apdu_enroll_out_len);
   
    // if the swift callback returned an error, return that error code
    if (returnValue != 0) return returnValue;
    
    // otherwise, return the status word
    returnValue = lib_get_status_word(apdu_enroll_out, apdu_enroll_out_len);
    return returnValue;
}

//----------------------------------------------------------------------------------------------------------------------
int lib_enroll_init(uint8_t* pin, int len)
{
    //select the enroll applet
    int returnValue = lib_enroll_select();
    if (returnValue != 0x9000) return returnValue;
    
    // before we can get the enrollment status, we need to verify the PIN
    returnValue = lib_enroll_verify_pin(pin, len);
    if (returnValue == 0x6985)      // the applet returns 'conditions not satisfied' if there isn't a pin
    {
        // set the pin
        returnValue = lib_enroll_set_pin(pin, len);
        if (returnValue != 0x9000) return returnValue;
        
        // select the applet again
        returnValue = lib_enroll_select();
        if (returnValue != 0x9000) return returnValue;
        
        // verify the pin one more time
        returnValue = lib_enroll_verify_pin(pin, len);
    }
    
    Max_num_fingers = 0;
    Enrolled_touches = 0;
    Remaining_touches = 0;
    Biometric_mode = 0xff;

    return returnValue;
}

//----------------------------------------------------------------------------------------------------------------------
// returns 0x9000 if the pin verified successfully
// returns 0x6985 if there isn't a pin and one needs to be set
int lib_enroll_verify_pin(uint8_t* pin, int len)
{
    int bufferPointer = 5;      // starts at the 6th byte in the apdu_verify_pin buffer below
    int returnValue;
    uint8_t bufferByte;
    uint8_t apdu_verify_pin[] = { 0x80, 0x20, 0x00, 0x80, 0x08, 0x2F, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF };
    
    // the PIN must be 4 - 7 characters in length
    if (len < 4) return _SDK_ERROR_PIN_LENGTH_INVALID_;
    if (len > 8) return _SDK_ERROR_PIN_LENGTH_INVALID_;
    
    // embed the actual PIN digits within the apdu command
    apdu_verify_pin[bufferPointer++] = (uint8_t)(0x20 + len);
    for (int i = 0; i < len; i++)
    {
        bufferByte = pin[i];
        if (bufferByte > 0x09) return _SDK_ERROR_PIN_DIGIT_INVALID_;    // PIN digits must be in the range 0 - 9
        if ((i & 0x01) == 0)
        {
            apdu_verify_pin[bufferPointer] &= 0x0F;
            apdu_verify_pin[bufferPointer] |= (bufferByte << 4);
        }
        else
        {
            apdu_verify_pin[bufferPointer] &= 0xF0;
            apdu_verify_pin[bufferPointer++] |= bufferByte;      // apdu_verify_pin[p++] |= (bufferByte << 0);
        }
    }

    apdu_enroll_out_len = 0;
    returnValue = apdu_secure_channel(apdu_verify_pin, sizeof(apdu_verify_pin), apdu_enroll_out, &apdu_enroll_out_len);
    
    if (returnValue != 0) return returnValue;
    
//    // TODO: what should this return? does this happen?
//    if (apdu_enroll_out_len != 2) 
//        return -4;
   // if (apdu_enroll_out[0] == 0x90 && apdu_enroll_out[1] == 0x00) return 0;
   // if (apdu_enroll_out[0] == 0x69 && apdu_enroll_out[1] == 0x85) return -50;

    // TODO: -x6961 not documented anywhere
//    if (apdu_enroll_out[0] != 0x69 && apdu_enroll_out[0] != 0x61) return -100;
    
//    if ((apdu_enroll_out[1] & 0xF0) != 0xC0) return -100;
//    return (apdu_enroll_out[1]);      // this is the number of verification tries remaining
    
    // if the swift callback returned an error, return that error code
    if (returnValue != 0) return returnValue;
    
    // otherwise, return the status word
    returnValue = lib_get_status_word(apdu_enroll_out, apdu_enroll_out_len);
    return returnValue;
}

//----------------------------------------------------------------------------------------------------------------------
int lib_enroll_set_pin(uint8_t* pin, int len)
{
    int bufferPointer = 8;      // starts at the 9th byte of the apdu_set_pin buffer below
    int returnValue;
    uint8_t bufferByte;
    uint8_t apdu_set_pin[] = { 0x80, 0xE2, 0x08, 0x00, 0x0B, 0x90, 0x00, 0x08, 0x2F, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF };
    
    // the PIN must be 4 - 7 characters in length
    if (len < 4) return _SDK_ERROR_PIN_LENGTH_INVALID_;
    if (len > 8) return _SDK_ERROR_PIN_LENGTH_INVALID_;
    
    // embed the actual PIN digits within the apdu command
    apdu_set_pin[bufferPointer++] = (uint8_t)(0x20 + len);
    for (int i = 0; i < len; i++)
    {
        bufferByte = pin[i];
        if (bufferByte > 0x09) _SDK_ERROR_PIN_DIGIT_INVALID_;    // PIN digits must be in the range 0 - 9
        if ((i & 0x01) == 0)
        {
            apdu_set_pin[bufferPointer] &= 0x0F;
            apdu_set_pin[bufferPointer] |= (bufferByte << 4);
        }
        else
        {
            apdu_set_pin[bufferPointer] &= 0xF0;
            apdu_set_pin[bufferPointer++] |= bufferByte;
        }
    }

    apdu_enroll_out_len = 0;
    returnValue = apdu_secure_channel(apdu_set_pin, sizeof(apdu_set_pin), apdu_enroll_out, &apdu_enroll_out_len);
 //   if (Ret != 0) return _SDK_ERROR_EXCHANGE_;
 //   Ret = lib_check_sw_err(apdu_enroll_out, apdu_enroll_out_len);
    if (returnValue != 0) return returnValue;
    returnValue = lib_get_status_word(apdu_enroll_out, apdu_enroll_out_len);
    if (returnValue != 0x9000) return returnValue;

    uint8_t apdu_set_ptl[] = { 0x80, 0xE2, 0x08, 0x00, 0x04, 0x90, 0x08, 0x01, 0x03};
    apdu_enroll_out_len = 0;
    returnValue = apdu_secure_channel(apdu_set_ptl, sizeof(apdu_set_ptl), apdu_enroll_out, &apdu_enroll_out_len);
//    if (Ret != 0) return _SDK_ERROR_EXCHANGE_;
//    Ret = lib_check_sw_err(apdu_enroll_out, apdu_enroll_out_len);
    if (returnValue != 0) return returnValue;
    returnValue = lib_get_status_word(apdu_enroll_out, apdu_enroll_out_len);
    if (returnValue != 0x9000) return returnValue;


    uint8_t apdu_set_enroll[] = { 0x80, 0xE2, 0x08, 0x00, 0x04, 0x90, 0x13, 0x01, 0xCB };
    apdu_enroll_out_len = 0;
    returnValue = apdu_secure_channel(apdu_set_enroll, sizeof(apdu_set_enroll), apdu_enroll_out, &apdu_enroll_out_len);
 //   if (Ret != 0) return _SDK_ERROR_EXCHANGE_;
//    Ret = lib_check_sw_err(apdu_enroll_out, apdu_enroll_out_len);
    if (returnValue != 0) return returnValue;
    returnValue = lib_get_status_word(apdu_enroll_out, apdu_enroll_out_len);
    if (returnValue != 0x9000) return returnValue;

    uint8_t apdu_set_enroll_limit[] = { 0x80, 0xE2, 0x08, 0x00, 0x04, 0x90, 0x15, 0x01, 0xFF };
    apdu_enroll_out_len = 0;
    returnValue = apdu_secure_channel(apdu_set_enroll_limit, sizeof(apdu_set_enroll_limit), apdu_enroll_out, &apdu_enroll_out_len);
 //   if (Ret != 0) return _SDK_ERROR_EXCHANGE_;
 //   Ret = lib_check_sw_err(apdu_enroll_out, apdu_enroll_out_len);
    if (returnValue != 0) return returnValue;
    returnValue = lib_get_status_word(apdu_enroll_out, apdu_enroll_out_len);
    if (returnValue != 0x9000) return returnValue;

    uint8_t apdu_set_store[] = { 0x80, 0xE2, 0x88, 0x00, 0x00};
    apdu_enroll_out_len = 0;
    returnValue = apdu_secure_channel(apdu_set_store, sizeof(apdu_set_store), apdu_enroll_out, &apdu_enroll_out_len);
 //   if (Ret != 0) return _SDK_ERROR_EXCHANGE_;
  //  Ret = lib_check_sw_err(apdu_enroll_out, apdu_enroll_out_len);
    if (returnValue != 0) return returnValue;
    
    returnValue = lib_get_status_word(apdu_enroll_out, apdu_enroll_out_len);
    return returnValue;
}

//----------------------------------------------------------------------------------------------------------------------
int lib_enroll_status(uint8_t* max_num_fingers, uint8_t* enrolled_touches, uint8_t* remaining_touches, uint8_t* biometric_mode )
{
    int returnValue = 0;
    do
    {
        uint8_t apdu_status[] = { 0x00, 0x59, 0x04, 0x00, 0x01, 0x00 };
        apdu_enroll_out_len = 0;
        returnValue = apdu_secure_channel(apdu_status, sizeof(apdu_status), apdu_enroll_out, &apdu_enroll_out_len);
  //      if (Ret != 0) return _SDK_ERROR_EXCHANGE_;
 //       Ret = lib_enroll_check_sw(apdu_enroll_out, apdu_enroll_out_len);
        if (returnValue == 0) break;
        if (returnValue == 1) continue;
        return returnValue;
    } while (1);

 //   if (apdu_enroll_out_len < (32 + 12)) return _SDK_ERROR_STATE_;
    max_num_fingers[0] = apdu_enroll_out[31];
    Max_num_fingers = max_num_fingers[0];

    enrolled_touches[0] = apdu_enroll_out[32];
    Enrolled_touches = enrolled_touches[0];

    remaining_touches[0] = apdu_enroll_out[33];
    Remaining_touches = remaining_touches[0];

    biometric_mode[0] = apdu_enroll_out[39];
    Biometric_mode = biometric_mode[0];
    
    returnValue = lib_get_status_word(apdu_enroll_out, apdu_enroll_out_len);
    return returnValue;
}

//----------------------------------------------------------------------------------------------------------------------
int lib_enroll_process(uint8_t* remaining_touches)
{
    int returnValue = 0;
    
    do
    {
        uint8_t apdu_process[] = { 0x00, 0x59, 0x03, 0x00, 0x02, 0x00, 0x01 };
        apdu_enroll_out_len = 0;
        returnValue = apdu_secure_channel(apdu_process, sizeof(apdu_process), apdu_enroll_out, &apdu_enroll_out_len);
        //      if (Ret != 0) return _SDK_ERROR_EXCHANGE_;
        //      Ret = lib_enroll_check_sw(apdu_enroll_out, apdu_enroll_out_len);
        if (returnValue == 0) break;
        if (returnValue == 1) continue;
        return returnValue;
    } while (1);
    
    returnValue = lib_get_status_word(apdu_enroll_out, apdu_enroll_out_len);
    if (returnValue != 0x9000) {
        return returnValue;
    }

    uint8_t max_num_fingers[1];
    uint8_t biometric_mode[1];
    uint8_t enrolled_touches[1];
    returnValue = lib_enroll_status(max_num_fingers, enrolled_touches, remaining_touches, biometric_mode);
    //       if (Ret != 0) return _SDK_ERROR_EXCHANGE_;
    //       Ret = lib_check_sw_err(apdu_enroll_out, apdu_enroll_out_len);
    //      if (Ret != 0) return Ret;
    
    
    return returnValue;
}

//----------------------------------------------------------------------------------------------------------------------
// note that this just verifies the enrollment process
int lib_enroll_verify(void)
{
    int returnValue = 0;
    do
    {
        uint8_t apdu_verify[] = { 0x00, 0x59, 0x00, 0x00, 0x01, 0x00 };
        apdu_enroll_out_len = 0;
        returnValue = apdu_secure_channel(apdu_verify, sizeof(apdu_verify), apdu_enroll_out, &apdu_enroll_out_len);
        
        //      if (Ret != 0) return Ret;
        //       Ret = lib_enroll_check_sw(apdu_enroll_out, apdu_enroll_out_len);
        if (returnValue == 0) break;
        if (returnValue == 1) continue;
        return returnValue;
    } while (1);
    
    returnValue = lib_get_status_word(apdu_enroll_out, apdu_enroll_out_len);
    return returnValue;
}

int lib_enroll_validate(void)
{
    int returnValue = 0;
    do
    {
        uint8_t apdu_verify[] = { 0xED, 0x56, 0x00, 0x00, 0x01, 0x00 };
        apdu_enroll_out_len = 0;
        returnValue = apdu_secure_channel(apdu_verify, sizeof(apdu_verify), apdu_enroll_out, &apdu_enroll_out_len);
        
        //      if (Ret != 0) return Ret;
        //       Ret = lib_enroll_check_sw(apdu_enroll_out, apdu_enroll_out_len);
        if (returnValue == 0) break;
        if (returnValue == 1) continue;
        return returnValue;
    } while (1);
    
    returnValue = lib_get_status_word(apdu_enroll_out, apdu_enroll_out_len);
    return returnValue;
}

//int lib_verify_enrollment(uint8_t* pin, int len)
//{
//    // verify enrollment
//    int returnValue = lib_enroll_verify();
//    if (returnValue == 0x6985)      // the applet returns 'conditions not satisfied' if there isn't a pin
//    {
//        // verify the pin one more time
//        returnValue = lib_enroll_verify_pin(pin, len);
//
//        if (returnValue == 0x9000) {
//            returnValue = lib_enroll_verify();
//        }
//    }
//    
//    return returnValue;
//}









//----------------------------------------------------------------------------------------------------------------------
int lib_enroll_check_status_word(uint8_t* apdu_enroll, uint32_t  apdu_enroll_len)
{
    uint16_t SW;
    int resp = 0;
    SW = lib_get_status_word(apdu_enroll, apdu_enroll_len);
    switch (SW)
    {
        //------------
    case    0x9000:
        resp = 0;
        break;

        //------ 1 ------
    case    0x6300:
    case    0x6745:
    case    0x6747:
    case    0x6748:
        resp = 1;
        break;

        //------ 2 ------
    case    0x6749:
    case    0x6987:
    case    0x6988:
    case    0x6F87:
    case    0x6F88:
        resp = 2;
        break;

        //------ 3 ------
    case    0x6746:
    case    0x6A84:
        resp = 3;
        break;

        //------ 4 ------
    case    0x62A1:
    case    0x62F1:
    case    0x63C0:
    case    0x6501:
    case    0x6502:
    case    0x6503:
    case    0x6641:
    default:
        resp = 4;
        break;
    }
    return resp;
}
















//----------------------------------------------------------------------------------------------------------------------
int lib_enroll_reprocess(int num_finger, uint8_t* enrolled_touches, uint8_t* remaining_touches, uint8_t* biometric_mode)
{
    int Ret=0;
    if (num_finger > Max_num_fingers) return -101;
    if (Biometric_mode == 0 && Enrolled_touches==0) return -102;
    
    do
    {
        uint8_t apdu_process[] = { 0x00, 0x59, 0x03, 0x00, 0x02, 0x02, 0x01 };
        apdu_enroll_out_len = 0;
        Ret = apdu_secure_channel(apdu_process, sizeof(apdu_process), apdu_enroll_out, &apdu_enroll_out_len);
        if (Ret != 0) return Ret;
//        Ret = lib_enroll_check_sw(apdu_enroll_out, apdu_enroll_out_len);
        if (Ret == 0) break;
        if (Ret == 1) continue;
        return -Ret;
    } while (1);
    
    {
        uint8_t max_num_fingers[1];
        Ret = lib_enroll_status(max_num_fingers, enrolled_touches, remaining_touches, biometric_mode);
 //       if (Ret != 0) return _SDK_ERROR_EXCHANGE_;
 //       Ret = lib_check_sw_err(apdu_enroll_out, apdu_enroll_out_len);
        if (Ret != 0) return Ret;
    }

    return Ret;
}

//----------------------------------------------------------------------------------------------------------------------
