module BlockExecExpMax

using JuMP
using Clp
using Test

export find_exp_strategy

function tune_exp_strategy(price, prob, next_dollars, next_unsold)
	model = Model(Clp.Optimizer)
	set_silent(model)
	n = length(price)
	@variable(model, qty[1:n]  >= 0)
	@expression(model, trade[i = 1:n], sum(qty[j] * price[j] for j in 1:i))
	@expression(model, sold[i = 1:n], sum(qty[j] for j in 1:i))
	@expression(model, dollars[i = 1:n], prob[i] * (trade[i] + (1 - sold[i]) * next_dollars))
	@expression(model, unsold[i = 1:n], prob[i] * (1 - sold[i]) * next_unsold)
	@objective(model, Max, sum(dollars))
	@constraint(model, sum(qty[i] for i in 1:n) <= 1)
	optimize!(model)
	for i in 1:length(price)
		println("qty_", i, " = ", getvalue(qty[i]))
	end
	println("bought dollars = ", getvalue(sum(dollars)), " remaining fil = ", getvalue(sum(unsold)))
	return getvalue(sum(dollars)), getvalue(sum(unsold))
end

function find_exp_strategy(price, prob, num_rounds) # -> expected sold revenue, expected unsold
	if num_rounds <= 0
		return 0.0, 1.0
	else
		next_dollars, next_unsold = find_exp_strategy(price, prob, num_rounds-1)
		println("remaing rounds ", num_rounds)
		return tune_exp_strategy(price, prob, next_dollars, next_unsold)
	end
end

function test_exp_strategy()
	find_exp_strategy([150.0, 160.0, 170.0, 300.0], [0.33, 0.33, 0.33, 0.01], 4)
end

end # module
