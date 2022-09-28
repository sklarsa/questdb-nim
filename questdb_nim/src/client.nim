import message
import std/net
import std/os
import std/tables

type
    IlpClient = ref object
        address*: string
        port*: Port
        socket: Socket

proc newIlpClient(address: string, port: Port): IlpClient =
    let sock = newSocket()
    sock.connect(address, port)

    IlpClient(address: address, port: port, socket: sock)


proc send*(c: IlpClient, m: IlpMessage) =
    let msg = $m & '\n'
    c.socket.send(msg)

when isMainModule:
    let c = newIlpClient("localhost", Port(9009))
    let msg1 = IlpMessage(
        tableName: "hi",
        tagset: {"mytag_1":"mytagvalue_1", "mytag_2":"mytagvalue_2"}.toTable(),
        valueset: {"myvalue_1": 3.14159265358979323846264338327950, "myvalue_2": 2.0}.toTable(),
    )
    echo $msg1
    c.send(msg1)
    sleep(1000)
    c.socket.close()
