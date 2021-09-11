function eval_definition(fn, init_val)
    return eval(Meta.parse(fn)), eval(Meta.parse(init_val))
end
