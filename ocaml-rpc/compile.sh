# eth --test -d /tmp/test &
# PID=$!
ocamlbuild -use-ocamlfind -pkgs batteries,rpclib,rpclib.unix,rpclib.json,unix,ppx_deriving,ppx_deriving_rpc main.native || exit 1
# while [ ! -S /tmp/test/geth.ipc ]; do
#	echo "still waiting"
#	sleep 2
#done

# https://superuser.com/a/576404
# sudo mv /tmp/test/geth.ipc /tmp/test/geth.ipc.original
# sudo socat -t100 -x -v UNIX-LISTEN:/tmp/test/geth.ipc,mode=777,reuseaddr,fork UNIX-CONNECT:/tmp/test/geth.ipc.original

./main.native
#kill $PID
