function lookTx(hash)
{
    tx = eth.getTransaction(hash);
    if (tx.to)
        return;
    receipt = eth.getTransactionReceipt(hash)
    if (! receipt)
        return;
    console.log('');
    console.log('hash: ' + hash);
    console.log('input: ' + tx.input)
    console.log('address: ' + receipt.contractAddress)
}
function cont1(err, number)
{
    for (i = 0; i <= number; i++) {
        b = eth.getBlock(i);
        b.transactions.forEach(lookTx)
    }
}
function d() {
    eth.getBlockNumber(cont1)
}
