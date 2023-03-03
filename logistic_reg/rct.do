/******************************************************************
Study Design: RCT
Outcome: Infectious disease 
Intervention: Vaccination
*******************************************************************/

clear all
scalar p1 = .10
scalar p2 = .18
di "Odds Ratio = " (p1*(1 - p2))/(p2*(1 - p1))
di "Risk difference (delta) = " p2 - p1

power twoproportions .18 .10, power(.8)
local obs = r(N)

// Generate one study
set obs `obs'
set seed 20230302
gen vaccine = rbinomial(1, .5)
label define vaccine 0 "Control" 1 "Intervention"
label value vaccine vaccine 
tab vaccine
gen dengue = rbinomial(1, invlogit(-1.5 + ln(0.51)*vaccine))
tab dengue vaccine, col

logit dengue vaccine, or

// Simulate a large number of studies
capture program drop sim_vacc 
program define sim_vacc, rclass
drop _all 
	set obs 590
	gen x = rbinomial(1,.5)
	gen Y = rbinomial(1, invlogit(-1.5+ln(0.51)*x))
	logit Y x
	return scalar b1 = _b[x]
	return scalar se_b1 = _se[x]
	test _b[x] = 0 
	return scalar p = r(p)
end 

simulate b1 = r(b1) se_b1 = r(se_b1) p = r(p) , reps(1000) seed(20230302): sim_vacc

// Simulated power
count if p < 0.05
di "Simulated power = " r(N)/c(N)*100 "%"
