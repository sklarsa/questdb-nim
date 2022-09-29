import message
import std/net
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
    ## Sends a single message to the server
    let payload = $m & '\n'
    m.validate()

    c.socket.send(payload)

proc send*(c: IlpClient, m: openArray[IlpMessage]) =
    ## Sends a list of messages to the server
    var payload = ""
    for msg in m:
        msg.validate()
        payload.add($msg & '\n')

    c.socket.send(payload)


when isMainModule:
    let c = newIlpClient("localhost", Port(9009))
    let msg1 = IlpMessage(
        tableName: "hi",
        symbolset: {"mytag_1":"mytagvalue_1", "mytag_2":"mytagvalue_2"}.toTable(),
        columnset: {"myvalue_1": IlpValue(f: 3.14159265358979323846264338327950), "myvalue_2": IlpValue(s: "2.0")}.toTable(),
    )
    echo $msg1
    c.send(msg1)
    c.socket.close()
