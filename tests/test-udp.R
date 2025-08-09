#
# test code for package  
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
