import ChessOuterClass.Color
import ChessOuterClass.Piece
import io.grpc.Server
import io.grpc.ServerBuilder
import io.grpc.protobuf.services.ProtoReflectionService

class ChessGrpcService : ChessGrpcKt.ChessCoroutineImplBase() {
    // This is a rpc call
    override suspend fun toggleColor(request: Piece): Piece {
        println("got new request")
        val newColor = if (request.color == Color.WHITE) Color.BLACK else Color.WHITE
        return Piece.newBuilder().setColor(newColor).setName(request.name).build()
    }
}

// .http request to try this service:
//  ###
//  GRPC localhost:8080/Chess/ToggleColor
//  Host: localhost
//
//  {
//      "name": "bishop",
//      "color": "BLACK"
//  }
fun main() {
    val server: Server = ServerBuilder
        .forPort(8080)
        .addService(ChessGrpcService())
        // reflection is needed for IntelliJ http client
        .addService(ProtoReflectionService.newInstance())
        .build()

    server.start()
    println("Server started, listening on " + server.port)

    Runtime.getRuntime().addShutdownHook(
        Thread {
            println("*** shutting down gRPC server since JVM is shutting down")
            server.shutdown()
            println("*** server shut down")
        }
    )

    server.awaitTermination()
}
