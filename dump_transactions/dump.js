function lookTx(hash)
{
    console.log(hash)
}
function cont1(err, number)
{
    for (i = number - 10; i <= number; i++) {
        b = eth.getBlock(i);
        b.transactions.forEach(lookTx)
    }
}
function d() {
    eth.getBlockNumber(cont1)
}
