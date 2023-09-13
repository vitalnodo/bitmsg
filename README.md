# bitmsg [WORK IN PROGRESS]
bitmsg is an alternative implementation of the bitmessage protocol.

The main difference at the moment is that it uses kaitaistruct for serialization and deserialization, and zig for cryptography and pow purposes. Since the support for serialization for other languages in kaitaistruct is still limited, it was decided to make a module for python for interacting with network.

Despite the implementation of important parts, it is not yet possible to demonstrate real use, but the work is in progress.

## Commands
To get started, install kaitaistruct that supports serialization according to the instructions from [here](https://https://doc.kaitai.io/serialization.html)

Then, after changing the protocol description, you can run the following command to generate new up-to-date files for serialization and deserialization
```bash
    kaitai-struct-compiler kaitai/bitmessage.ksy --read-write --target python \
        --outdir kaitai/out
```

To clone this repo

```bash
git clone https://github.com/vitalnodo/bitmsg.git --recurse-submodules

```

To install all the necessary modules for python, including the pybitmsg module 

```bash
pip install -r requirements.txt
```