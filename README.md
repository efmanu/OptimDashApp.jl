# Dash Optim App
Web app to optimize functions of 2 variables using Optim.jl, created with Dash.jl.

NB: Only functions with 2 parameters

### Run DashOptim App
From the project folder, enter the following commands in Julia REPL
```julia
    julia>using Pkg
    julia>Pkg.activate(".")
    julia>include("run.jl")
```
### Run Optimization
![Animation6](https://user-images.githubusercontent.com/22251968/133268423-16f3e186-486a-4ef6-af10-a12281c6960a.gif)

### Deploy in Herokuapp
From the project folder, enter the following commands in command line/terminal etc.
```
heroku login #then login to heroku app with your credentials
git push heroku master
```
Sometimes push won't work, then do

```
git push heroku master:master -f
```
