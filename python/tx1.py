from helper1 import (little_endian_to_int)
from script import Script
from io import BytesIO

import json
import requests

from helper import (
    encode_varint,
    hash256,
    int_to_little_endian,
    little_endian_to_int,
    read_varint,
)


class Tx:

    def __init__(self, version, tx_ins, tx_outs, locktime, testnet=False):
        self.version = version
        self.tx_ins = tx_ins
        self.tx_outs = tx_outs
        self.locktime = locktime
        self.testnet = testnet

    def __repr__(self):
        tx_ins = ''
        for tx_in in self.tx_ins:
            tx_ins += tx_in.__repr__() + '\n'
        tx_outs = ''
        for tx_out in self.tx_outs:
            tx_outs += tx_out.__repr__() + '\n'
        return 'tx: {}\nversion: {}\ntx_ins:\n{}tx_outs:\n{}locktime: {}'.format(self.id(),
                   self.version,
                   tx_ins,
                   tx_outs,
                   self.locktime,
                   )

    def id(self):
        '''Human-readable hexadecimal of the transaction hash'''
        return self.hash().hex()

    def hash(self):
        '''Binary hash of the legacy serialization'''
        return hash256(self.serialize())[::-1]

    @classmethod # this method has to be a class method a the serialization will return a new instance of a Tx object
    def parse(cls, s, testnet=False):
        version = little_endian_to_int(s.read(4))
        num_inputs = read_varint(s)
        inputs = []
        for _ in range(num_inputs):
            inputs.append(TxIn.parse(s))
        num_outputs = read_varint(s)
        outputs = []
        for _ in range(num_outputs):
            outputs.append(TxOut.parse(s))
        locktime = little_endian_to_int(s.read(4))
        return cls(version, inputs, outputs, locktime, testnet=testnet)

    def parse_version(cls, s, testnet=False):
        version = little_endian_to_int(s.read(4))
        return cls(version, None, None, None, testnet=testnet)

    def serialize(self):
        '''Returns the byte serialization of the transaction'''
        result = int_to_little_endian(self.version, 4)
        result += encode_varint(len(self.tx_ins))
        for tx_in in self.tx_ins:
            result += tx_in.serialize()
        result += encode_varint(len(self.tx_outs))
        for tx_out in self.tx_outs:
            result += tx_out.serialize()
        result += int_to_little_endian(self.locktime, 4)
        return result

    def fee(self, testnet=False):
        input_sum, output_sum = 0, 0
        for tx_in in self.tx_ins:
            input_sum += tx_in.value(testnet=testnet)
        for tx_out in self.tx_outs:
            output_sum += tx_out.amount
        fee = input_sum - output_sum
        return fee

class TxIn:

    def __init__(self, prev_tx, prev_index, script_sig=None, sequence=0xffffffff):
        self.prev_tx = prev_tx
        self.prev_index = prev_index
        if script_sig is None:
            self.script_sig = Script() # We default to an empty ScriptSig
        else:
            self.script_sig = script_sig
        self.sequence = sequence

    def __repr__(self):
        return '{}:{}'.format(self.prev_tx.hex(), self.prev_index,)

    @classmethod
    def parse(cls, s):
        '''Takes a byte stream and parses the tx_input at the start. Returns a TxIn object'''
        prev_tx = s.read(32)[::-1]
        prev_index = little_endian_to_int(s.read(4))
        script_sig = Script.parse(s)
        sequence = little_endian_to_int(s.read(4))
        return cls(prev_tx, prev_index, script_sig, sequence)

    def serialize(self):
        '''Returns the byte serialization of the transaction input'''
        result = self.prev_tx[::-1]
        result += int_to_little_endian(self.prev_index, 4)
        result += self.script_sig.serialize()
        result += int_to_little_endian(self.sequence, 4)
        return result

    def fetch_tx(self, testnet=False):
        return TxFetcher.fetch(self.prev_tx.hex(), testnet=testnet)

    def value(self, testnet=False):
        '''Get the output value by looking up the txhash. Returns the amount in satoshi'''
        tx = self.fetch_tx(testnet=testnet)
        return tx.tx_outs[self.prev_index].amount / 100000000

    def script_pubkey(self, testnet=False):
        '''Get the ScriptPubKey by looking up the tx hash. Returns a Script object'''
        tx = self.fetch_tx(testnet=testnet)
        return tx.tx_outs(self.prev_index).script_pubkey

class TxOut:

    def __init__(self, amount, script_pubkey):
        self.amount = amount
        self.script_pubkey = script_pubkey

    def __repr__(self):
        return '{}:{}'.format(self.amount, self.script_pubkey)

    @classmethod
    def parse(cls, s):
        '''Takes a byte stream and parses the tx_output at the start. Returns a TxOut object'''
        amount = little_endian_to_int(s.read(8))
        script_pubkey = Script.parse(s)
        return cls(amount, script_pubkey)

    def serialize(self):
        '''Returns the byte serialization of the transaction output'''
        result = int_to_little_endian(self.amount, 8)
        result += self.script_pubkey.serialize()
        return result


    def value(self):
        return self.amount / 100000000

class TxFetcher:
    cache = {}

    @classmethod
    def get_url(cls, testnet=False):
        if testnet:
            return 'https://blockstream.info/testnet/api/'
        else:
            return 'https://blockstream.info/api/'

    @classmethod
    def fetch(cls, tx_id, testnet=False, fresh=False):
        if fresh or (tx_id not in cls.cache):
            url = '{}/tx/{}/hex'.format(cls.get_url(testnet), tx_id)
            response = requests.get(url)
            try:
                raw = bytes.fromhex(response.text.strip()) # NOTE: this "raw" object can be found with key "hex" in transaction json
            except ValueError:
                raise ValueError('unexpected response: {}'.format(response.text))
            if raw[4] == 0:
                raw = raw[:4] + raw[6:]
                tx = Tx.parse(BytesIO(raw), testnet=testnet)
                tx.locktime = little_endian_to_int(raw[-4:])
            else:
                tx = Tx.parse(BytesIO(raw), testnet=testnet)
            if tx.id() != tx_id:  # <1>
                raise ValueError('not the same id: {} vs {}'.format(tx.id(),
                                  tx_id))
            cls.cache[tx_id] = tx
        cls.cache[tx_id].testnet = testnet
        return cls.cache[tx_id]

    @classmethod
    def fetchraw(cls, rawtx, testnet=False, fresh=False):
        raw = bytes.fromhex(rawtx.strip()) # maybe remove the strip() method
        if raw[4] == 0:
            raw = raw[:4] + raw[6:]
            tx = Tx.parse(BytesIO(raw), testnet=testnet)
            tx.locktime = little_endian_to_int(raw[-4:])
        else:
            tx = Tx.parse(BytesIO(raw), testnet=testnet)
        cls.cache[tx.id()] = tx
        cls.cache[tx.id()].testnet = testnet
        return cls.cache[tx.id()]
