--这是无人机摄像头控制炮台的独立代码--
local per=peripheral.wrap("bottom")
local cannon = peripheral.wrap("back")

local function viewRotToAngle(p)
    local picth = p.getPitch()
    local yaw = p.getYaw()
    return picth, yaw
end

local function controlCannon(cannon, picth, yaw)
        cannon.setPitch(picth)
        cannon.setYaw(yaw)
end

local function calculateYaw(angle)
    angle = (angle + 360) % 360
    return angle > 180 and angle - 360 or angle
end

term.clear()
while true do
    sleep(0.05)
    local npitch, nyaw = viewRotToAngle(per)
    nyaw = calculateYaw(nyaw)
    npitch = -npitch
    term.setCursorPos(1, 3)
    print(("Yaw: %.2f Pitch: %.2f"):format(nyaw, npitch))
    controlCannon(cannon, npitch, nyaw)
end
