from setuptools import setup, Extension
from pathlib import Path

from builder import ZigBuilder

native = Extension("native", sources=["module.zig"])

setup(
    name="native",
    version="0.0.1",
    ext_modules=[native],
    cmdclass={"build_ext": ZigBuilder},
    py_modules=["builder"],
)
