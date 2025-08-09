#
# getCurrentTime - get current time from pool.ntp.org NTP servers 
#
#     Copyright (C) 2025  Greg Hunt <greg@firmansyah.com>
#
#     This program is free software: you can redistribute it and/or modify
#     it under the terms of the GNU General Public License as published by
#     the Free Software Foundation, either version 3 of the License, or
#     (at your option) any later version.
#
#     This program is distributed in the hope that it will be useful,
#     but WITHOUT ANY WARRANTY; without even the implied warranty of
#     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#     GNU General Public License for more details.
#
#     You should have received a copy of the GNU General Public License
#     along with this program.  If not, see <https://www.gnu.org/licenses/>.
#
#
getCurrentTime<-function()
{
  hexToRaw <- function(x) {
    digits <- strtoi(strsplit(x, "")[[1]], base=16L)
    return(as.raw(bitwShiftL(digits[c(TRUE, FALSE)],4) + digits[c(FALSE, TRUE)]))
  }

  extract64bits<-function(numericPayload, offset)
  {
    # UDP epoch is 1900, apply offset to Unix epoch
    ntpEpochOffset = 2208988800

    seconds = -ntpEpochOffset + (numericPayload[offset] * 256 * 256 * 256) + (numericPayload[offset+1] * 256 * 256) +
              (numericPayload[offset+2] * 256) + numericPayload[offset+3]
    fracseconds = -ntpEpochOffset + (numericPayload[offset+4] * 256 * 256 * 256) + (numericPayload[offset+5] * 256 * 256) +
              (numericPayload[offset+6] * 256) + numericPayload[offset+7]

    return(c(seconds, fracseconds))
  }

  construct64bits<-function(theTime)
  {
    return(writeBin(as.numeric(theTime), raw(), size = 8, endian = "big"))
  }

  sampleOne<-function(serverName)
  {
    ntpPort = 123;

    host = nslookup(serverName)

    olddigitssecs = options(digits.secs = 6)

    udpPayload = raw(48)
    udpPayload[1:48] = as.raw(0) # zset the whole thing to zeroes
    udpPayload[1] = hexToRaw("23") # meeans NTP 4 client

    rawReturned = udpSendRecv(host, ntpPort, udpPayload, doReceive=TRUE)
    if(is.null(rawReturned))
    {
      return(NA)
    }

    ntpPayload = readBin(rawReturned, what="raw", n=100, size=1, signed=FALSE, endian="big")

    numericPayload = as.integer(ntpPayload)

    stratum = numericPayload[2]
    if(stratum >= 16)
    {
      warning("Unsynchronised NTP Clock returned by pool.ntp.org, value will be dropped")
      return(NA)
    }
    if(stratum == 0)
    {
      warning("Zero NTP Clock Stratum returned by pool.ntp.org, possible KOD, value will be dropped")
      return(NA)
    }

    serverTransmit = extract64bits(numericPayload, 41)
#    serverReceive = extract64bits(numericPayload, 33)
#    originTimestamp = extract64bits(numericPayload, 25)

    options(olddigitssecs)
    return(as.POSIXct(serverTransmit[1] + (serverTransmit[2]/(2**32))))

  }

  vals = c(sampleOne("0.pool.ntp.org"), sampleOne("1.pool.ntp.org"), sampleOne("2.pool.ntp.org"), sampleOne("3.pool.ntp.org"))
  indices = c(1,2,3,4)

  selection = !is.na(vals)
  vals = vals[selection]
  indices = indices[selection]

  if(length(vals) == 0)
  {
    stop("no functioning NTP servers found")
  }

  if (length(vals == 1))
  {
    return(vals[1])
  }

  combs = combn(indices, m=2, simplify=FALSE)
  diffs = lapply(combs, FUN=function(x){abs(as.numeric(x[1])-as.numeric(x[2]))})
  overallmin = min(diffs)

  mins = which(diffs == overallmin)

  return(vals[combs[[mins[1]]][1]])

}
