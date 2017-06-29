type eth_acccounts =
  string list [@@deriving rpc]

let c : Rpc.call =
  Rpc.({ name = "eth_accounts"
       ; params = []
       })

(* How to perform a call and expect a return of eth_accounts *)

let filename = "/tmp/test/geth.ipc"


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

  exception Host_not_found of string

  let open_connection_unix_fd filename =
    let s = Unix.socket Unix.PF_UNIX Unix.SOCK_STREAM 0 in
    try
      let addr = Unix.ADDR_UNIX(filename) in
      Unix.connect s addr;
      s
    with e ->
      Unix.close s;
      raise e

  let open_connection_fd host port =
    let s = Unix.socket Unix.PF_INET Unix.SOCK_STREAM 0 in
    try
      let he =
        try Unix.gethostbyname host
        with Not_found -> raise (Host_not_found host) in
      if Array.length he.Unix.h_addr_list = 0
      then failwith (Printf.sprintf "Couldn't resolve hostname: %s" host);
      let ip = he.Unix.h_addr_list.(0) in
      let addr = Unix.ADDR_INET(ip, port) in
      Unix.connect s addr;
      s
    with e ->
      Unix.close s;
      raise e

  let rec split ?(accu=[]) c s =
    try
      let i = String.index s c in
      let prefix = String.sub s 0 i in
      let suffix =
        if i = String.length s - 1 then
          ""
        else
          String.sub s (i+1) (String.length s - i - 1) in
      split ~accu:(prefix :: accu) c suffix
    with _ ->
      List.rev (s :: accu)

  let strip s =
    let is_space c = c = ' ' || c = '\n' || c = '\r' || c = '\t' in
    let n = String.length s in
    let start = ref 0 in
    let ends = ref (n - 1) in
    while !start < n && is_space s.[!start] do
      incr start;
    done;
    while  !ends > 0 && is_space s.[!ends] do
      decr ends;
    done;
    if !start = 0 && !ends = n - 1 then
      s
    else
      String.sub s !start (!ends - !start + 1)

end


type connection =
  | Unix_socket of string

let string_of_rpc_call call =
  Jsonrpc.string_of_call call

let rpc_response_of_fd fd =
  Jsonrpc.response_of_in_channel (Unix.in_channel_of_descr fd)

let send_call ~fd call =
  let body = string_of_rpc_call call in
  let output_string str =
    ignore (Unix.write fd (Bytes.of_string str) 0 (String.length str)) in
  output_string body

let rpc_fd (fd: Unix.file_descr) content_type call =
  try
    send_call ~fd call;
    rpc_response_of_fd fd
  with Unix.Unix_error(Unix.ECONNRESET, _, _) ->
    raise Connection_reset

let with_fd ~connection ~call f =
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

let do_rpc_unix ~content_type ~filename call =
  let connection = Unix_socket filename in
  with_fd ~connection rpc_response_of_fd


let () =
  let () = Printf.printf "ocaml start\n%!" in
  let response = do_rpc_unix ~filename:filename c in
  let () = Printf.printf "got response\n%!" in
  ()

(* ocaml-rpc formats every message as an HTTP request while geth does not expect this *)
(* ocaml-bitcoin is similar.  It always adds HTTP headers *)
