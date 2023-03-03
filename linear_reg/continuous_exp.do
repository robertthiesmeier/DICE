/**************************************************************
Study design: 1-year cross sectional
Outcome: Systolic Blood pressure
Intervention: Air pollution
***************************************************************/

// Sample size calculation
power oneslope 0 0.5, sdx(4.2) sderror(4.9)

// Generate one study
clear all
set obs 45
set seed 20230224
gen air = rnormal(17.6, 4.2)
gen sys = rnormal(120 + 0.5*air, 4.9)
reg sys air


// Simulation Program
capture program drop sysair
program define sysair, rclass 
drop _all 
	set obs 45
	gen air = rnormal(17.6, 4.2)
	gen sys = rnormal(120 + 0.5*air, 4.6)

	reg sys air
	return scalar b1 = _b[air]
	return scalar se_b1 = _se[air]
	test _b[air] = 0
	return scalar p = r(p)
end 

// Simulate one study 
sysair 

// Simulate 1,000 studies
simulate b1 = r(b1) se_b1 = r(se_b1) p = r(p), reps(1000): sysair

// simulated power
qui count if p < 0.05
di "Simulated Power = " r(N)/c(N)*100 "%"

// average linear adjusted effect of x on y
summarize b1
