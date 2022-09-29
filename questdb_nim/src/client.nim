import message
import std/net
import std/tables
import std/times

type
    IlpClient = ref object
        address*: string
        port*: Port
        socket: Socket

proc newIlpClient(address: string, port: Port): IlpClient =
    let sock = newSocket()
    sock.connect(address, port)

    # todo: handle authentication here

    IlpClient(address: address, port: port, socket: sock)

proc send*(c: IlpClient, m: string) =
    ## Sends a raw string message to the server.
    ## WARNING: No validation is performed in this message.  The caller is responsible
    ## for ensuring that the message is formatted correctly

    # todo: add jwt if authentication is enabled

    c.socket.send(m)

proc send*(c: IlpClient, m: IlpMessage) =
    ## Sends a single message to the server
    let payload = $m & '\n'
    m.validate()

    c.send(payload)

proc send*(c: IlpClient, m: openArray[IlpMessage]) =
    ## Sends a list of messages to the server
    var payload = ""
    for msg in m:
        msg.validate()
        payload.add($msg & '\n')

    c.send(payload)


when isMainModule:
    let c = newIlpClient("localhost", Port(9009))
    let t = now().toTime()
    let msg1 = IlpMessage(
        tableName: "hi",
        symbolset: {"mytag_1":"mytagvalue_1", "mytag_2":"mytagvalue_2"}.toOrderedTable(),
        columnset: {
            "myvalue_1": IlpValue(kind: ilpFloat, floatVal: 3.14159265358979323846264338327950),
            "myvalue_2": IlpValue(kind: ilpString, stringVal: "2.0"),
            "myvalue_3": IlpValue(kind: ilpTime, timeVal: t),
        }.toOrderedTable(),
        timestamp: t,

    )
    echo $msg1
    c.send(msg1)
    c.socket.close()
