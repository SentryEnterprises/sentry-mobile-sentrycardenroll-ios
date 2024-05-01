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
//_Export_ int LibSdkWalletInit(int SecureChannel, SmartCardApduCallBack callback)
//{
//    int Ret;
//    uint8_t vers[8];
//    ApduIsSecureChannel = 0;
//    pSmartCardApduCallBack = callback;
//    if (callback == NULL) return -1;
//    Ret = lib_wallet_init(SecureChannel);
//    if (SecureChannel > 0 && Ret==0)
//    {
//        ApduIsSecureChannel = SecureChannel;
//    }
//
//    Ret = lib_wallet_get_version(vers);
//    if (Ret != 0) return Ret;
//    if (vers[0] != 0x02) return _SDK_ERROR_CRITERION_;
//    if (vers[1] == 0x00) return _SDK_ERROR_CRITERION_;
//    if (vers[1] > 0x01) return 0;
//    if (vers[2] < 28) return _SDK_ERROR_CRITERION_;
//
//    return Ret;
//}
////----------------------------------------------------------------------------------------------------------------------
//_Export_ int LibSdkWalletDeinit(void)
//{
//    ApduIsSecureChannel = 0;
//    pSmartCardApduCallBack = NULL;
//    lib_wallet_deinit();
//    return 0;
//}
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
//_Export_ int LibSdkGetWalletVersion(uint8_t* version)
//{
//    return lib_wallet_get_version(version);
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
//_Export_ int LibSdkGetAccounts(uint8_t* NumberAccounts, uint8_t* AccountInfo)
//{
//    return lib_wallet_get_accounts(NumberAccounts, AccountInfo);
//}
////----------------------------------------------------------------------------------------------------------------------
//_Export_ int LibSdkCreateWallet(int Iteration, int Words, int Lang, uint8_t* passphrase, int len_passphrase, uint8_t* mnemonics, int* len_mnemonic)
//{
//    return lib_wallet_create(Iteration, Words, Lang, passphrase, len_passphrase,  mnemonics, len_mnemonic);
//}
////----------------------------------------------------------------------------------------------------------------------
//_Export_ int LibSdkRecoveryWallet(int Iteration, uint8_t* mnemonics, int len_mnemonics, uint8_t* passphrase, int len_passphrase)
//{
//    return lib_wallet_recovery(Iteration, mnemonics, len_mnemonics, passphrase, len_passphrase);
//}
////----------------------------------------------------------------------------------------------------------------------
//_Export_ int LibSdkAccountCreate(uint32_t currID, uint8_t netID, uint8_t accountID, uint8_t chain, uint8_t bip, uint8_t* nickname, int len_nick)
//{
//    return lib_wallet_account_create(currID, netID, accountID, chain, bip, nickname, len_nick);
//}
////----------------------------------------------------------------------------------------------------------------------
//_Export_ int LibSdkSelectAccount(int AccountIndex)
//{
//    return lib_wallet_select_account(AccountIndex);
//}
////----------------------------------------------------------------------------------------------------------------------
//_Export_ int LibSdkAccountGetStatus(uint8_t* ALC, uint8_t* WSSM)
//{
//    return lib_wallet_get_status_account(ALC,  WSSM);
//}
////----------------------------------------------------------------------------------------------------------------------
//_Export_ int LibSdkAccountGetPublicKey(uint8_t* AccountPublicKey,  uint8_t* AccountChainCodeKey, uint8_t* PublicKeyParent)
//{
//    return lib_wallet_get_publickey_account(AccountPublicKey, AccountChainCodeKey, PublicKeyParent);
//}
////----------------------------------------------------------------------------------------------------------------------
//_Export_ int LibSdkAccountGetReceivePublicKey(uint8_t* AccountPublicKey)
//{
//    return lib_wallet_get_receive_publickey_account(AccountPublicKey);
//}
////----------------------------------------------------------------------------------------------------------------------
//_Export_ int LibSdkAccountGetAddressIndex(uint16_t *AddressIndex)
//{
//    return lib_wallet_get_address_index(AddressIndex);
//}
////----------------------------------------------------------------------------------------------------------------------
//_Export_ int LibSdkAccountGetChainIndex(uint8_t* ChainIndex)
//{
//    return lib_wallet_get_chain_index(ChainIndex);
//}
////----------------------------------------------------------------------------------------------------------------------
//_Export_ int LibSdkAccountSetAddressIndex(uint16_t AddressIndex)
//{
//    return lib_wallet_set_address_index(AddressIndex);
//}
////----------------------------------------------------------------------------------------------------------------------
//_Export_ int LibSdkAccountSetChainIndex(uint8_t ChainIndex)
//{
//    return lib_wallet_set_chain_index(ChainIndex);
//}
////----------------------------------------------------------------------------------------------------------------------
//_Export_ int LibSdkAccountSignHash( uint8_t* Hash, int len_hash, uint8_t* R, uint8_t* S, uint8_t *V)
//{
//    return lib_wallet_sign_hash(Hash, len_hash, R, S, V);
//}
////----------------------------------------------------------------------------------------------------------------------
//_Export_ int LibSdkResetWallet(void)
//{
//    return lib_wallet_reset();
//}
////----------------------------------------------------------------------------------------------------------------------
//_Export_ int LibSdkSelectWallet(void)
//{
//    if (ApduIsSecureChannel > 0)
//    {
//        return lib_wallet_select_wallet_sc();
//    }
//    else
//    {
//        return lib_wallet_select_wallet();
//    }
//}
////----------------------------------------------------------------------------------------------------------------------
//_Export_ int LibSdkWalletGetCVMStatus(uint8_t* CVM, uint8_t* WSSM)
//{
//    return lib_wallet_get_cvm_status(CVM, WSSM);
//}
////----------------------------------------------------------------------------------------------------------------------
//_Export_ int LibSdkWalletCVMVerify(uint8_t* CVM, uint8_t* WSSM)
//{
//    return lib_wallet_get_cvm_verify(CVM, WSSM);
//}
////----------------------------------------------------------------------------------------------------------------------
//_Export_ int LibSdkWalletCVMDisablePin(void)
//{
//    return lib_wallet_cvm_disable_pin();
//}
////----------------------------------------------------------------------------------------------------------------------
///
///
///
///
///
///
///
///
///
///
///
///

_Export_ int LibSdkEnrollSelect(SmartCardApduCallBack callback)
{
    int Ret;
    ApduIsSecureChannel = 0;
    pSmartCardApduCallBack = callback;
    if (callback == NULL) return -1;
    
    Ret = lib_enroll_select();
    
    return Ret;
}
//----------------------------------------------------------------------------------------------------------------------
_Export_ int LibSdkEnrollInit(uint8_t* pin, int len, SmartCardApduCallBack callback)
{
    int Ret;
    ApduIsSecureChannel = 0;
    pSmartCardApduCallBack = callback;
    if (callback == NULL) return -1;
 //   lib_wallet_deinit();
    Ret = lib_enroll_init(pin, len);
 //   Ret = lib_enroll_select();
    return Ret;
}
//----------------------------------------------------------------------------------------------------------------------
_Export_ int LibSdkEnrollDeinit(void)
{
    ApduIsSecureChannel = 0;
    pSmartCardApduCallBack = NULL;
    return 0;
}
////----------------------------------------------------------------------------------------------------------------------
//_Export_ int LibSdkGetEnrollStatus(uint8_t* max_num_fingers, uint8_t* enrolled_touches, uint8_t* remaining_touches, uint8_t* biometric_mode)
//{
//    int Ret;
//    Ret = lib_enroll_status(max_num_fingers, enrolled_touches, remaining_touches, biometric_mode);
//    return Ret;
//}
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


