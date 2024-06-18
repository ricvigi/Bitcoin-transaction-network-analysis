import json, subprocess, signal
from io import BytesIO
from tx import Tx
from ecc import S256Point
from processing_helper_functions import main

filepaths = [f"tseries/APIrequests/0bigsequence/500{x}.json" for x in range(538, 601)]

if __name__ == "__main__":

  for filepath in filepaths:
    with open(filepath, 'r') as file:
        text = file.read()
        data = json.loads(text)

    main(data)
