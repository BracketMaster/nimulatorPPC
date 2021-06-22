import termios
from posix import select, Timeval, Time, TFdSet
from posix import FD_ZERO, FD_SET
import std/exitprocs

var f : File
var fd = cast[cint](stdin.getFileHandle())
var old_setting = Termios()
var readfds : TFdSet

proc setcbreak(fd : cint, termios: Termios) = 
  var new_setting = termios
  new_setting.c_lflag = (not(ICANON or ECHO)) and new_setting.c_lflag
  new_setting.c_lflag = ISIG or new_setting.c_lflag
  
  new_setting.c_iflag = not(ICRNL) and new_setting.c_iflag
  
  new_setting.c_cc[VMIN] = cast[cuchar](1.uint8)
  new_setting.c_cc[VTIME] = cast[cuchar](0.uint8)
  assert fd.tcSetAttr(TCSADRAIN, addr new_setting) == 0

proc restoreTerm() =
  assert fd.tcSetAttr(TCSADRAIN, addr old_setting) == 0
  f.close()

proc rx_empty*(): bool = 
  var duration = Timeval(tvsec: 0.Time, tvUsec: 0)
  var is_empty = select(cast[cint](1), unsafeAddr readfds, nil, nil, addr duration)
  (is_empty).bool

proc getChar*() : char =
  var my_chars : array[1, uint8]
  discard f.readBytes(my_chars, 0, 1)
  return cast[char](my_chars[0])

proc setRawTerm*() = 
  discard f.open(fd)
  readfds.FD_ZERO
  fd.FD_SET(readfds)
  assert fd.tcGetAttr(addr old_setting) == 0
  fd.setcbreak(old_setting)

addExitProc(restoreTerm)