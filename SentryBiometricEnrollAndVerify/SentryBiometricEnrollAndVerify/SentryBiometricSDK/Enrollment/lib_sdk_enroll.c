//
//  lib_sdk_enroll.c
//  
//
//  Created by John Ayres on 4/29/24.
//

//#include "lib_wallet.h"
#include "secure.h"
//#include "preliminary.h"
//#include "bip39.h"
#include "wrapper.h"

uint8_t            apdu_enroll_out[300];
uint32_t        apdu_enroll_out_len = 0;

static uint8_t Max_num_fingers, Enrolled_touches, Remaining_touches, Biometric_mode;

uint16_t lib_get_status_word(uint8_t* pout, int len)
{
    uint16_t statusWord;
    if (len < 2) return 0;
    statusWord = (pout[len - 2] << 8) + (pout[len - 1] << 0);       // TODO: does << 0 actually do anything?
    return statusWord;
}

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
int lib_enroll_select(void)
{
    int Ret;
    //uint8_t apdu_sel[] = { 0x00, 0xA4, 0x04, 0x00, 0x00};
    uint8_t apdu_select[] = { 0x00, 0xA4, 0x04, 0x00, 0x09, 0x49, 0x44, 0x45, 0x58, 0x5F, 0x4C, 0x5F, 0x01, 0x01, 0x00 };
    apdu_enroll_out_len = 0;
    //int Ret = apdu_secure_channel(apdu_sel, sizeof(apdu_sel), apdu_enroll_out, &apdu_enroll_out_len);
    //if (Ret != 0) return Ret;
    Ret = apdu_secure_channel(apdu_select, sizeof(apdu_select), apdu_enroll_out, &apdu_enroll_out_len);
//Ret = apdu_secure_channel(apdu_select, sizeof(apdu_select), apdu_enroll_out, &apdu_enroll_out_len);
  //  if (Ret != 0) return _SDK_ERROR_EXCHANGE_;
   // Ret = lib_check_sw_err(apdu_enroll_out, apdu_enroll_out_len);
   // if (Ret != 0) return Ret;
    Ret = lib_get_status_word(apdu_enroll_out, apdu_enroll_out_len);
    return Ret;
}

//----------------------------------------------------------------------------------------------------------------------
int lib_enroll_verify_pin(uint8_t* pin, int len)
{
    int p = 5, Ret;
    uint8_t b;
    uint8_t apdu_verify_pin[] = { 0x80,0x20,0x00,0x80,0x08,0x2F,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF };
    if (len < 4) return -1;
    if (len > 8) return -1;
    apdu_verify_pin[p++] = (uint8_t)(0x20 + len);
    for (int i = 0; i < len; i++)
    {
        b = pin[i];
        if (b > 0x09) return -2;
        if ((i & 0x01) == 0)
        {
            apdu_verify_pin[p] &= 0x0F;
            apdu_verify_pin[p] |= (b << 4);
        }
        else
        {
            apdu_verify_pin[p] &= 0xF0;
            apdu_verify_pin[p++] |= (b << 0);

        }
    }

    apdu_enroll_out_len = 0;
    Ret = apdu_secure_channel(apdu_verify_pin, sizeof(apdu_verify_pin), apdu_enroll_out, &apdu_enroll_out_len);
    if (Ret != 0) return Ret;
    if (apdu_enroll_out_len != 2) return -4;
    if (apdu_enroll_out[0] == 0x90 && apdu_enroll_out[1] == 0x00) return 0;
    if (apdu_enroll_out[0] == 0x69 && apdu_enroll_out[1] == 0x85) return -50;

    if (apdu_enroll_out[0] != 0x69 && apdu_enroll_out[0] != 0x61) return -100;
    if ((apdu_enroll_out[1] & 0xF0) != 0xC0) return -100;
    return (apdu_enroll_out[1]);
}
//----------------------------------------------------------------------------------------------------------------------
int lib_enroll_personalise(uint8_t* pin, int len)
{
    int p = 8, Ret;
    uint8_t b;
    uint8_t apdu_set_pin[] = { 0x80,0xE2,0x08,0x00,0x0B,0x90, 0x00, 0x08, 0x2F,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF };
    if (len < 4) return -1;
    if (len > 8) return -1;
    apdu_set_pin[p++] = (uint8_t)(0x20 + len);
    for (int i = 0; i < len; i++)
    {
        b = pin[i];
        if (b > 0x09) return -2;
        if ((i & 0x01) == 0)
        {
            apdu_set_pin[p] &= 0x0F;
            apdu_set_pin[p] |= (b << 4);
        }
        else
        {
            apdu_set_pin[p] &= 0xF0;
            apdu_set_pin[p++] |= (b << 0);

        }
    }

    apdu_enroll_out_len = 0;
    Ret = apdu_secure_channel(apdu_set_pin, sizeof(apdu_set_pin), apdu_enroll_out, &apdu_enroll_out_len);
 //   if (Ret != 0) return _SDK_ERROR_EXCHANGE_;
 //   Ret = lib_check_sw_err(apdu_enroll_out, apdu_enroll_out_len);
    if (Ret != 0) return Ret;

    uint8_t apdu_set_ptl[] = { 0x80,0xE2,0x08,0x00,0x04, 0x90, 0x08, 0x01, 0x03};
    apdu_enroll_out_len = 0;
    Ret = apdu_secure_channel(apdu_set_ptl, sizeof(apdu_set_ptl), apdu_enroll_out, &apdu_enroll_out_len);
//    if (Ret != 0) return _SDK_ERROR_EXCHANGE_;
//    Ret = lib_check_sw_err(apdu_enroll_out, apdu_enroll_out_len);
    if (Ret != 0) return Ret;


    uint8_t apdu_set_enroll[] = { 0x80,0xE2,0x08,0x00,0x04, 0x90, 0x13, 0x01, 0xCB };
    apdu_enroll_out_len = 0;
    Ret = apdu_secure_channel(apdu_set_enroll, sizeof(apdu_set_enroll), apdu_enroll_out, &apdu_enroll_out_len);
 //   if (Ret != 0) return _SDK_ERROR_EXCHANGE_;
//    Ret = lib_check_sw_err(apdu_enroll_out, apdu_enroll_out_len);
    if (Ret != 0) return Ret;

    uint8_t apdu_set_enroll_limit[] = { 0x80,0xE2,0x08,0x00,0x04, 0x90, 0x15, 0x01, 0xFF };
    apdu_enroll_out_len = 0;
    Ret = apdu_secure_channel(apdu_set_enroll_limit, sizeof(apdu_set_enroll_limit), apdu_enroll_out, &apdu_enroll_out_len);
 //   if (Ret != 0) return _SDK_ERROR_EXCHANGE_;
 //   Ret = lib_check_sw_err(apdu_enroll_out, apdu_enroll_out_len);
    if (Ret != 0) return Ret;

    uint8_t apdu_set_store[] = { 0x80,0xE2,0x88,0x00,0x00};
    apdu_enroll_out_len = 0;
    Ret = apdu_secure_channel(apdu_set_store, sizeof(apdu_set_store), apdu_enroll_out, &apdu_enroll_out_len);
 //   if (Ret != 0) return _SDK_ERROR_EXCHANGE_;
  //  Ret = lib_check_sw_err(apdu_enroll_out, apdu_enroll_out_len);
    if (Ret != 0) return Ret;
    return 0;

}
//----------------------------------------------------------------------------------------------------------------------
int lib_enroll_init(uint8_t* pin, int len)
{
    int ret = lib_enroll_select();
    if (ret != 0) return ret;
    ret = lib_enroll_verify_pin(pin, len);
    if (ret == -50)
    {
        ret = lib_enroll_personalise(pin, len);
        if (ret != 0) return ret;
        ret = lib_enroll_select();
        if (ret != 0) return ret;
        ret = lib_enroll_verify_pin(pin, len);
    }
    Max_num_fingers = 0;
    Enrolled_touches = 0;
    Remaining_touches = 0;
    Biometric_mode = 0xff;

    return ret;
}
//----------------------------------------------------------------------------------------------------------------------
int lib_enroll_status(uint8_t* max_num_fingers, uint8_t* enrolled_touches, uint8_t* remaining_touches, uint8_t* biometric_mode )
{
    int Ret=0;
    do
    {
        uint8_t apdu_status[] = { 0x00, 0x59, 0x04, 0x00, 0x01, 0x00 };
        apdu_enroll_out_len = 0;
        Ret = apdu_secure_channel(apdu_status, sizeof(apdu_status), apdu_enroll_out, &apdu_enroll_out_len);
  //      if (Ret != 0) return _SDK_ERROR_EXCHANGE_;
 //       Ret = lib_enroll_check_sw(apdu_enroll_out, apdu_enroll_out_len);
        if (Ret == 0) break;
        if (Ret == 1) continue;
        return -Ret;
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
    return Ret;

}
//----------------------------------------------------------------------------------------------------------------------
int lib_enroll_process(int num_finger, uint8_t* enrolled_touches, uint8_t* remaining_touches, uint8_t* biometric_mode)
{
    int Ret=0;
    if (num_finger > Max_num_fingers) return -101;
    if (Biometric_mode ==1) return -102;

    do
    {
        uint8_t apdu_process[] = { 0x00, 0x59, 0x03, 0x00, 0x02, 0x00, 0x01 };
        apdu_enroll_out_len = 0;
        Ret = apdu_secure_channel(apdu_process, sizeof(apdu_process), apdu_enroll_out, &apdu_enroll_out_len);
  //      if (Ret != 0) return _SDK_ERROR_EXCHANGE_;
  //      Ret = lib_enroll_check_sw(apdu_enroll_out, apdu_enroll_out_len);
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
int lib_enroll_verify(void)
{
    int Ret=0;
    do
    {
        uint8_t apdu_verify[] = { 0x00, 0x59, 0x00, 0x00, 0x01, 0x00 };
        apdu_enroll_out_len = 0;
        Ret = apdu_secure_channel(apdu_verify, sizeof(apdu_verify), apdu_enroll_out, &apdu_enroll_out_len);
        if (Ret != 0) return Ret;
 //       Ret = lib_enroll_check_sw(apdu_enroll_out, apdu_enroll_out_len);
        if (Ret == 0) break;
        if (Ret == 1) continue;
        return -Ret;
    } while (1);

    return Ret;
}
//----------------------------------------------------------------------------------------------------------------------
