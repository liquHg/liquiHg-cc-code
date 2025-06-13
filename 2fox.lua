--这是榴弹无人机的完整代码--
local PID = require("pid")
local pos = ship.getWorldspacePosition()
local h = -30
local left_jet = peripheral.wrap("left")
local right_jet = peripheral.wrap("right")
local thrust_left, thrust_right
local THRUST = 10000
local nowThrust
local theta = 86

local pid_h = PID.new(0.8, 0, 0.3)
local adjust_h = 0
local jet_angle = 0

local shipc = peripheral.wrap("front")
local a, b, c = 0, 0, 0

local per = peripheral.wrap("bottom")
local cannonp = peripheral.wrap("back")

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
redstone.setAnalogOutput("front", 1)
while true do
    sleep(0.05)
    if redstone.getAnalogInput("left") == 15 then
        a = 10
    end
    if redstone.getAnalogInput("right") == 15 then
        a = -10
    end
    if redstone.getAnalogInput("front") == 15 then
        c = 10
        jet_angle = -math.rad(theta)
        nowThrust = THRUST / math.cos(math.rad(theta))
    elseif redstone.getAnalogInput("back") == 15 then
        c = -10
        jet_angle = math.rad(theta)
        nowThrust = THRUST / math.cos(math.rad(theta))
    else
        jet_angle = 0
        nowThrust = THRUST
    end
    shipc.move(a, b, c)
    if redstone.getAnalogInput("bottom") == 15 then
        h = h - 2
    elseif redstone.getAnalogInput("top") == 15 then
        h = h + 2
    end
    pos = ship.getWorldspacePosition()
    adjust_h = pid_h:compute(h, pos.y)
    thrust_left = adjust_h * nowThrust / 2
    thrust_right = adjust_h * nowThrust / 2
    a, b, c = 0, 0, 0
    left_jet.setOutputThrust(math.clamp(thrust_left, -1400000000, 1400000000))
    right_jet.setOutputThrust(math.clamp(thrust_right, -1400000000, 1400000000))
    left_jet.setHorizontalTilt(jet_angle)
    right_jet.setHorizontalTilt(jet_angle)
    local npitch, nyaw = viewRotToAngle(per)
    nyaw = calculateYaw(nyaw)
    npitch = -npitch
    controlCannon(cannonp, npitch, nyaw)
    term.setCursorPos(1, 1)
    print(("Y=%.1f"):format(pos.y))
    term.setCursorPos(1, 2)
    print(("H=%d"):format(h - 6))
    term.setCursorPos(1, 3)
    print(("Yaw: %.2f Pitch: %.2f"):format(nyaw, npitch))
    sleep(0.05)
end
