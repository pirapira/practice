# Analyzing ENS with Oyente

After [getting Oyente working](https://github.com/pirapira/practice/blob/master/compare-tools/getting_oyente_working.md), I tried to analyze [ENS](https://github.com/Arachnid/ens) with it.

First, the `ENS` contract it self passes Oyente.
```
$ python oyente.py ../ens/ens/ENS.sol
Contract ENS:
Running, please wait...
        ============ Results ===========
          CallStack Attack:      False
          Concurrency Bug:       False
          Time Dependency:       False
          Reentrancy bug exists: False
        ====== Analysis Completed ======
```

Since Oyente does not accept multiple input files, I cancatenated the relevant files into one,
```
$ cat ../ens/ens/ENS.sol ../ens/ens/HashRegistrar.sol > ENS_HashRegistrar.sol
```
and edited `ENS_HashRegistrar.sol` a little bit to make it compile through solc.
* add a `payable` modifier to `setBalance()` function
* remove `import ENS.sol`

Then,
`$ python oyente.py ENS_HashRegistrar.sol` shows something interesting.

```
Contract Deed:
Running, please wait...
        ============ Results ===========
          CallStack Attack:      False
THIS IS A CALLLLLLLLLL
{'path_condition': [Iv >= 0, init_Is >= Iv, init_Ia >= 0, Not(If(Id_size == 0, 1, 0) != 0), Not(If(Id_0/
       26959946667150639794667015087019630673637144422540572481103610249216 ==
       95634448,
       1,
       0) !=
    0), If(Id_0/
   26959946667150639794667015087019630673637144422540572481103610249216 ==
   190493653,
   1,
   0) !=
0, Not(Iv != 0), If(255 &
   Ia_store_2/
   1461501637330902918203684832716283019655932542976 ==
   0,
   1,
   0) !=
0], 'Ia_store_2': Ia_store_2, 'Is': Is, 'Iv': Iv, 'Id_0': Id_0, 'Ia': Ia, 'balance_1': balance_1, 'Id_size': Id_size}

 This is the global state
{'Ia': {2: Ia_store_2}, 'miu_i': 3L, 'balance': {'Ia': init_Ia + Iv, 'Is': init_Is - Iv, '1461501637330902918203684832716283019655932542975 & Ia': balance_1}}
{64: 96}

CALL params

1461501637330902918203684832716283019655932542975 &
Ia_store_2

balance_1


 =>>>>>> New PC: [] 

Reentrancy_bug? True

Added True
          Concurrency Bug:       False
          Time Dependency:       False
          Reentrancy bug exists: True
        ====== Analysis Completed ======
Contract ENS:
Running, please wait...
        ============ Results ===========
          CallStack Attack:      False
          Concurrency Bug:       False
          Time Dependency:       False
          Reentrancy bug exists: False
        ====== Analysis Completed ======
Contract Registrar:
Running, please wait...
        ============ Results ===========
          CallStack Attack:      False
Exception - canceled
          Concurrency Bug:       False
          Time Dependency:       False
          Reentrancy bug exists: False
        ====== Analysis Completed ======
```

Oyente detects a reentrancy bug in `Deed` contract.
Actually, there are places `Deed` contract calls out before changing any storage.

## Evaluation

Here is my tentative evaluation of the tool.  I'm going to apply the same scale on every tool I will try and/or develop.


| input |Solidity source, concatenated|
|-------|----|
| needed tool enhancement before applicable | ten minutes (changing `import z3util` with `import z3.z3util`) |
| needed manual work for the particular example | two minutes (concatenation) |
| output | four booleans per contract |



### Trustworthiness of the output (what might be broken)

#### Soundness/Completeness

```diff
  More info needed.
```

Soundness here means no false negative, completeness means no false positive.  In many cases
it's within reach to achieve one of them.

[The Oyente paper](https://eprint.iacr.org/2016/633.pdf) is clear that Oyente does not have completeness (last paragraph of section 5).
I need to check the paper if any soundness claims are made.
Before seeing this, the four booleans (e.g. Reentrancy bug exists: Yes) are only advisory,
although the results are already useful for focusing attention on more suspicious code.

#### Solidity parsing

```diff
+ good
```

Oyente uses the original `solc` so the Solidity parsing matches the actually used compiler.

#### EVM code

```diff
+ good
```

Oyente uses the compiled EVM bytecode, which is identical to the deployed one.

#### EVM Interpreter

```diff
- questionable
```

Oyente interprets the EVM bytecode in its own way.  Sometimes the semantics looks
different from the EVM (what is the result of division by zero?).

#### All Desired Properties are Captured or Not

```diff
- no
```

Not all desired properties are captured.  For ENS, there are functional requirements such as
* only the owner can change the name registration;
* only the registered names can be resolved;
* if users do not play malicious, they can get most of their funds back, and so on.
These are not captured by Oyente.
