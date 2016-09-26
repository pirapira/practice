# How to obtain the bytecode under verification
```
practice$ git submodule init compare-tools/ens/ens
practice$ git submodule update compare-tools/ens/ens
practice/compare-tools/ens/ens$ solc -o ../HashRegistrar --ast --asm --bin --bin-runtime HashRegistrar.sol 
```
After this, `practice/compare-tools/ens/HashRegistrar` should contain hex codes.

