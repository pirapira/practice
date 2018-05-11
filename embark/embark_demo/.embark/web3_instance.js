
import Web3 from '/home/yh/.nvm/versions/node/v9.3.0/lib/node_modules/embark/js/web3-1.0.min.js';

 if (typeof web3 !== 'undefined') {
 } else {
 var web3 = new Web3();

 }function __reduce(arr, memo, iteratee, cb) {
  if (typeof cb !== 'function') {
    if (typeof memo === 'function' && typeof iteratee === 'function') {
      cb = iteratee;
      iteratee = memo;
      memo = [];
    } else {
      throw new TypeError('expected callback to be a function');
    }
  }

  if (!Array.isArray(arr)) {
    cb(new TypeError('expected an array'));
    return;
  }

  if (typeof iteratee !== 'function') {
    cb(new TypeError('expected iteratee to be a function'));
    return;
  }

  (function next(i, acc) {
    if (i === arr.length) {
      cb(null, acc);
      return;
    }

    iteratee(acc, arr[i], function(err, val) {
      if (err) {
        cb(err);
        return;
      }
      next(i + 1, val);
    });
  })(0, memo);
};
var __mainContext = __mainContext || this;
__mainContext.__LoadManager = function() { this.list = []; this.done = false; }
__mainContext.__LoadManager.prototype.execWhenReady = function(cb) { if (this.done) { cb(); } else { this.list.push(cb) } }
__mainContext.__LoadManager.prototype.doFirst = function(todo) { var self = this; todo(function() { self.done = true; self.list.map((x) => x.apply()) }) }
__mainContext.__loadManagerInstance = new __mainContext.__LoadManager();
var whenEnvIsLoaded = function(cb) {
  if (typeof document !== 'undefined' && document !== null && !/comp|inter|loaded/.test(document.readyState)) {
      document.addEventListener('DOMContentLoaded', cb);
  } else {
    cb();
  }
}
whenEnvIsLoaded(function(){
  __mainContext.__loadManagerInstance.doFirst(function(done) {
    __mainContext.web3 = undefined;
__reduce(["$WEB3","http://localhost:8545"],function(prev, value, next) {
  if (prev === false) {
    return next(null, false);
  }

  if (value === '$WEB3' && (typeof web3 !== 'undefined' && typeof Web3 !== 'undefined')) {
    web3.setProvider(web3.givenProvider);
  } else if (value !== '$WEB3' && (typeof Web3 !== 'undefined' && ((typeof web3 === 'undefined') || (typeof web3 !== 'undefined' && (!web3.isConnected || (web3.isConnected && !web3.isConnected())))))) {
    if (value.indexOf('ws://') >= 0) {
      web3.setProvider(new Web3.providers.WebsocketProvider(value));
    } else {
      web3.setProvider(new Web3.providers.HttpProvider(value));
    }
  } else if (value === '$WEB3') {
    return next(null, '');
  }

  web3.eth.getAccounts(function(err, account) {
    if (err) {
      next(null, true)
    } else {
      next(null, false)
    }
  });
}, function(err, _result) {
  web3.eth.getAccounts(function(err, accounts) {
    web3.eth.defaultAccount = accounts[0];
    done();
  });
});

  })
});


global.__embarkContext = __mainContext.__loadManagerInstance;

window.web3 = web3;

export default web3;
