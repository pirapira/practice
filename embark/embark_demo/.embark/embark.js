
import Web3 from '/home/yh/.nvm/versions/node/v9.3.0/lib/node_modules/embark/js/web3-1.0.min.js';

import web3 from 'Embark/web3';

var EmbarkJS = {};

EmbarkJS.isNewWeb3 = function() {
  var _web3 = new Web3();
  if (typeof(_web3.version) === "string") {
    return true;
  }
  return parseInt(_web3.version.api.split('.')[0], 10) >= 1;
};

EmbarkJS.Contract = function(options) {
    var self = this;
    var i, abiElement;
    var ContractClass;

    this.abi = options.abi;
    this.address = options.address;
    this.code = '0x' + options.code;
    //this.web3 = options.web3 || web3;
    this.web3 = options.web3 || window.web3;

    if (EmbarkJS.isNewWeb3()) {
      // TODO:
      // add default **from** address
      // add gasPrice
      ContractClass = new this.web3.eth.Contract(this.abi, this.address);
      ContractClass.setProvider(this.web3.currentProvider);
      ContractClass.options.data = this.code;

      return ContractClass;
    } else {
      ContractClass = this.web3.eth.contract(this.abi);

      this.eventList = [];

      if (this.abi) {
        for (i = 0; i < this.abi.length; i++) {
          abiElement = this.abi[i];
          if (abiElement.type === 'event') {
            this.eventList.push(abiElement.name);
          }
        }
      }

      var messageEvents = function() {
        this.cb = function() {};
      };

      messageEvents.prototype.then = function(cb) {
        this.cb = cb;
      };

      messageEvents.prototype.error = function(err) {
        return err;
      };

      this._originalContractObject = ContractClass.at(this.address);
      this._methods = Object.getOwnPropertyNames(this._originalContractObject).filter(function(p) {
        // TODO: check for forbidden properties
        if (self.eventList.indexOf(p) >= 0) {

          self[p] = function() {
            var promise = new messageEvents();
            var args = Array.prototype.slice.call(arguments);
            args.push(function(err, result) {
              if (err) {
                promise.error(err);
              } else {
                promise.cb(result);
              }
            });

            self._originalContractObject[p].apply(self._originalContractObject[p], args);
            return promise;
          };
          return true;
        } else if (typeof self._originalContractObject[p] === 'function') {
          self[p] = function(_args) {
            var args = Array.prototype.slice.call(arguments);
            var fn = self._originalContractObject[p];
            var props = self.abi.find((x) => x.name == p);

            var promise = new Promise(function(resolve, reject) {
              args.push(function(err, transaction) {
                promise.tx = transaction;
                if (err) {
                  return reject(err);
                }

                var getConfirmation = function() {
                  self.web3.eth.getTransactionReceipt(transaction, function(err, receipt) {
                    if (err) {
                      return reject(err);
                    }

                    if (receipt !== null) {
                      return resolve(receipt);
                    }

                    setTimeout(getConfirmation, 1000);
                  });
                };

                if (typeof(transaction) !== "string" || props.constant) {
                  resolve(transaction);
                } else {
                  getConfirmation();
                }
              });

              fn.apply(fn, args);
            });

            return promise;
          };
          return true;
        }
        return false;
      });
    }
};

EmbarkJS.Contract.prototype.deploy = function(args, _options) {
    var self = this;
    var contractParams;
    var options = _options || {};

    contractParams = args || [];

    contractParams.push({
        from: this.web3.eth.accounts[0],
        data: this.code,
        gas: options.gas || 800000
    });

    var contractObject = this.web3.eth.contract(this.abi);

    var promise = new Promise(function(resolve, reject) {
        contractParams.push(function(err, transaction) {
            if (err) {
                reject(err);
            } else if (transaction.address !== undefined) {
                resolve(new EmbarkJS.Contract({
                    abi: self.abi,
                    code: self.code,
                    address: transaction.address
                }));
            }
        });

        // returns promise
        // deploys contract
        // wraps it around EmbarkJS.Contract
        contractObject["new"].apply(contractObject, contractParams);
    });


    return promise;
};

EmbarkJS.Contract.prototype.new = EmbarkJS.Contract.prototype.deploy;

EmbarkJS.Contract.prototype.at = function(address) {
  return new EmbarkJS.Contract({ abi: this.abi, code: this.code, address: address });
};

EmbarkJS.Contract.prototype.send = function(value, unit, _options) {
  var options, wei;
  if (typeof unit === 'object') {
    options = unit;
    wei = value;
  } else {
    options = _options || {};
    wei = this.web3.toWei(value, unit);
  }

  options.to = this.address;
  options.value = wei;

  this.web3.eth.sendTransaction(options);
};

EmbarkJS.Storage = {};

EmbarkJS.Storage.Providers = {};

EmbarkJS.Storage.saveText = function(text) {
  if (!this.currentStorage) {
    throw new Error('Storage provider not set; e.g EmbarkJS.Storage.setProvider("ipfs")');
  }
  return this.currentStorage.saveText(text);
};

EmbarkJS.Storage.get = function(hash) {
  if (!this.currentStorage) {
    throw new Error('Storage provider not set; e.g EmbarkJS.Storage.setProvider("ipfs")');
  }
  return this.currentStorage.get(hash);
};

EmbarkJS.Storage.uploadFile = function(inputSelector) {
  if (!this.currentStorage) {
    throw new Error('Storage provider not set; e.g EmbarkJS.Storage.setProvider("ipfs")');
  }
  return this.currentStorage.uploadFile(inputSelector);
};

EmbarkJS.Storage.getUrl = function(hash) {
  if (!this.currentStorage) {
    throw new Error('Storage provider not set; e.g EmbarkJS.Storage.setProvider("ipfs")');
  }
  return this.currentStorage.getUrl(hash);
};

EmbarkJS.Storage.registerProvider = function(providerName, obj) {
  EmbarkJS.Storage.Providers[providerName] = obj;
};

EmbarkJS.Storage.setProvider = function(provider, options) {
  let providerObj = this.Providers[provider];

  if (!providerObj) {
    throw new Error('Unknown storage provider');
  } 

  this.currentStorage = providerObj;

  return providerObj.setProvider(options);
};

EmbarkJS.Storage.isAvailable = function(){
  return this.currentStorage.isAvailable();
};

EmbarkJS.Messages = {};

EmbarkJS.Messages.Providers = {};

EmbarkJS.Messages.registerProvider = function(providerName, obj) {
  EmbarkJS.Messages.Providers[providerName] = obj;
};

EmbarkJS.Messages.setProvider = function(provider, options) {
  let providerObj = this.Providers[provider];

  if (!providerObj) {
    throw new Error('Unknown messages provider');
  }

  this.currentMessages = providerObj;

  return providerObj.setProvider(options);
};

EmbarkJS.Messages.isAvailable = function(){
  return this.currentMessages.isAvailable();
};

EmbarkJS.Messages.sendMessage = function(options) {
  if (!this.currentMessages) {
    throw new Error('Messages provider not set; e.g EmbarkJS.Messages.setProvider("whisper")');
  }
  return this.currentMessages.sendMessage(options);
};

EmbarkJS.Messages.listenTo = function(options, callback) {
  if (!this.currentMessages) {
    throw new Error('Messages provider not set; e.g EmbarkJS.Messages.setProvider("whisper")');
  }
  return this.currentMessages.listenTo(options, callback);
};

EmbarkJS.Utils = {
  fromAscii: function(str) {
    var _web3 = new Web3();
    return _web3.utils ? _web3.utils.fromAscii(str) : _web3.fromAscii(str);
  },
  toAscii: function(str) {
    var _web3 = new Web3();
    return _web3.utils.toAscii(str);
  }
};

export default EmbarkJS;



let __MessageEvents = function() {
  this.cb = function() {};
};

__MessageEvents.prototype.then = function(cb) {
  this.cb = cb;
};

__MessageEvents.prototype.error = function(err) {
  return err;
};

__MessageEvents.prototype.stop = function() {
  this.filter.stopWatching();
};


/*global EmbarkJS, Web3, __MessageEvents */

// for the whisper v5 and web3.js 1.0
let __embarkWhisperNewWeb3 = {};

__embarkWhisperNewWeb3.setProvider = function (options) {
  const self = this;
  let provider;
  if (options === undefined) {
    provider = "localhost:8546";
  } else {
    provider = options.server + ':' + options.port;
  }
  // TODO: take into account type
  self.web3 = new Web3(new Web3.providers.WebsocketProvider("ws://" + provider));
  self.getWhisperVersion(function (err, version) {
    if (err) {
      console.log("whisper not available");
    } else if (version >= 5) {
      self.web3.shh.newSymKey().then((id) => {
        self.symKeyID = id;
      });
      self.web3.shh.newKeyPair().then((id) => {
        self.sig = id;
      });
    } else {
      throw new Error("version of whisper not supported");
    }
    self.whisperVersion = self.web3.version.whisper;
  });
};

__embarkWhisperNewWeb3.sendMessage = function (options) {
  var topics, data, ttl, payload;
  topics = options.topic || options.topics;
  data = options.data || options.payload;
  ttl = options.ttl || 100;
  var powTime = options.powTime || 3;
  var powTarget = options.powTarget || 0.5;

  if (topics === undefined) {
    throw new Error("missing option: topic");
  }

  if (data === undefined) {
    throw new Error("missing option: data");
  }

  topics = this.web3.utils.toHex(topics).slice(0, 10);

  payload = JSON.stringify(data);

  let message = {
    symKeyID: this.symKeyID, // encrypts using the sym key ID
    sig: this.sig, // signs the message using the keyPair ID
    ttl: ttl,
    topic: topics,
    payload: EmbarkJS.Utils.fromAscii(payload),
    powTime: powTime,
    powTarget: powTarget
  };

  this.web3.shh.post(message, function () {
  });
};

__embarkWhisperNewWeb3.listenTo = function (options, callback) {
  var topics = options.topic || options.topics;

  let promise = new __MessageEvents();

  if (typeof topics === 'string') {
    topics = [this.web3.utils.toHex(topics).slice(0, 10)];
  } else {
    topics = topics.map((t) => this.web3.utils.toHex(t).slice(0, 10));
  }

  let filter = this.web3.shh.subscribe("messages", {
    symKeyID: this.symKeyID,
    topics: topics
  }).on('data', function (result) {
    var payload = JSON.parse(EmbarkJS.Utils.toAscii(result.payload));
    var data;
    data = {
      topic: EmbarkJS.Utils.toAscii(result.topic),
      data: payload,
      //from: result.from,
      time: result.timestamp
    };

    if (callback) {
      return callback(null, data);
    }
    promise.cb(payload, data, result);
  });

  promise.filter = filter;

  return promise;
};

__embarkWhisperNewWeb3.getWhisperVersion = function (cb) {
  this.web3.shh.getVersion(function (err, version) {
    cb(err, version);
  });
};

__embarkWhisperNewWeb3.isAvailable = function () {
  return new Promise((resolve, reject) => {
    if (!this.web3.shh) {
      return resolve(false);
    }
    try {
      this.getWhisperVersion((err) => {
        resolve(Boolean(!err));
      });
    }
    catch (err) {
      reject(err);
    }
  });
};


EmbarkJS.Messages.registerProvider('whisper', __embarkWhisperNewWeb3);
import IpfsApi from 'ipfs-api';

let __embarkIPFS = {};

__embarkIPFS.setProvider = function (options) {
  var self = this;
  var promise = new Promise(function (resolve, reject) {
    try {
      if (options === undefined) {
        self.ipfsConnection = IpfsApi('localhost', '5001');
        self._getUrl = "http://localhost:8080/ipfs/";
      } else {
        var ipfsOptions = {host: options.server, protocol: 'http'};
        if (options.protocol) {
          ipfsOptions.protocol = options.protocol;
        }
        if (options.port && options.port !== 'false') {
          ipfsOptions.port = options.port;
        }
        self.ipfsConnection = IpfsApi(ipfsOptions);
        self._getUrl = options.getUrl || "http://localhost:8080/ipfs/";
      }
      resolve(self);
    } catch (err) {
      console.log(err);
      self.ipfsConnection = null;
      reject(new Error('Failed to connect to IPFS'));
    }
  });
  return promise;
};

__embarkIPFS.saveText = function (text) {
  const self = this;
  var promise = new Promise(function (resolve, reject) {
    if (!self.ipfsConnection) {
      var connectionError = new Error('No IPFS connection. Please ensure to call Embark.Storage.setProvider()');
      reject(connectionError);
    }
    self.ipfsConnection.add(self.ipfsConnection.Buffer.from(text), function (err, result) {
      if (err) {
        reject(err);
      } else {
        resolve(result[0].path);
      }
    });
  });

  return promise;
};

__embarkIPFS.get = function (hash) {
  const self = this;
  // TODO: detect type, then convert if needed
  //var ipfsHash = web3.toAscii(hash);
  var promise = new Promise(function (resolve, reject) {
    if (!self.ipfsConnection) {
      var connectionError = new Error('No IPFS connection. Please ensure to call Embark.Storage.setProvider()');
      reject(connectionError);
    }
    self.ipfsConnection.get(hash, function (err, files) {
      if (err) {
        return reject(err);
      }
      resolve(files[0].content.toString());
    });
  });

  return promise;
};

__embarkIPFS.uploadFile = function (inputSelector) {
  const self = this;
  var file = inputSelector[0].files[0];

  if (file === undefined) {
    throw new Error('no file found');
  }

  var promise = new Promise(function (resolve, reject) {
    if (!self.ipfsConnection) {
      var connectionError = new Error('No IPFS connection. Please ensure to call Embark.Storage.setProvider()');
      reject(connectionError);
    }
    var reader = new FileReader();
    reader.onloadend = function () {
      var fileContent = reader.result;
      var buffer = self.ipfsConnection.Buffer.from(fileContent);
      self.ipfsConnection.add(buffer, function (err, result) {
        if (err) {
          reject(err);
        } else {
          resolve(result[0].path);
        }
      });
    };
    reader.readAsArrayBuffer(file);
  });

  return promise;
};

__embarkIPFS.isAvailable = function () {
  return new Promise((resolve) => {
    if (!this.ipfsConnection) {
      return resolve(false);
    }
    this.ipfsConnection.id()
      .then((id) => {
        resolve(Boolean(id));
      })
      .catch(() => {
        resolve(false);
      });
  });
};

__embarkIPFS.getUrl = function (hash) {
  return (this._getUrl || "http://localhost:8080/ipfs/") + hash;
};


EmbarkJS.Storage.registerProvider('ipfs', __embarkIPFS);
var whenEnvIsLoaded = function(cb) {
  if (typeof document !== 'undefined' && document !== null && !/comp|inter|loaded/.test(document.readyState)) {
      document.addEventListener('DOMContentLoaded', cb);
  } else {
    cb();
  }
}
whenEnvIsLoaded(function() {
  
EmbarkJS.Messages.setProvider('whisper',{"server":"localhost","port":8546,"type":"ws"});
});

var whenEnvIsLoaded = function(cb) {
  if (typeof document !== 'undefined' && document !== null && !/comp|inter|loaded/.test(document.readyState)) {
      document.addEventListener('DOMContentLoaded', cb);
  } else {
    cb();
  }
}
whenEnvIsLoaded(function() {
  
EmbarkJS.Storage.setProvider('ipfs',{"server":"localhost","port":5001,"protocol":"http","getUrl":"http://localhost:8080/ipfs/"});
});
