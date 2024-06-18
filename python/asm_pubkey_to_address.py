import hashlib
import base58
import argparse

# Step 1: Extract the public key
public_key = "0496b538e853519c726a2c91e61ec11600ae1390813a627c66fb8be7947be63c52da7589379515d4e0a604f8141781e62294721166bf621e73a82cbf2342c858ee"

def derive_address(key:str) -> str:

    # Compute the SHA-256 hash of the public key
    sha256_hash = hashlib.sha256(bytes.fromhex(public_key)).digest()

    # Compute the RIPEMD-160 hash of the SHA-256 hash
    ripemd160 = hashlib.new('ripemd160')
    ripemd160.update(sha256_hash)
    public_key_hash = ripemd160.digest()

    # Add the version byte in front of the RIPEMD-160 hash
    version_byte = b'\x00'
    extended_ripemd160 = version_byte + public_key_hash

    # Compute the checksum
    checksum = hashlib.sha256(hashlib.sha256(extended_ripemd160).digest()).digest()[:4]

    # Construct the binary Bitcoin address
    binary_address = extended_ripemd160 + checksum

    # Encode the binary address in Base58Check
    bitcoin_address = base58.b58encode(binary_address).decode('utf-8')

    print(bitcoin_address)
    return bitcoin_address

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description='Derive Bitcoin address from public key.')
    parser.add_argument('public_key', type=str, help='The public key in hex format')

    args = parser.parse_args()
    address = derive_address(args.public_key)
