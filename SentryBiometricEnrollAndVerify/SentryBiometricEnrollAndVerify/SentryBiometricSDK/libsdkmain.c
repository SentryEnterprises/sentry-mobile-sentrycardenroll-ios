//
//  libsdkmain.c
//  
//
//  Created by John Ayres on 4/29/24.
//

#include "stdint.h"
#include "string.h"

#include "libsdkmain.h"
//#include "lib_wallet.h"
#include "secure.h"
#include "wrapper.h"
#include "libsdkmain.h"
#include "lib_sdk_enroll.h"
//#include "support.h"


////----------------------------------------------------------------------------------------------------------------------
////typedef int (*SmartCardApduCallBack)(uint8_t* DataIn, uint32_t DataInLen, uint8_t* DataOut, uint32_t* DataOutLen);
////----------------------------------------------------------------------------------------------------------------------

////----------------------------------------------------------------------------------------------------------------------
//_Export_ int LibSdkGetSdkVersion(uint8_t* version)
//{
//    return lib_sdk_get_version(version);
//}
////----------------------------------------------------------------------------------------------------------------------
//_Export_ int LibSdkGetCapability(uint8_t* capability)
//{
//    return lib_sdk_get_capability(capability);
//}
////----------------------------------------------------------------------------------------------------------------------
//_Export_ int LibSdkStorePin(uint8_t* pin, int len)
//{
//    return lib_wallet_store_pin(pin, len);
//}
////----------------------------------------------------------------------------------------------------------------------
//_Export_ int LibSdkVerifyPin(uint8_t* pin, int len)
//{
//    return lib_wallet_verify_pin(pin, len);
//}
////----------------------------------------------------------------------------------------------------------------------
//_Export_ int LibSdkGetGGUID(uint8_t* gguid)
//{
//    return lib_wallet_get_gguid(gguid);
//}

////----------------------------------------------------------------------------------------------------------------------
//_Export_ int LibSdkGetOSVersion(uint8_t* version)
//{
//    return lib_os_get_version(version);
//}
////----------------------------------------------------------------------------------------------------------------------
//_Export_ int LibSdkGetStatus(uint8_t* GWLCS, uint8_t* WPSM, uint8_t* WSSM)
//{
//    return lib_wallet_get_status(GWLCS, WPSM, WSSM);
//}
////----------------------------------------------------------------------------------------------------------------------



/// Verified to work

// TODO: May not expose this
_Export_ int LibSdkEnrollSelect(SmartCardApduCallBack callback)
{
    int returnValue;
    ApduIsSecureChannel = 0;
    pSmartCardApduCallBack = callback;
    if (callback == NULL) return _SDK_ERROR_NULL_CALLBACK_;
    
    returnValue = lib_enroll_select();
    return returnValue;
}


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
_Export_ int LibSdkEnrollVerify(uint8_t* pin, int len)
{
    int returnValue;
    returnValue = lib_enroll_verify();
    //returnValue = lib_verify_enrollment(pin, len);
    return returnValue;
}

///





////----------------------------------------------------------------------------------------------------------------------
//_Export_ int LibSdkEnrollProcess(int num_finger, uint8_t* enrolled_touches, uint8_t* remaining_touches, uint8_t* biometric_mode)
//{
//    int Ret;
//    Ret = lib_enroll_process(num_finger, enrolled_touches, remaining_touches, biometric_mode);
//    return Ret;
//}
////----------------------------------------------------------------------------------------------------------------------
//_Export_ int LibSdkEnrollReprocess(int num_finger, uint8_t* enrolled_touches, uint8_t* remaining_touches, uint8_t* biometric_mode)
//{
//    int Ret;
//    Ret = lib_enroll_reprocess(num_finger, enrolled_touches, remaining_touches, biometric_mode);
//    return Ret;
//}
////----------------------------------------------------------------------------------------------------------------------
//_Export_ int LibSdkEnrollVerify(void)
//{
//    int Ret;
//    Ret = lib_enroll_verify();
//    return Ret;
//}
//----------------------------------------------------------------------------------------------------------------------














//_Export_ int LibSdkPublicKeyDecompress(uint8_t* Compress, uint8_t* Decompress)
//{
//    return lib_public_decompress(Compress, Decompress);
//}
////----------------------------------------------------------------------------------------------------------------------
//_Export_ int LibSdkRipemd160(uint8_t* Data, int DataLen, uint8_t* SHA160)
//{
//    return lib_ripemd160(Data, DataLen, SHA160);
//}
////----------------------------------------------------------------------------------------------------------------------
//_Export_ int LibSdkHash160(uint8_t* Data, int DataLen, uint8_t* SHA160)
//{
//    return lib_sha160(Data, DataLen, SHA160);
//}
////----------------------------------------------------------------------------------------------------------------------
//_Export_ int LibSdkKeccak256(uint8_t* Data, int DataLen, uint8_t* _SHA256)
//{
//    return lib_sha3_256(Data, DataLen, _SHA256);
//}
////----------------------------------------------------------------------------------------------------------------------
//_Export_ int LibSdkSha256(uint8_t* Data, int DataLen, uint8_t* _SHA256)
//{
//    return lib_sha2_256(Data, DataLen, _SHA256);
//}
////----------------------------------------------------------------------------------------------------------------------
//_Export_ int LibSdkSha256D(uint8_t* Data, int DataLen, uint8_t* _SHA256)
//{
//    return lib_sha2_256D(Data, DataLen, _SHA256);
//}
////----------------------------------------------------------------------------------------------------------------------
////----------------------------------------------------------------------------------------------------------------------
//_Export_ int LibSdkVerifyPublicSignHash(uint8_t* Compress, uint8_t* Hash, uint8_t* Sign)
//{
//    return lib_wallet_public_verify_sign_hash(Compress, Hash, Sign);
//}
////----------------------------------------------------------------------------------------------------------------------
//_Export_ int LibSdkAddressToScript(uint8_t* Address, int Len, uint8_t* Script, uint32_t* ScriptLen)
//{
//    return lib_address_to_script(Address, Len, Script, ScriptLen);
//}
////----------------------------------------------------------------------------------------------------------------------
//_Export_ int LibSdkBip143(uint8_t* Inputs, int InputCount, uint8_t* Outputs, int OutputCount, uint32_t LockTime, uint8_t* Trx, uint32_t* TrxLen, uint8_t* TrxHash)
//{
//    return lib_bip143(Inputs, InputCount, Outputs, OutputCount, LockTime, Trx, TrxLen, TrxHash);
//}
////----------------------------------------------------------------------------------------------------------------------
//_Export_ int LibSdkWalletGetAddress(uint8_t* Address, uint32_t* AddressLen)
//{
//    return lib_wallet_get_address(Address, AddressLen);
//}
////----------------------------------------------------------------------------------------------------------------------
//_Export_ int LibSdkEip1559(
//    uint8_t* chain_id,
//    uint8_t* nonce,
//    uint8_t* max_priority_fee_per_gas,
//    uint8_t* max_fee_per_gas,
//    uint8_t* gas_limit,
//    uint8_t* destination,
//    uint8_t* amount,
//    uint8_t* data,
//    uint8_t* access_list,
//    uint8_t* Trx, uint32_t* TrxLen, uint8_t* TrxHash)
//{
//    return lib_eip1559(
//        chain_id,
//        nonce,
//        max_priority_fee_per_gas,
//        max_fee_per_gas,
//        gas_limit,
//        destination,
//        amount,
//        data,
//        access_list,
//        Trx, TrxLen, TrxHash);
//
//}
////----------------------------------------------------------------------------------------------------------------------



//----------------------------------------------------------------------------------------------------------------------


