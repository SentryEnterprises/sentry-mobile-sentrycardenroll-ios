//
//  libsdkmain.c
//  
//
//  Created by John Ayres on 4/29/24.
//

#include "stdint.h"
#include "string.h"

#include "libsdkmain.h"
#include "secure.h"
#include "wrapper.h"
#include "libsdkmain.h"
#include "lib_sdk_enroll.h"







//----------------------------------------------------------------------------------------------------------------------
_Export_ int LibSdkEnrollInit(uint8_t* pin, int len, SmartCardApduCallBack callback)
{
    int returnValue;
    ApduIsSecureChannel = 0;
    pSmartCardApduCallBack = callback;
    
    if (callback == NULL) return _SDK_ERROR_NULL_CALLBACK_;

    returnValue = lib_enroll_init(pin, len);
    return returnValue;
}

//----------------------------------------------------------------------------------------------------------------------
// this requires that LibSdkEnrollInit has been called, or that the app is selected, the pin has been verified, and a callback is in place
_Export_ int LibSdkGetEnrollStatus(uint8_t* max_num_fingers, uint8_t* enrolled_touches, uint8_t* remaining_touches, uint8_t* biometric_mode)
{
    int returnValue;
    returnValue = lib_enroll_status(max_num_fingers, enrolled_touches, remaining_touches, biometric_mode);
    
    // TODO: This ignores qualification touches, we made need that in the future
    
    return returnValue;
}

//----------------------------------------------------------------------------------------------------------------------
_Export_ int LibSdkEnrollDeinit(void)
{
    ApduIsSecureChannel = 0;
    pSmartCardApduCallBack = NULL;
    return 0;
}

//----------------------------------------------------------------------------------------------------------------------
_Export_ int LibSdkEnrollProcess(uint8_t* remaining_touches)
{
    int returnValue;
    returnValue = lib_enroll_process(remaining_touches);
    return returnValue;
}

//----------------------------------------------------------------------------------------------------------------------
_Export_ int LibSdkEnrollVerify()
{
    int returnValue;
    returnValue = lib_enroll_verify();
    return returnValue;
}

_Export_ int LibSdkValidateFingerprint(void)
{
    int returnValue;
    returnValue = lib_enroll_validate();
    return returnValue;
}
