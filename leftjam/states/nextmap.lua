LeftJam = LeftJam or {}
LeftJam.States = LeftJam.States or {}



local function cbrtf(n)
    return n ^ 0.3333333333333333333333
end

local function lerp(t, a, b)
    return a * (1 - t) + b * t
end


--https://bottosson.github.io/posts/oklab/
local function lerp_oklab(t, from, to)
    return {
        L = lerp(t, from.L, to.L),
        a = lerp(t, from.a, to.a),
        b = lerp(t, from.b, to.b),
    }
end


local function linear_srgb_to_oklab(c)
    local l = 0.4122214708 * c[1] + 0.5363325363 * c[2] + 0.0514459929 * c[3]
    local  m = 0.2119034982 * c[1] + 0.6806995451 * c[2] + 0.1073969566 * c[3]
    local s = 0.0883024619 * c[1] + 0.2817188376 * c[2] + 0.6299787005 * c[3]

    local  l_ = cbrtf(l)
    local  m_ = cbrtf(m)
    local  s_ = cbrtf(s)

    return {
        L = 0.2104542553 * l_ + 0.7936177850 * m_ - 0.0040720468 * s_,
        a = 1.9779984951 * l_ - 2.4285922050 * m_ + 0.4505937099 * s_,
        b = 0.0259040371 * l_ + 0.7827717662 * m_ - 0.808675766 * s_,
    }
end

local function oklab_to_linear_srgb(c)
    local l_ = c.L + 0.3963377774 * c.a + 0.2158037573 * c.b
    local m_ = c.L - 0.1055613458 * c.a - 0.0638541728 * c.b
    local s_ = c.L - 0.0894841775 * c.a - 1.2914855480 * c.b

    local l = l_ * l_ * l_
    local m = m_ * m_ * m_
    local s = s_ * s_ * s_

    return {
        4.0767416621 * l - 3.3077115913 * m + 0.2309699292 * s,
        -1.2684380046 * l + 2.6097574011 * m - 0.3413193965 * s,
        -0.0041960863 * l - 0.7034186147 * m + 1.7076147010 * s
    }
end




LeftJam.States[STATE_NEXT_MAP] = {}

LeftJam.States[STATE_NEXT_MAP].init = function()
    --LeftJam.LoadMap("untitled")
    --LeftJam.InitPlayer()
end

LeftJam.States[STATE_NEXT_MAP].think = function(dt)
    --print("Brain activation")
    --LeftJam.PlayerThink(dt)

    --LeftJam.MapThink(dt)
    LeftJam.CamThink(dt)
    --LeftJam.SwitchControllable(dt)
    --LeftJam.MapEndThink(dt)
end

LeftJam.States[STATE_NEXT_MAP].render = function()
    love.graphics.clear(.2, .3, .4)
    love.graphics.setColor(1, 1, 1)
    LeftJam.MapDraw()
    LeftJam.RenderControlSphere()


    -- make gradient
    local w, h = love.graphics.getDimensions()
    LeftJam.RenderOKLabGradient(0, 0, w, h, {24, 24, 24, 242.25}, {32, 128, 64}, 128)
end

LeftJam.States[STATE_NEXT_MAP].exit = function()
end