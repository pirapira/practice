contract superSend
{
	function superSend(address _receiver) payable
	{
		selfdestruct(_receiver);
	}
}

contract User
{
	function pay(address _addr)
	{
		superSend s = (new superSend).value(this.balance)(_addr);
		if (address(s) == 0)
		   throw;
	}
}
