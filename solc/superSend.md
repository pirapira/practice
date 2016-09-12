# A way to transfer Eth from a contract?

*Edit: this is considered a loophole, and it's not nice to use it, especially on contracts that performs accounting on the received Eth (see [comment](https://www.reddit.com/r/ethereum/comments/52b8fb/a_way_to_transfer_eth_from_a_contract/d7jbkrt)).*

Edit: a similar idea [existed long before](https://gist.github.com/holiman/f66bae83540728c209e521c42bd06362).

Edit: added a check if the call depth limit has been reached (after reading [a comment by /u/DeviateFish_](https://www.reddit.com/r/ethereum/comments/52b8fb/a_way_to_transfer_eth_from_a_contract/d7j0wmu); though that's only a part of the suggestions in the comment).

## Problem

It's tricky to send Eth from a Solidity contract.
There are expressions like `address.send(amount)` and `address.call.value(amount)()` but they have problems.

* If you do not check the result of the transfer, a malicious caller can set up a big call-depth and cause the transfer to fail, but the business process just moves on, making a loss to the to-be beneficiary.
* If you do check the result of the transfer, the receiver can block the business process by refusing the transfer.

The current solution is to make the beneficiary withdraw the amount.  [The whole situation is described in @chriseth's post](https://blog.ethereum.org/2016/06/10/smart-contract-security/).

I came up with another possible solution.

## Solution?

The solution involves a special gadget called `superSend` contract.

```
contract superSend
{
	function superSend(address _receiver) payable
	{
		selfdestruct(_receiver);
	}
}
```
The constructor `superSend()` destroys itself, and at the same time, sends all its balance to `_receiver`.  The `_receiver` has no way to refuse this transfer.  So the above problems are mitigated.  Just note that the gas is on the sender's side. *Edit: but what happens when the call depth is already 1023?*

The usage is a bit involved.
```
function pay(address _recipient, uint _amount)
{
    superSend s = (new superSend).value(_amount)(_recipient);
	if (address(s) == 0x0)
		throw;
}
```
For some reasons, the parentheses around `new superSend` is necessary.

## Questions

* Does it work?
    * I don't know yet what happens when the call depth is already 1023.  This has to be tested.
    * It seems to work [Browser Solidity](https://ethereum.github.io/browser-solidity/#version=soljson-v0.4.1+commit.4fc6fc2c.js) with [this input](https://gist.github.com/anonymous/312c0eff5ffb8de031173c220d7f73c0), but I haven't tried it on the testnet.
* Isn't it expensive to (try to) create a new contract for such a purpose?
    * Maybe, maybe not, because the self-destruction gives a refund.

## Acknowledgments

The idea came from a conversation with @Georgi87 and @konradkonrad.
