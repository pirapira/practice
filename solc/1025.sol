pragma solidity ^0.4.2;

contract TTF
{
	uint public x;

	// If this succeeds or not...

	function ()
	{
		if (x == 1024) {
		   // at this moment, 1025 EVM instances exist from x == 0 to x == 1024
		   return;
		}
		x = x + 1;
		if(!this.send(msg.value)) throw;
		x = x - 1;
	}
}
