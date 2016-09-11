# A way to transfer Eth from a contract?

## Problem

It's tricky to send Eth from a Solidity contract.
There are expressions like `address.send(amount)` and `address.call.value(amount)()` but they have problems.

* If you do not check the result of the transfer, a malicious caller can set up a big call-depth and cause the transfer to fail, but the business process to move on.
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
The constructor `supreSend()` destroys itself, and at the same time, sends all its balance to `_receiver`.  The `_receiver` has no way to refuse this transfer.  So the above problems are mitigated.  Just note that the sender pays the gas.

The usage is a bit involved.
```
function pay(address _recipient, uint _amount)
{
    (new superSend).value(_amount)(_recipient);
}
```
For some reasons, the parentheses around `new superSend` is necessary.

## Questions

* Does it work?
    * I don't know yet.  I don't have a working client (shame!!).
* Isn't it expensive to (try to) create a new contract for such a purpose?
    * Maybe not, because the selfdestruction gives a refund.

## Acknowledgments

The idea came from a conversation with @Georgi87 and @konradkonrad.