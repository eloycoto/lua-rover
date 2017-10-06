require('rover.setup')()

local parser = require('rover.vendor').require('argparse')() {
    name = "rover",
    description = "Rover provides consistent environment for Lua projects."
}
local command_target = '_cmd'
parser:command_target(command_target)

local _M = { }

local mt = {}

local function load_commands(commands, parser)
    for i=1, #commands do
        commands[commands[i]] = require('rover.cli.' .. commands[i]):new(parser)
    end
    return commands
end

_M.commands = load_commands({ 'exec', 'install', 'lock' }, parser)

function mt.__call(self, arg)
    -- now we parse the options like usual:
    local ok, ret = self.parse(arg)
    local cmd = ok and ret[command_target]

    if ok and cmd then
        self.commands[cmd](ret)
    elseif ok then
        self.commands.install(ret)
    else
        print(ret)
        os.exit(1)
    end
end

function _M.parse(arg)
    return parser:pparse(arg)
end

return setmetatable(_M, mt)
