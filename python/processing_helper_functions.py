import json, subprocess, signal, pprint
from io import BytesIO
from tx import Tx
from ecc import S256Point


def get_transactions_from_block(block:dict):
    '''Queries the blockchain for data about all transactions in a block and stores them in json files in the working directory'''
    script_path = "/home/rick/Desktop/2ndSemester/DMAU2/project/search_transactions.sh"
    for tx in block['tx'][1:]:
        try:
            res = subprocess.run(["zsh", script_path, tx, block['hash']], check=True, capture_output=True, text=True)
            if res.stderr:
                print(res.stderr)
        except subprocess.CalledProcessError as e:
            print(f"[*]ERROR: {e}")
    return

def recursive_back_search(tx, count, level):
     try:
        tabs = "|"*0
        if tx.is_coinbase():
            print(f"{tabs}[*]COINBASE REACHED: {tx.id()}")
            return
        if not tx.verify():
            print(f"{tabs}[*]FATAL ERROR: Transaction {tx.id()} is creating money!")
            return
        print(f"{tabs}[*]Transaction {tx.id()}")
        print(f"{tabs}[-]INPUTS:")
        for k in range(len(tx.tx_ins)):
            print(f"{tabs}\t[-]INPUT-ID:{tx.tx_ins[k].prev_tx.hex()}")
        amount = 0
        num_outputs = 0
        for out in tx.tx_outs:
            num_outputs += 1
            amount += out.amount
        amount += tx.fee()
        print(f"{tabs}[-]TOTAL OUTPUT: {amount}\n[-]HOP: {count}\n[-]LEVEL: {level}")
        for i in range(len(tx.tx_ins)):
            txi = tx.tx_ins[i].fetch_tx()
            recursive_back_search(txi, count + 1, level + 1)
        print(f"END, LEVEL{level}")
     except:
        print(f"[*] PARSING ERROR AT LEVEL {level}, TXID {tx.id()}")
        return
     return

def foo(SECONDS, func, *args, **kwargs):
    signal.signal(signal.SIGALRM, timeout_handler)
    signal.alarm(SECONDS)
    try:
        recursive_back_search(*args, **kwargs)
    finally:
        signal.alarm(0)
    return

def main(block_json):
    # dictionary of everlasting sadness and sorrow
    ERRORS_COUNT = {"IndexError":0,
                    "KeyError":0,
                    "AttributeError":0,
                    "ValueError":0,
                    "SyntaxError":0}
    #data = json.loads(block_json) # this in case you want to parse the json file in here
    data = block_json
    script_path = "/home/rick/Desktop/2ndSemester/DMAU2/project/search_transactions.sh"
    hex_script_path = "/home/rick/Desktop/2ndSemester/DMAU2/project/get_transaction_hex.sh"
    result = []
    for t in data['tx']:
      try:
        #res = subprocess.run(["zsh", script_path, tx, data['hash']], check=True, capture_output=True, text=True) # NOTE: to run this command, you must be running the bitcoin-core software (bitcoind -printtoconsole). Moreover, this command returns a slightly different transaction JSON, compared to the blockchain.info API
        res = subprocess.run(["zsh", script_path, t], check=True, capture_output=True, text=True)
        try:
            tx = json.loads(res.stdout.encode(encoding="utf-8"))
        except:
            continue
        receivers = []
        tot = 0
        '''for i in range(len(tx['vout'])):
            if 'coinbase' in tx['vin'][0].keys(): # we skip the coinbase parsing... for now!
                continue
            if tx['vout'][i]['scriptPubKey']['type'] == 'pubkey':
                sec = tx['vout'][i]['scriptPubKey']['asm'][:-12] # extract the sec pubkey and remove the OP_CHECKSIG at the end
                receivers.append((S256Point.parse(bytes.fromhex(sec)).address(), tx['vout'][i]['value'])) # derive the public address as we will do below...
                tot += tx['vout'][i]['value']
                continue
            try:
                receivers.append((tx['vout'][i]['scriptPubKey']['address'], tx['vout'][i]['value'])) # get the public address of the receiver, and the amount he received
                tot += tx['vout'][i]['value']
            except KeyError:
                print(f"[*]KeyError, skipping {tx}")
                ERRORS_COUNT['KeyError'] += 1
                continue
        '''
        for k in range(len(tx['out'])): # Here we are parsing the receiving addresses from a different json than the one returned by the bitcoin-cli
            if "addr" in tx['out'][k].keys():
                try:
                    address = tx['out'][k]['addr']
                    value = tx['out'][k]['value']
                    receivers.append((address, value)) # get the public address of the receiver, and the amount he received
                    tot += value
                except KeyError as e:
                    print(f"[*]KeyError {e}, skipping {tx['hash']}")
                    ERRORS_COUNT['KeyError'] += 1
                    # ###### DEBUGGING CODE #######
                    # pprint.pprint(tx)
                    # return 1
                    # #############################
                    continue
        #stream = BytesIO(bytes.fromhex(tx['hex']))
        hx = subprocess.run(["zsh", hex_script_path, t], check=True, capture_output=True, text=True)
        try:
            stream = BytesIO(bytes.fromhex(hx.stdout))
        except Exception as e:
            print(f"[*]{e}, resuming")
            continue
        pprint.pprint(tx)
        tx = Tx.parse(stream)
        sec_pubkeys = [] # To see what addresses own the outputs that are input to each transaction, we take the SEC pubkey (uncompressed or compressed), and we derive the address from it
        for i in range(len(tx.tx_ins)):
          try:
            sec_pubkeys.append(tx.tx_ins[i].script_sig.cmds[1].hex()) # take the "second" element of the script sig, i.e. the SEC pubkey
          except IndexError:
            print(f"[*]IndexError, there's something wrong with sec pubkey {type(tx.tx_ins[i])}")
            ERRORS_COUNT['IndexError'] += 1
            # ###### DEBUGGING CODE #######
            # return 1
            # #############################
          except AttributeError:
            print(f"[*]AttributeError: 'int' object has no attribute 'hex'")
            ERRORS_COUNT['AttributeError'] += 1
            # ###### DEBUGGING CODE #######
            # return 1
            # #############################
        sender_addresses = [] # now we derive the addresses from the sec pubkeys we found. These addresses can be clustered together since they represent an entity (or a group of entities collaborating together) that has control over the private keys that generated these public keys (addresses).
        for sec in sec_pubkeys:
          try:
            sender_addresses.append(S256Point.parse(bytes.fromhex(sec)).address()) # In each SEC pubkey is encoded information about the public key on the ECC curve. Using finite field arithmetic over the standard encryption curve of bitcoin, we can derive the public address from the sec address.
          except ValueError:
            print(f"[*]ValueError for sec {bytes.fromhex(sec).hex()}. Possible parsing problem")
            ERRORS_COUNT['ValueError'] += 1
            # ###### DEBUGGING CODE #######
            # return 1
            # #############################
        print(f"[*]Transaction {tx.id()}\n\t[-]Sender: {sender_addresses}\n\t[-]Receivers: {receivers}\n\t[-]Total amount sent: {tot}")
        result.append({'id':tx.id(),'sender':[x for x in sender_addresses], 'receiver':[x for x in receivers]}) # Append to the result list a dictionary of all transaction information
      except SyntaxError as e:
        print(f"[ERROR] Error {e} in parsing transaction {tx['hash']}")
        ERRORS_COUNT['SyntaxError'] += 1
        # ###### DEBUGGING CODE #######
        # return 1
        # #############################
        continue
    try:
        make_txedgelist(data['hash'], data['height'])
        print(f"[*]SUCCESS in using make_txedgelist function on block {data['hash']}")
    except:
        path = f"tseries/APIrequests/0bigsequence/{data['height']}.txedgelist_{data['hash']}.csv"
        with open(path, "w") as file:
            type0 = 0
            type1 = 1
            file.write("sender,receiver,amount,type\n")
            for transaction in result:
                for sender in transaction['sender']:
                    file.write(f"{sender},{transaction['id']},NA,{type0}\n") # If it's an input, set type to 0
                for receiver in transaction['receiver']:
                    file.write(f"{transaction['id']},{receiver[0]},{receiver[1]},{type1}\n") # If it's an output, set type to 1
        print(f"tseries/txedgelist_{data['hash']}.csv written succesfully")

    try:
        make_txnodelist(result, data['hash'], data['height'])
        print(f"[*]SUCCESS in using make_txnodelist function on block {data['hash']}")
    except:
        path = f"tseries/APIrequests/0bigsequence/{data['height']}.txnodelist_{data['hash']}.csv"
        with open(path, "w") as file:
            file.write("name\n")
            names = []
            for transaction in result:
                names.append(transaction['id'])
                for sender in transaction['sender']:
                    names.append(sender)
                for receiver in transaction['receiver']:
                    names.append(receiver[0])
            names = set(names)
            for name in names:
                file.write(f"{name}\n")
        print(f"tseries/txedgelist_{data['hash']}.csv written succesfully")


    ##########################################################################################
    print(f"[*]END. Finished process with {sum([ERRORS_COUNT[x] for x in ERRORS_COUNT.keys()])} errors.\n\t{ERRORS_COUNT['IndexError']} IndexError\n\t{ERRORS_COUNT['KeyError']} KeyError\n\t{ERRORS_COUNT['AttributeError']} AttributeError\n\t{ERRORS_COUNT['ValueError']} ValueError\n\t{ERRORS_COUNT['SyntaxError']} SyntaxError")
    return

def make_txnodelist(transactions_list:list[dict], blockhash:str, height:str):
    '''Creates a txnodelist file'''
    path = f"tseries/APIrequests/0bigsequence/{height}.txnodelist_{blockhash}.csv"
    try:
        with open(path, "w") as file:
            file.write("name\n")
            names = []
            for transaction in transactions_list:
                names.append(transaction['id'])
                for sender in transaction['sender']:
                    names.append(sender)
                for receiver in transaction['receiver']:
                    names.apppend(receiver[0])
        names = set(names)
        for name in names:
            file.write(f"{name}\n")
        print(f"[*]tseries/txnodelist_{blockhash}.csv written succesfully")
    except:
        raise Exception(f"make_txnodelist did not work")
    return


def make_txedgelist(blockhash:str, height:str):
    '''Creates the texdgelist file'''
    path = f"tseries/APIrequests/0bigsequence/{height}.txedgelist_{blockhash}.csv"
    try:
        with open(path, "w") as file:
            type0 = 0
            type1 = 1
            file.write("sender,receiver,amount,type\n")
            for transaction in result:
                for sender in transaction['sender']:
                    file.write(f"{sender},{transaction['id']},NA,{type0}\n") # If it's an input, set type to 0
                for receiver in transaction['receiver']:
                    file.write(f"{transaction['id']},{receiver[0]},{receiver[1]},{type1}\n") # If it's an output, set type to 1
        print(f"[*]tseries/txedgelist_{blockhash}.csv written succesfully")
    except:
        raise Exception(f"make_txedgelist did not work")
    return
