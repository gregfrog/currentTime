
getCurrentTime<-function()
{
  hex_to_raw <- function(x) {
    digits <- strtoi(strsplit(x, "")[[1]], base=16L)
    return(as.raw(bitwShiftL(digits[c(TRUE, FALSE)],4) + digits[c(FALSE, TRUE)]))
  }

  ntpPort = 123;

  host = nslookup("pool.ntp.org")

  udpPayload = raw(48)
  udpPayload[1:48] = as.raw(0) # zset the whole thing to zeroes
  udpPayload[1] = hex_to_raw("23") # meeans NTP 4 client

  rawReturned = udpSendRecv(host, ntpPort, udpPayload, doReceive=TRUE)
  ntpPayload = readBin(rawReturned, what="raw", n=100, size=1, signed=FALSE, endian="big")

  numericPayload = as.integer(ntpPayload)

  stratum = numericPayload[2]

  # UDP epoch is 1900, apply offset to Unix epoch
  ntpEpochOffset = 2208988800

  # high order word of the NTP send timestamp

  seconds = -ntpEpochOffset + (numericPayload[41] * 256 * 256 * 256) + (numericPayload[42] * 256 * 256) + (numericPayload[43] * 256) + numericPayload[44]

  return (as.POSIXct(seconds))

}
