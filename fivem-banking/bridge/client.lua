Bridge = {}

---@param kind 'success' | 'error' | 'inform'
function Bridge.Notify(message, kind)
    lib.notify({ title = 'Banque', description = message, type = kind or 'inform' })
end
