# steps for adding new instructions:
# 1. copy this file
# 2. for any new instruction, update the comments
# as needed and anything associated with the comments
import ../imported_symbols

# this proc name matches file name
proc addis*(instruction : uint32) = 
  ## page 67 in POWERISA manual 3.0B
  ## make sure to grab the get_form.``instruction`` below
  ## matches the the filename
  var RA_addr = get_form.addis().RA(instruction)
  var RT_addr = get_form.addis().RT(instruction)
  var SI_shft = get_form.addis().SI(instruction) shl 16

  # actually do work needed to execute instruction
  if RA_addr == 0:
    regfiles.GPR[RT_addr] = cast[uint64](SI_shft)
  else:
    regfiles.GPR[RT_addr] = regfiles.GPR[RA_addr] + cast[uint64](SI_shft)
