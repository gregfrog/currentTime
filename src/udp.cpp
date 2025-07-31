#include <Rinternals.h>
#include <R_ext/Rdynload.h>

#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include <sys/socket.h>
#include <arpa/inet.h>
#include <errno.h>

extern "C" SEXP udp_transact_impl(SEXP host, SEXP port, SEXP message, SEXP shouldReceive)
{

  const int maxUDPPacketeSize = 1472;
  unsigned char receiveBuffer[maxUDPPacketeSize];
  int sock;
  struct sockaddr_in server;

  const unsigned char* msg = RAW(message);
  int sendBufferSize = Rf_length(message);
  const char* ntpHost = CHAR(Rf_asChar(host));
  int ntpPort = Rf_asInteger(port);
  bool doRecv = Rf_asBool(shouldReceive);


  if ((sock = socket(AF_INET, SOCK_DGRAM, IPPROTO_UDP)) < 0) {
    Rf_error("%s %s", (char *)&"UDP: Failed to create UDP socket.", strerror(errno));
    return R_NilValue;
  }

  server.sin_family = AF_INET;
  server.sin_addr.s_addr = INADDR_ANY;
  server.sin_port = htons((short) ntpPort);

  if (inet_aton(ntpHost, &server.sin_addr) == 0) {
    Rf_error("%s %s", (char *)&"UDP: Failed to parse host address.", strerror(errno));
    close(sock);
    return R_NilValue;
  }

  if (sendto(sock, msg, sendBufferSize, 0, (struct sockaddr *) &server,
             sizeof(server)) < 0) {
    Rf_error("%s %s", (char *)&"UDP: Failed to send message.", strerror(errno));
    close(sock);
    return R_NilValue;
  }


  if(doRecv)
  {
    struct timeval tv;
    tv.tv_sec = 30;
    tv.tv_usec = 0;

    setsockopt(sock, SOL_SOCKET, SO_RCVTIMEO, (const char*)&tv, sizeof tv);

    ssize_t rcvCount  = recv(sock, receiveBuffer, maxUDPPacketeSize -1, 0);

    if(rcvCount < 0)
    {
      Rf_error("%s %s", """UDP: receive message failed.", strerror(errno));
      close(sock);
      UNPROTECT(1);
      return R_NilValue;
    }
    SEXP resultVec = PROTECT(Rf_allocVector(RAWSXP, rcvCount));
    Rbyte *returnValue =  RAW(resultVec);

    memcpy(returnValue, receiveBuffer, rcvCount);

    UNPROTECT(1);
    return resultVec;
  }

    close(sock);
    return R_NilValue;

}

static const R_CallMethodDef udp_entries[] = {
  {"udp_transact_impl", (DL_FUNC) &udp_transact_impl, 4},
  {NULL, NULL, 0}
};

void R_init_udp(DllInfo *info) {
  R_registerRoutines(info, NULL, udp_entries, NULL, NULL);
  R_useDynamicSymbols(info, FALSE);
}
