using Test
using Random
using UnitTestDesign


### total_combinations
tc_trials = [
    [[2, 2, 2], 2, 12],
    [[2, 3, 2], 2, 16],
    [[2, 3, 2, 2], 2, 6+4+4+6+6+4],
    [[2, 3, 2, 2], 3, 12+12+8+12]
]
for trial in tc_trials
    res = UnitTestDesign.total_combinations(trial[1], trial[2])
    @test res == trial[3]
end


### combination_number

for cn_a in 1:6
    for cn_b in 1:cn_a
        @test UnitTestDesign.combination_number(cn_a, cn_b) == factorial(cn_a) ÷ (factorial(cn_a - cn_b) * factorial(cn_b))
    end
end


### next_multiplicative
arity0 = [3, 7, 9, 4]
vv0 = copy(arity0)
UnitTestDesign.next_multiplicative!(vv0, arity0)
@test vv0 == [1, 1, 1, 1]
vv = [1,1,1]
nmarity = [2,3,2]
for i in 1:prod(nmarity)
    UnitTestDesign.next_multiplicative!(vv, nmarity)
end
@test vv == [1, 1, 1]


### all_combinations
rng = MersenneTwister(9237425)
for ac_trial_idx in 1:5
    n_way = [2, 3, 4][rand(rng, 1:3)]
    param_cnt = rand(rng, (n_way + 1):(n_way + 3))
    arity = rand(rng, 2:4, param_cnt)
    coverage = UnitTestDesign.all_combinations(arity, n_way)
    # It has the right column dimnsion.
    @test size(coverage, 2) == length(arity)
    # Every combination is nonzero.
    @test sum(sum(coverage, dims = 2) == 0) == 0
    # The total number of combinations agrees with expectations.
    @test UnitTestDesign.total_combinations(arity, n_way) == size(coverage, 1)
    # Generate some random combinations and check that they are in there.
    for comb_idx in 1:100
        comb = [rand(rng, 1:arity[cj]) for cj in 1:param_cnt]
        comb[randperm(rng, param_cnt)[1:(param_cnt - n_way)]] .= 0
        @test sum(comb .!= 0) == n_way
        found = false
        for sidx in 1:size(coverage, 1)
            if coverage[sidx, :] == comb
                found = true
            end
        end
        @test found
    end
end


### one_parameter_combinations(arity, n_way)

minimal = UnitTestDesign.one_parameter_combinations([2, 3], 1)
@test minimal == [0 1; 0 2; 0 3]

paired = UnitTestDesign.one_parameter_combinations([2, 3], 2)
@test paired == [1 1; 2 1; 1 2; 2 2; 1 3; 2 3]
