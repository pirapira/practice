
(* below is largely based on ocaml-rpc *)

(*
 * Copyright (c) 2006-2009 Citrix Systems Inc.
 * Copyright (c) 2006-2014 Thomas Gazagnaire <thomas@gazagnaire.org>
 *
 * Permission to use, copy, modify, and distribute this software for any
 * purpose with or without fee is hereby granted, provided that the above
 * copyright notice and this permission notice appear in all copies.
 *
 * THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
 * WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
 * MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
 * ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
 * WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
 * ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
 * OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
*)

(* I modified the above-mentinoed code. *)

exception Connection_reset

let lib_version = "0.1.1"

module Utils = struct

  let open_connection_unix_fd filename =
    let s = Unix.socket Unix.PF_UNIX Unix.SOCK_STREAM 0 in
    try
      let addr = Unix.ADDR_UNIX(filename) in
      Unix.connect s addr;
      Printf.eprintf "connected \n%!";
      s
    with e ->
      Printf.eprintf "some problem \n%!";
      Unix.close s;
      raise e

end

type connection =
  | Unix_socket of string

let string_of_call ?(version=Jsonrpc.V1) (call : Rpc.call) =
  let c = call in
  Rpc.(Jsonrpc.
  (let json =
    match version with
    | V1 ->
      Dict [
        "method", String ((c : Rpc.call).name);
        "params", Enum c.params;
        "id", Int (new_id ());
      ]
    | V2 ->
      Dict [
        "jsonrpc", String "2.0";
        "method", String c.name;
        "params", Rpc.Enum c.params;
        "id", Int (new_id ());
      ]
  in
  to_string json))

let string_of_rpc_call (call : Rpc.call) =
  string_of_call ~version:(Jsonrpc.V2) call

let rpc_response_of_fd fd =
  Jsonrpc.response_of_in_channel (Unix.in_channel_of_descr fd)

let send_call ~fd call =
  let body = string_of_rpc_call call in
  let output_string str =
    ignore (Unix.write fd (Bytes.of_string str) 0 (String.length str)) in
  output_string body

let rpc_fd (fd: Unix.file_descr) call =
  try
    send_call ~fd call;
    rpc_response_of_fd fd
  with Unix.Unix_error(Unix.ECONNRESET, _, _) ->
    raise Connection_reset

let with_fd ~connection ~call =
  let s =
    match connection with
    | Unix_socket sock ->
      Utils.open_connection_unix_fd sock in
  try
    let result = rpc_fd s call in
    Unix.close s;
    result;
  with e ->
    Unix.close s;
    raise e

let do_rpc_unix filename call =
  let connection = Unix_socket filename in
  with_fd ~connection ~call


let eth_accounts_call : Rpc.call =
  Rpc.({ name = "eth_accounts"
       ; params = []
       })

(* How to perform a call and expect a return of eth_accounts *)

let filename = "/tmp/test/geth.ipc"

type address = string [@@deriving rpc]

type eth_accounts = address list [@@deriving rpc]

type eth_create_transaction =
  { from : string
  ; gas : int
  ; value : int
  ; data : string
  }
  [@@deriving rpc]

let pick_result (j : Rpc.t) =
  Rpc.
  (match j with
  | Dict x ->
     List.assoc "result" x
  | _ ->
     failwith "unexpected form"
  )

let eth_accounts (filename : string) : eth_accounts =
  let res : Rpc.response = (do_rpc_unix filename eth_accounts_call) in
  let json : Rpc.t = pick_result (Jsonrpc.json_of_response Jsonrpc.V2 res) in
  let result : eth_accounts = eth_accounts_of_rpc json in
  result

let init_code_dummy = "0x00"

let eth_sendCreateTransaction (trans : eth_create_transaction) : address =
  let call : Rpc.call =
    Rpc.({ name = "eth_sendTransaction"
         ; params = [rpc_of_eth_create_transaction trans]
         }) in
  let res : Rpc.response = do_rpc_unix filename call in
  let json : Rpc.t = pick_result (Jsonrpc.json_of_response Jsonrpc.V2 res) in
  let result = address_of_rpc json in
  result

let initcode_compiled =
  "0x60606040527f0000000000000000000000000000000000000000000000000000000000000060807f0000000000000000000000000000000000000000000000000000000000000040805180920190528180380382397f00000000000000000000000000000000000000000000000000000000000000025b82157f000000000000000000000000000000000000000000000000000000000000012c57815181557f0000000000000000000000000000000000000000000000000000000000000020909203917f000000000000000000000000000000000000000000000000000000000000000101907f000000000000000000000000000000000000000000000000000000000000002001907f0000000000000000000000000000000000000000000000000000000000000076565b5050506001547f000000000000000000000000000000000000000000000000000000000000015957600180555b600154806300000005557f0000000000000000000000000000000000000000000000000000000000000001016001557f00000000000000000000000000000000000000000000000000000000000000237f0000000000000000000000000000000000000000000000000000000000000000557f0000000000000000000000000000000000000000000000000000000000000414807f000000000000000000000000000000000000000000000000000000000000004080518092019052817f000000000000000000000000000000000000000000000000000000000000023b8239f37f000000000000000000000000000000000000000000000000000000000000000054565b60606040527f00000000000000000000000000000000000000000000000000000000000000003560e060020a9004507f0000000000000000000000000000000000000000000000000000000000000075565b7f00000000000000000000000000000000000000000000000000000000000000237f000000000000000000000000000000000000000000000000000000000000000055347f0000000000000000000000000000000000000000000000000000000000000005547f0000000000000000000000000000000000000000000000000000000000000003547f0000000000000000000000000000000000000000000000000000000000000002547f0000000000000000000000000000000000000000000000000000000000000002557f0000000000000000000000000000000000000000000000000000000000000003557f0000000000000000000000000000000000000000000000000000000000000005557f00000000000000000000000000000000000000000000000000000000000000045560016020807f000000000000000000000000000000000000000000000000000000000000004080518092019052918152f360606040527f0000000000000000000000000000000000000000000000000000000000000060807f0000000000000000000000000000000000000000000000000000000000000040805180920190528180380382397f00000000000000000000000000000000000000000000000000000000000000025b82157f000000000000000000000000000000000000000000000000000000000000012c57815181557f0000000000000000000000000000000000000000000000000000000000000020909203917f000000000000000000000000000000000000000000000000000000000000000101907f000000000000000000000000000000000000000000000000000000000000002001907f0000000000000000000000000000000000000000000000000000000000000076565b5050506001547f000000000000000000000000000000000000000000000000000000000000015957600180555b600154806300000005557f0000000000000000000000000000000000000000000000000000000000000001016001557f00000000000000000000000000000000000000000000000000000000000000237f0000000000000000000000000000000000000000000000000000000000000000557f0000000000000000000000000000000000000000000000000000000000000414807f000000000000000000000000000000000000000000000000000000000000004080518092019052817f000000000000000000000000000000000000000000000000000000000000023b8239f3"

let initcode_args : string =
    "0000000000000000000000000000000000000000000000000000000000000000"
  ^ "0000000000000000000000000000000000000000000000000000000400000020"
  ^ "0000000000000000000000000000000000000000000000000000000000000000"

let initcode = initcode_compiled^initcode_args

let test_mineBlocks (num : int) =
  let call : Rpc.call =
    Rpc.({ name = "test_mineBlocks"
         ; params = [Rpc.Int (Int64.of_int num)]
         }) in
  let res : Rpc.response = do_rpc_unix filename call in
  ()

let eth_getBalance (addr : address) : Big_int.big_int =
  let call : Rpc.call =
    Rpc.({ name = "eth_getBalance"
         ; params = [rpc_of_address addr; Rpc.rpc_of_string "latest"]
         }) in
  let res : Rpc.response = do_rpc_unix filename call in
  let json = pick_result (Jsonrpc.json_of_response Jsonrpc.V2 res) in
  let () = Printf.printf "got result %s\n%!" (Rpc.string_of_rpc json) in
  let result = Rpc.string_of_rpc json in
  Big_int.big_int_of_string result

let test_setChainParams (config : Rpc.t) : unit =
  let call : Rpc.call =
    Rpc.({ name = "test_setChainParams"
         ; params = [config]
         }) in
  ignore (do_rpc_unix filename call)

let rich_config (accounts : address list) : Rpc.t =
  let accounts_with_balance =
    List.map (fun addr ->
        (addr, Rpc.(Dict [ ("wei", String "0x10000000000000000000") ]))) accounts in
  Rpc.(Dict
         [ ("sealEngine", String "NoProof")
		 ; ("params", Dict
                        [ ("accountStartNonce", String "0x")
                        ; ("maximumExtraDataSize", String "0x1000000")
                        ; ("blockReward", String "0x")
                        ; ("allowFutureBlocks", String "1")
			            ; ("homsteadForkBlock", String "0x00")
			            ; ("EIP150ForkBlock", String "0x00")
			            ; ("EIP158ForkBlock", String "0x00")
           ])
		 ; ("genesis", Dict
                         [ ("author", String "0000000000000010000000000000000000000000")
			             ; ("timestamp", String "0x00")
			             ; ("parentHash", String "0x0000000000000000000000000000000000000000000000000000000000000000")
			             ; ("extraData", String "0x")
			             ; ("gasLimit", String "0x1000000000000")
           ])
         ;  ("accounts", Dict accounts_with_balance)
         ]
  )

type transaction_receipt =
  { blockHash : string
  ; blockNumber : int64
  ; transactionHash : string
  ; transactionIndex : int64
  ; from : address
  ; _to : address [@ key "to"]
  ; cumulativeGasUsed : int64
  ; gasUsed : int64
  ; contractAddress : address
  ; logs : string (* XXX actually more structured *)
  } [@@ deriving rpc]

let () =
  let accounts = (eth_accounts filename) in
  let config = rich_config accounts in
  let () = test_setChainParams(config) in
  let () = Printf.printf "%d accounts\n" (List.length accounts) in
  let () = assert (List.length accounts = 1) in
  let balance = eth_getBalance (List.nth accounts 0) in
  let () = assert (Big_int.gt_big_int balance (Big_int.big_int_of_int 10000000000000000)) in
  let trans : eth_create_transaction =
    { from = List.nth accounts 0
    ; gas = 1000000
    ; value = 0
    ; data = initcode
    }
  in
  let tx = (eth_sendCreateTransaction trans) in
  let () = test_mineBlocks 1 in
  ()

(* ocaml-rpc formats every message as an HTTP request while geth does not expect this *)
(* ocaml-bitcoin is similar.  It always adds HTTP headers *)
