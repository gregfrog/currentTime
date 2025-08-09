
udpSendRecv <- function(host, port, rawMessage, doReceive) {
  stopifnot(is.character(host))
  stopifnot(is.numeric(port))
  stopifnot(is.raw(rawMessage))
  stopifnot(is.logical(doReceive))
  return(.Call("udp_transact_impl",  host, as.integer(port), rawMessage, doReceive))
}
