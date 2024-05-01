#ifndef __secure_module_auth__
#include "stdint.h"

int lib_auth_init(uint8_t* ApduInternal, int* len);
int lib_auth_ecdh_kdf(uint8_t* PubKey);
int lib_auth_wrapper_init(uint8_t* chaining);
int lib_auth_wrap(uint8_t* apdu_in, uint32_t in_len, uint8_t* apdu_out, uint32_t* out_len);
int lib_auth_unwrap(uint8_t* apdu_in, uint32_t in_len, uint8_t* apdu_out, uint32_t* out_len);

int lib_public_decompress(uint8_t* Compress, uint8_t* Decompress);

int lib_sha160(uint8_t* Data, int DataLen, uint8_t* SHA160);
int lib_ripemd160(uint8_t* Data, int DataLen, uint8_t* SHA160);
int lib_sha2_256(uint8_t* Data, int DataLen, uint8_t* SHA256);
int lib_sha2_256D(uint8_t* Data, int DataLen, uint8_t* SHA256);
int lib_sha3_256(uint8_t* Data, int DataLen, uint8_t* SHA256);

int lib_wallet_public_verify_sign_hash(uint8_t* Compress, uint8_t* Hash, uint8_t* Sign);





#endif // !__secure_module_auth__

