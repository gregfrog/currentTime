
od = options(digits.secs = 6)
current = currentTime::getCurrentTime()
rNow = Sys.time()

warnings()
print(current)
print(rNow)
print(as.numeric(rNow) - as.numeric(current))

options(od)

if(abs(difftime(current, rNow, units = "secs")) > 1) {
  message("time difference too large")
}
