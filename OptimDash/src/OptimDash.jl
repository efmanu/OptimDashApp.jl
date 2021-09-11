module OptimDash

include("render_funcs.jl")
include("optim_funcs.jl")
using Dash, DashBootstrapComponents
using DashHtmlComponents, DashCoreComponents
using PlotlyJS
using Optim

#Initialize channel to get data during optimization
chn = Base.Channel{Vector{Float64}}(Inf)
x_graph = []
y_graph = []
y_graph1 = []
itr = 0
eval_f = nothing

function make_app()
    global chn, x_graph, y_graph, itr, eval_f

    chn = Base.Channel{Vector{Float64}}(Inf)
    x_graph = []
	y_graph = []
    y_graph1 = []
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
        State("dopt-user-func-init", "value")
    ) do n_clicks, user_funcs, funcs_init
        ctx = callback_context()
        if isempty(ctx.triggered) || (user_funcs isa Nothing) || (funcs_init isa Nothing)
            throw(PreventUpdate())
        end
        global chn, eval_f, x_graph, y_graph, y_graph1, itr
        x_graph = []
        y_graph = []
        y_graph1 = []
        itr = 0
        eval_f, init_f = eval_definition(user_funcs, funcs_init)
        if length(init_f) != 2
            throw(PreventUpdate())
        end

        function g(f)
            function _g(x)
                put!(chn, x)
                return Base.invokelatest(f,x)
            end
            return _g
        end
        @async optimize(g(eval_f), init_f)
        return render_liveupdates()
    end

    callback!(app,
        Output("dopt-heat-map", "figure"),
        Output("dopt-params-state", "figure"),
        Output("interval-component", "disabled"),
        Input("interval-component", "n_intervals"),
        State("dopt-heat-map", "figure"),
        State("dopt-params-state", "figure"),
        prevent_initial_call=true) do n, heat_fig, state_fig
        st = false
        global x_graph, y_graph, y_graph1, chn, itr, eval_f
        if isready(chn)
            val = take!(chn)
            itr += 1
            append!(x_graph, itr)
            append!(y_graph, val[1])
			append!(y_graph1, val[2])
        else
            st = true
        end
        z = eval_f.(vcat.(y_graph, y_graph1'))
        fig = PlotlyJS.plot(heatmap(x = y_graph, y = y_graph1, z = z))
        return fig,
            Dict(
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
