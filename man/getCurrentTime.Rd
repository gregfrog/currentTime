\name{getCurrentTime}
\alias{getCurrentTime}
\title{GetCurrent Time from NTP}
\usage{
getCurrentTime()
}
\description{
Retrieves current time from one of four NTP servers at 0. to 3.pool.ntp.org.

The returned values are discarded if the server is not synchronised, one of the two closest remaining values are in the set is returned.

Returns a POSIXct value for the current UTC time.

Does not implement anthe full algorithm to adjust for network RTT and NTP server response time, falling between SNTP's single servr appraoch and 
the full NTP algorithm.  Only the return time is calulated and applied to the current time.   
this is being used to set time to about 1 second precision at one moment in time.  Note that randomly chosen NTP servers can be off by seconds, 
this is cleaned up by the NTP protocol which detects the spread of responses and discards high spread servers, converging on a high 
precision timestamp, this does not do that.  
}
\examples{
getCurrentTime()
}
