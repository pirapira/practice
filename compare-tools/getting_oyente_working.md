# Getting Oyente working

## Getting Oyente recognize Z3

First, at the top of this repository,
```
git submodule init
git submodule update --recursive
```
would checkout oyente and z3.

When you do
```
cd compare-tools/oyente
./oyente.py
```
You would wait for a minute, and you will see a message
```
Z3 is not available. Please install z3 from https://github.com/Z3Prover/z3.
```

So, move on to the installation of z3.
```
cd ../z3
python scripts/mk_make.py --python
cd build
make
sudo make install
```

Then, hoping it works, go back to `oyente`.
```
cd ../../oyente
./oyente.py
Error: Z3 is not available. Please install z3 from https://github.com/Z3Prover/z3.
```
However, it does not still work.

To see the reason, do something similar on `python` interactively.
```
python
>> import z3
Traceback (most recent call last):
  File "<stdin>", line 1, in <module>
  File "/usr/lib/python2.7/dist-packages/z3/__init__.py", line 1, in <module>
    from .z3 import *
  File "/usr/lib/python2.7/dist-packages/z3/z3.py", line 44, in <module>
    from . import z3core
  File "/usr/lib/python2.7/dist-packages/z3/z3core.py", line 4, in <module>
    import pkg_resources
ImportError: No module named pkg_resources
```

Now I know the missing module, I can install it.
```
sudo apt install python-pkg-resources
```

After this, `import z3` seems to work in `python`.
```
python
>> import z3
```

Back in `oyente`, it still fails.
```
python oyente.py
Error: Z3 is not available. Please install z3 from https://github.com/Z3Prover/z3.
```

Looking into `oyente.py` I found it imports not only `z3` but also `z3util`.

When I try to import this in `python`, the `z3util` import fails.
```
>>> import z3
>>> import z3util
Traceback (most recent call last):
  File "<stdin>", line 1, in <module>
ImportError: No module named z3util
```

However,
```
>>> import z3.z3util
```
works.

So. I edited `oyente.py` and replaced
`import z3util` with `import z3.z3util`.

Now the error message from `oyente.py` has changed.

```
$ python oyente.py
usage: oyente.py [-h] [-b] [-j] [-e] [-p] [--error] [-t TIMEOUT] [-d] [-v]
                 [-r]
                 source
oyente.py: error: too few arguments
```
