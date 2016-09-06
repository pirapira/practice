// solc token.sol --formal

/// @why3 invariant { to_int this.storage.balance = 150 }
contract C
{
	uint256 balance;

	function C()
	{
		balance = 150;
	}
}
