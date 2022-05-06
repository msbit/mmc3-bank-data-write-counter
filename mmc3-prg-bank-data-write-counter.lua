local bankSelectValue
local bankDataCounts = {}

for i = 0x00, 0x07 do
  bankDataCounts[i] = {}
end

local function tableKeys(t)
  local result = {}
  for k, _ in pairs(t) do
    table.insert(result, k)
  end
  return result
end

local function logBank(dataCounts, bank)
  local counts = dataCounts[bank]
  local keys = tableKeys(counts)
  table.sort(keys)

  for _, value in pairs(keys) do
    local count = counts[value]
    emu.log(string.format(" > %02x:%02x %d", bank, value, count))
  end
end

local function onMemoryCpuWrite(address, value)
  if (address & 0x01) == 0x00 then
    bankSelectValue = value
  end

  if (address & 0x01) == 0x01 then
    bankDataCounts[bankSelectValue & 0x07][value] = (bankDataCounts[bankSelectValue & 0x07][value] or 0) + 1
  end
end

local function onEventEndFrame()
  local frameCount = emu.getState().ppu.frameCount
  if (frameCount % 1000) ~= 0 then
    return
  end

  emu.log(string.format("[%d]", frameCount))
  for bank = 0x00, 0x07 do
    logBank(bankDataCounts, bank)
  end
  emu.log('')
end

emu.addMemoryCallback(onMemoryCpuWrite, emu.memCallbackType.cpuWrite, 0x8000, 0x9fff)
emu.addEventCallback(onEventEndFrame, emu.eventType.endFrame)
