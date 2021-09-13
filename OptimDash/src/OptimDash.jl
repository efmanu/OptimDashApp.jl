module OptimDash

include("render_funcs.jl")
using Dash, DashBootstrapComponents
using DashHtmlComponents, DashCoreComponents
using PlotlyJS
using Optim

function eval_definition(strs...)
    return eval.(Meta.parse.(strs))
end

#Initialize channel to get data during optimization
chn = Base.Channel{Vector{Float64}}(Inf)
x_graph = []
y_graph = []
y_graph1 = []
itr = 0
eval_f = nothing
range_value = []

function make_app()
    global chn, x_graph, y_graph, itr, eval_f
    global range_value

    chn = Base.Channel{Vector{Float64}}(Inf)
    x_graph = []
	y_graph = []
    y_graph1 = []
    range_value = []
    itr = 0
    eval_f = nothing
    
    external_stylesheets = "https://cdnjs.cloudflare.com/ajax/libs/font-awesome/4.7.0/css/font-awesome.min.css"
    app = dash(external_stylesheets=[dbc_themes.BOOTSTRAP,external_stylesheets], 
	    suppress_callback_exceptions=true)
    
    app.layout = html_div([
        render_all()
    ])
    callback!(app,
        Output("dopt-params-plot-loc", "children"),      
        Input("dopt-btn-optim", "n_clicks"),
        State("dopt-user-funcs", "value"),
        State("dopt-user-func-init", "value"),
    ) do n_clicks, user_funcs, funcs_init
        ctx = callback_context()
        if isempty(ctx.triggered) || (user_funcs isa Nothing) || (funcs_init isa Nothing)
            throw(PreventUpdate())
        end
        global chn, eval_f, x_graph, y_graph, y_graph1, itr
        global range_value
        
        itr = 0
        eval_f, init_f = eval_definition(
            user_funcs, funcs_init,
        )
        x_graph = [0]
        y_graph = [init_f[1]]
        y_graph1 = [init_f[2]]

        if length(init_f) != 2
            throw(PreventUpdate())
        end

        global prevx = copy(init_f)
        function g(f)
            function _g(x)
                global prevx
                if !isapprox(x, prevx, atol = 1e-4)
                    put!(chn, x)
                    prevx = copy(x)
                end
                return Base.invokelatest(f, x)
            end
            return _g
        end
        alg = BFGS()
        @async optimize(g(eval_f), init_f, alg, Optim.Options(x_abstol = 1e-3, f_abstol = 1e-3, g_abstol = 1e-3, f_calls_limit = 100))
        return render_liveupdates()
    end

    callback!(app,
        Output("dopt-params-state", "figure"),
        Output("interval-component", "disabled"),
        Input("interval-component", "n_intervals"),
        State("dopt-params-state", "figure"),
        prevent_initial_call=true) do n, state_fig
        st = false
        global x_graph, y_graph, y_graph1, chn, itr, eval_f
        global range_value
        if isready(chn)
            val = take!(chn)
            itr += 1
            append!(x_graph, itr)
            append!(y_graph, val[1])
			append!(y_graph1, val[2])
        else
            st = true
        end
        return Dict(
                "data" => [
                    Dict(
                        "x" => x_graph,
                        "y" => y_graph,
                        "mode" => "line",
                    ),  
                    Dict(
                        "x" => x_graph,
                        "y" => y_graph1,
                        "mode" => "line",
                    )
                ]
            ), st
    end
    return app
end

end # module
