#include "stdint.h"
#include "string.h"
#include "uECC.h"
#include "sha.h"
#include "sha3.h"
#include "aes.h"
#include "wrapper.h"


static uint8_t lib_tmp[64] = { 0x05, 0x8E, 0xD0, 0x52, 0x79, 0x14, 0xC9, 0xBD, 0xBC, 0x01, 0x99, 0x29, 0x37, 0x24, 0x5F, 0x7E, 0x9E, 0x18, 0x52, 0xA4, 0xC7, 0x4B, 0x95, 0x98, 0x5C, 0xDA, 0xC5, 0xCA, 0xB5, 0x5B, 0x3C, 0x1D, 0x16, 0x05, 0x8C, 0x28, 0x34, 0x88, 0xA1, 0x6E, 0x60, 0x21, 0x06, 0x7D, 0xA8, 0x01, 0xCE, 0x5E, 0x52, 0x33, 0x3A, 0x72, 0xB8, 0x86, 0x16, 0x35, 0xC6, 0x93, 0x90, 0x1A, 0x4D, 0xE0, 0xBC, 0x5D };

static uint8_t sd_public_key[64];

static uint8_t private_key[32];
static uint8_t public_key[64];
static uint8_t signature[64];
static uint8_t secret_shsee[32];
static uint8_t secret_shses[32];
static uint8_t pub[64];


static uint8_t Chaining[16] = { 0x92, 0xE5, 0x8D, 0x51, 0x14, 0x6F, 0x1D, 0x12, 0x29, 0x39, 0x22, 0x6B, 0xD2, 0x0F, 0x09, 0xEB };

static uint8_t KeyRespt[16];
static uint8_t KeyENC[16] = { 0x87, 0x83, 0x23, 0xDE, 0xEC, 0x1F, 0xB5, 0x58, 0xCA, 0x79, 0x4F, 0x78, 0xC4, 0x27, 0x8F, 0xD1 };
static uint8_t KeyCMAC[16] = { 0x51, 0x4A, 0x67, 0xDD, 0xB2, 0xC3, 0xC1, 0x44, 0xBB, 0xAC, 0x57, 0xFF, 0x0F, 0x94, 0xA4, 0x7F };
static uint8_t KeyRMAC[16] = { 0xA4, 0xCF, 0xB3, 0x47, 0x76, 0xCD, 0xFB, 0x91, 0x13, 0x27, 0x54, 0x8A, 0x63, 0x4D, 0x6A, 0xCA };

static uint8_t ApduInternalAuth[] = { 0x80, 0x88, 0x18, 0x13, 0x53, 0xA6, 0x0D, 0x90, 0x02, 0x11, 0x00, 0x95, 0x01, 0x3C, 0x80, 0x01, 0x88, 0x81, 0x01, 0x10, 0x5F, 0x49, 0x41, 0x04, 0x6A, 0x02, 0x83, 0x8F, 0x28, 0xDD, 0xBC, 0x54, 0x0D, 0xC7, 0x1F, 0x64, 0xB2, 0x8B, 0xC9, 0x65, 0xC8, 0xC9, 0x88, 0xB9, 0x72, 0xA7, 0x67, 0xF0, 0x14, 0x72, 0x73, 0x0A, 0x3B, 0xBF, 0x3F, 0x04, 0xD1, 0xE4, 0x20, 0x4A, 0x47, 0x0F, 0x97, 0x4F, 0xEB, 0x14, 0x3B, 0xA1, 0x0D, 0x1B, 0xF5, 0xDC, 0x18, 0xB0, 0xE2, 0xDC, 0xA8, 0xDF, 0xB1, 0x60, 0xA0, 0x3F, 0x3A, 0x46, 0xED, 0xD4, 0xC5, 0x98, 0x00 };

static uECC_Curve curve;

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Input: NONE
// Output:  ApduInternal, len
int lib_auth_init(uint8_t *ApduInternal, int *len)
{
    int ret;
    int valid;
    uint8_t PubKey[65];
    uint8_t key_enc[16];
    uint8_t iv[16];
    uint8_t iv2[16];

    curve = uECC_secp256r1();
    ret = uECC_make_key(public_key, private_key, curve);
    
    do
    {
        ret = uECC_make_key(public_key, private_key, curve); //to-> *PubKey
        if (ret != 1) return -100;
        valid = uECC_valid_public_key(public_key, curve);
        if (valid == 1)
        {
            memcpy(key_enc, private_key, 16);
            memcpy(iv, private_key, 16);
            memcpy(iv2, private_key+16, 16);
        }
    } while (valid != 1);

    {
        for (int i = 0; i < 16; i++)
        {
            AES_128_CBC_Decrypt(key_enc, lib_tmp, sd_public_key, 64, iv2);
            uint8_t dt = iv[i] ^ key_enc[i];
            iv[i] = dt - 1;
            key_enc[i] = dt;
        }
        AES_128_CBC_Decrypt(key_enc, lib_tmp, sd_public_key, 64, iv);
    }

    ret = uECC_shared_secret(sd_public_key, private_key, secret_shses, curve);//to-> static SecretKey
    if (ret != 1) return -101;
    PubKey[0] = 4;
    memcpy(PubKey + 1, public_key, 64);
    memcpy(ApduInternalAuth + 23, PubKey, 65);
    memcpy(ApduInternal, ApduInternalAuth, sizeof(ApduInternalAuth));
    len[0] = sizeof(ApduInternalAuth);
    return 0;
}

//--------------------------------------------------------------------------------------------------------------------------------------------------------
//Input: PubKey 04 xxxx
//Calc: SecretKeys
int lib_auth_ecdh_kdf(uint8_t* PubKey )
{
    int ret;
    uint8_t SecretKeys[250];
    uint8_t shared_secret[256];
    //PubKey[0] = 4;
    memcpy(pub, PubKey + 1, 64);
    curve = uECC_secp256r1();
    ret = uECC_shared_secret(pub, private_key, secret_shsee, curve);
    if (ret != 1) return -102;
    memcpy(shared_secret + 0, secret_shsee, 32);
    memcpy(shared_secret + 32, secret_shses, 32);

    shared_secret[64] = 0x00;
    shared_secret[65] = 0x00;
    shared_secret[66] = 0x00;
    shared_secret[67] = 0x01;

    shared_secret[68] = 0x3C;
    shared_secret[69] = 0x88;
    shared_secret[70] = 0x10;

    SHA256(shared_secret, 71, SecretKeys);
    shared_secret[67] = 0x02;
    SHA256(shared_secret, 71, SecretKeys + 32);
    shared_secret[67] = 0x03;
    SHA256(shared_secret, 71, SecretKeys + 64);

    memcpy(KeyRespt, SecretKeys + 0, 16);
    memcpy(KeyENC, SecretKeys + 16, 16);
    memcpy(KeyCMAC, SecretKeys + 32, 16);
    memcpy(KeyRMAC, SecretKeys + 48, 16);
    return 0;
}

//--------------------------------------------------------------------------------------------------------------------------------------------------------
int lib_auth_wrapper_init(uint8_t* chaining)
{
    wrapper_init(chaining);
    return 0;
}
//--------------------------------------------------------------------------------------------------------------------------------------------------------
int lib_auth_wrap(uint8_t* apdu_in, uint32_t in_len, uint8_t* apdu_out, uint32_t* out_len)
{
    if (in_len < 5) return -1;
    wrap(apdu_in, in_len, apdu_out, out_len, KeyENC, KeyCMAC);
    return 0;
}

//--------------------------------------------------------------------------------------------------------------------------------------------------------
int lib_auth_unwrap(uint8_t* apdu_in, uint32_t in_len, uint8_t* apdu_out, uint32_t* out_len)
{
    return unwrap(apdu_in, in_len, apdu_out, out_len, KeyENC, KeyRMAC);
}
//--------------------------------------------------------------------------------------------------------------------------------------------------------
int lib_public_decompress(uint8_t* Compress, uint8_t* Decompress)
{
    if (Compress[0] != 0x03 && Compress[0] != 0x02)
    {
        return -1;
    }
    curve = uECC_secp256k1();
    uECC_decompress(Compress, Decompress, curve);
    return 0;
}
//----------------------------------------------------------------------------------------------------------------------
int lib_ripemd160(uint8_t* Data, int DataLen, uint8_t* SHA160)
{
    ripemd160(Data, DataLen, SHA160);
    return 0;
}
//----------------------------------------------------------------------------------------------------------------------
int lib_sha160(uint8_t* Data, int DataLen, uint8_t* SHA160)
{
    uint8_t Digest[32];
    SHA256(Data, (uint16_t)DataLen, Digest);
    ripemd160(Digest, 32, SHA160);
    return 0;
}
//----------------------------------------------------------------------------------------------------------------------
int lib_sha2_256(uint8_t* Data, int DataLen, uint8_t* _SHA256)
{
    SHA256(Data, (uint16_t)DataLen, _SHA256);
    return 0;
}
//----------------------------------------------------------------------------------------------------------------------
int lib_sha2_256D(uint8_t* Data, int DataLen, uint8_t* _SHA256)
{
    uint8_t temp32[32];
    SHA256(Data, (uint16_t)DataLen, temp32);
    SHA256(temp32, 32, _SHA256);
    return 0;
}
//----------------------------------------------------------------------------------------------------------------------
int lib_sha3_256(uint8_t* Data, int DataLen, uint8_t* _SHA256)
{
    BRKeccak256(_SHA256, Data, DataLen);
    return 0;
}
//----------------------------------------------------------------------------------------------------------------------
int lib_wallet_public_verify_sign_hash(uint8_t* Compress, uint8_t* Hash, uint8_t* Sign)
{
    if (Compress[0] != 0x03 && Compress[0] != 0x02)
    {
        return -1;
    }
    int Ret;
    uint8_t Decompress[64];
    uECC_Curve curve2;
    curve2 = uECC_secp256k1();
    uECC_decompress(Compress, Decompress, curve2);
    Ret = uECC_verify(Decompress, Hash, 32, Sign, curve2);
    if (Ret == 1)
    {

        return 0;
    }

    return 100;
}
//----------------------------------------------------------------------------------------------------------------------
