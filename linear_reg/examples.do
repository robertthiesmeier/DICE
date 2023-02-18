* Example of a RCT 

// sample size calculation 
power twomeans 120 115, sd(10) n(170)

// Generate trial data 
clear all 
set obs 170
set seed 20240224
gen pa = rbinomial(1, .5)
gen bmi = rnormal(120-5*pa, 10)
regress bmi pa 

capture program drop sim_lm
program define sim_lm, rclass
	drop _all
	set obs 170
	gen pa = rbinomial(1, .5)
	gen bmi = rnormal(120-5*pa, 10)
	reg bmi pa 
	return scalar est_b = _b[pa]
	return scalar est_se_b = _se[pa]
	test _b[pa] = 0
	return scalar p = r(p)
end

// Generate one study
sim_lm 

// Generate 1,000 studies

simulate est_b  = r(est_b) est_se_b = r(est_se_b) p =r(p), reps(1000): sim_lm

// describe the sampling distribution of the estimated effect
summarize 

// simulated power
count if p < 0.05
di "Simulated Power (%) = " r(N)/c(N)*100 
