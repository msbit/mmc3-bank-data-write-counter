DEBOUNCE = 10

local bankSelectValue
local bankDataCounts = {
  [0x06] = {},
  [0x07] = {}
}
local previousFrameCount = 0

function onMemoryCpuWrite(address, value)
  if (address & 0x01) == 0x00 then
    bankSelectValue = value
  end

  if (address & 0x01) == 0x01 and ((bankSelectValue & 0x07) == 0x06 or (bankSelectValue & 0x07) == 0x07) then
    bankDataCounts[bankSelectValue & 0x07][value] = (bankDataCounts[bankSelectValue & 0x07][value] or 0) + 1
  end
end

function onEventEndFrame()
  local mouseState = emu.getMouseState()
  if mouseState.left == false then
    return
  end

  local state = emu.getState()
  local frameCount = state.ppu.frameCount

  if (frameCount - DEBOUNCE) < previousFrameCount then
    return
  end

  previousFrameCount = frameCount

  emu.log(string.format("[%d]", frameCount))
  for bank, counts in pairs(bankDataCounts)
  do
    for value, count in pairs(counts)
    do
      emu.log(string.format(" > %02x:%02x %d", bank, value, count))
    end
  end
  emu.log('')
end

emu.addMemoryCallback(onMemoryCpuWrite, emu.memCallbackType.cpuWrite, 0x8000, 0x9fff)
emu.addEventCallback(onEventEndFrame, emu.eventType.endFrame)
