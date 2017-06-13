Yoichi
=======


A list of minimal smart contract examples
-----------------------------------------

* a contract that always throws an exception
* a contract that forwards a call
* a contract that DELEGATECALLs an address in the storage
* a transferrable token
* contract purity checker
* sealed auction
* a contract that verifies off-chain computation
* state-channeled chess

A list of desiderata
--------------------

* an interpreter independent of EVM
  (metrics: percentage of the interpreter code identical to EVM, lower the better)
* grammar deep-embeddable to Coq and Isabelle able to cause all kinds of side-effects that an EVM code can cause
  (metrics: percentage of instructions touchable)
ability to change implementations sharing the same interface
  (metrics: )
control over gas cost consumption
  (metrics: the max amount of gas consumable per line, lower the better)
* abstraction over splitting transactions
  (metrics: the size of diff for spliting a big function into two steps that are called in two transactions)
* abstraction over spliting contracts
  (metrics: the size of diff for spliting a big contract into several)
* abstraction over producing codes
  (metrics: the size of QUINE)
* abstraction over DELEGATECALL
  (metrics: the size of diff for spliting a part of the code, and DELEGATECALLing it)
* abstraction over on-chain/off-chain computation
  (metrics: the size of diff for spliting a part of the code to be executed by a participant off-chain)
* abstraction over sharding/asynchronous communication
  (metrics: the size of diff for spliting a part of the code to a different shard)
* abstraction over zksnark
  (metrics: the size of diff for splitting a part of the code away into a zksnark gadget)

A list of tools
---------------

* quoting code (as in `returnlll`)
* S5 modal types (on-chain, off-chain by a participant, etc; Tom Murphy VII: https://www.cs.cmu.edu/~tom7/papers/modal-types-for-mobile-code.pdf)
* notation for precondition / postcondition / invariant
* concolic execution
