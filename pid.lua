-- pid.lua
-- PID 控制器模块
local PID = {}

-- 创建新 PID 实例
function PID.new(Kp, Ki, Kd)
    local self = {
        Kp = Kp or 0.0,  -- 比例系数
        Ki = Ki or 0.0,  -- 积分系数
        Kd = Kd or 0.0,  -- 微分系数

        integral = 0.0,    
        prev_error = 0.0,  
        prev_time = nil,   

        integral_min = -math.huge,  
        integral_max = math.huge    
    }

    -- 设置积分限幅
    function self:setIntegralLimit(min, max)
        self.integral_min = min
        self.integral_max = max
        return self
    end

    -- 计算 PID 输出
    function self:compute(setpoint, measurement)
        local error = setpoint - measurement
        local current_time = os.clock()
        local dt = 0.0

        
        if self.prev_time then
            dt = current_time - self.prev_time
        else
            dt = 0.0
        end
        self.prev_time = current_time

        
        local P = self.Kp * error

        
        if dt > 0 then
            self.integral = self.integral + error * dt
            
            self.integral = math.clamp(self.integral, self.integral_min, self.integral_max)
        end
        local I = self.Ki * self.integral

        
        local D = 0.0
        if dt > 0 then
            local derivative = (error - self.prev_error) / dt
            D = self.Kd * derivative
        end
        self.prev_error = error

        return P + I + D
    end

    
    function self:reset()
        self.integral = 0.0
        self.prev_error = 0.0
        self.prev_time = nil
        return self
    end

    return self
end


function math.clamp(value, min_val, max_val)
    return math.min(math.max(value, min_val), max_val)
end

return PID