type eth_acccounts =
  string list [@@deriving rpc]

let c : Rpc.call =
  Rpc.({ name = "eth.accounts"
       ; params = []
       })

(* How to perform a call and expect a return of eth_accounts *)

let filename = "/tmp/geth.ipc"

let () =
  let response = Rpc_client.(do_rpc_unix `JSON filename "" c) in
  ()
