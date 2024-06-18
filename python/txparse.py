import subprocess, json

if __name__ == "__main__":
    block_number = 125156
    subprocess.run(["zsh", ["-c", "listblock", str(block_number)]])


