# bitmsg [WORK IN PROGRESS]
bitmsg is an alternative implementation of the bitmessage protocol.

The main difference at the moment is that it uses kaitaistruct for serialization and deserialization, and zig for cryptography and pow purposes. 

Despite the implementation of important parts, it is not yet possible to demonstrate real use, but the work is in progress.

## Commands
To get started, install kaitaistruct that supports serialization according to the instructions from [here](https://doc.kaitai.io/serialization.html)

Then, after changing the protocol description, you can run the following command to generate new up-to-date files for serialization and deserialization
```bash
    kaitai-struct-compiler kaitai_gen/bitmessage.ksy --read-write --target python \
        --outdir kaitai_gen/out
```

To clone this repo

```bash
git clone https://github.com/vitalnodo/bitmsg.git

```

To install kaitai struct python runtime

```bash
pip install git+https://github.com/kaitai-io/kaitai_struct_python_runtime.git@serialization
```

To build libbitmsg
```bash
cd libbitmsg
zig build
```

To run some tests of libbitmsg with ctypes:
```
python test.py
```

To mess with the network:
```
python main.py
```