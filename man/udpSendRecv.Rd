\name{udpSendRecv}
\alias{udpSendRecv}
\title{Send UDP packet with RAW type as payload}
\usage{
udpSendRecv(host, port, rawMessage, doReceive)
}
\description{
Send raw byte vector as payload of UDP pcaket.  Optionally wait for and return a response.

The returned packet size is limited to 1472 bytes, which is large for Intern et traffic, but small for local networks which may not fragment packets.
}
\arguments{
  \item{host}{
  Character string - name of the host to direct the packet to.
  }
  \item{port}{
  integer - the UDP port to send the packet to
  }
  \item{rawMessage}{
  A Raw vector the length of the UDP payload.
  }
  \item{doReceive}{
  Whether to wait for a response to the packet.
  }
}
\value{
The function returns a raw vector that is the payload of the returned UDP packet.
}
\examples{
udpPayload = raw(48)
udpPayload[1:48] = as.raw(0) # zset the whole thing to zeroes
udpPayload[1] = as.raw(35) # x23, 35 dec, means NTP 4 client

rawResult = udpSendRecv(nslookup("0.pool.ntp.org"), 123, udpPayload, doReceive=TRUE)

}
