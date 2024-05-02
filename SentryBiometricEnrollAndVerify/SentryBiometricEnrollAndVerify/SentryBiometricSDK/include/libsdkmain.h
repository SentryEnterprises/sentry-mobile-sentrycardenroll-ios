//
//  libsdkmain.h
//
//
//  Created by John Ayres on 4/29/24.
//

#ifndef __lib_main_header__

#include "stdint.h"

#ifdef _WINDOWS
#define DllExport   __declspec( dllexport )
#define  _Export_ DllExport
#endif

#ifdef __ANDROID__
#define  _Export_ extern
#endif

#ifdef __APPLE__
#define  _Export_ extern
#endif

#include "wrapper.h"


//------------------------------------------------------------------------------------
// TODO: May not expose this
_Export_ int LibSdkEnrollSelect(SmartCardApduCallBack callback);

_Export_ int LibSdkEnrollInit(uint8_t* pin, int len, SmartCardApduCallBack callback);
_Export_ int LibSdkEnrollDeinit(void);
_Export_ int LibSdkGetEnrollStatus(uint8_t* max_num_fingers, uint8_t* enrolled_touches, uint8_t* remaining_touches, uint8_t* biometric_mode);
//_Export_ int LibSdkEnrollProcess(int num_finger, uint8_t* enrolled_touches, uint8_t* remaining_touches, uint8_t* biometric_mode);
//_Export_ int LibSdkEnrollReprocess(int num_finger, uint8_t* enrolled_touches, uint8_t* remaining_touches, uint8_t* biometric_mode);
//_Export_ int LibSdkEnrollVerify(void);


#endif // !__lib_main_header__



