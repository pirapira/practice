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
		(new superSend).value(this.balance)(_addr);
	}
}
