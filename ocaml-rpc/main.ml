type eth_acccounts =
  string list [@@deriving rpc]

let c : Rpc.call =
  Rpc.({ name = "eth.accounts"
       ; params = []
       })
