/***************************************************************
Study design: cohort
multiple explanatory variables; independent observations
Outcome: Major Depressive Disorder (MDD)
Main exposure: Blood glucose level (mmol/L)
***************************************************************/

clear all 
set obs 15000
set seed 20230302
gen glucose = rnormal(5.1, 0.9)
gen sex = rbinomial(1, 0.4)
gen education = irecode(runiform(), 0.38, 0.7, 0.92, 1)
tab education, gen(ed_dummy) // generate dummy variables
gen MDD = rbinomial(1, invlogit(-2.8+log(1.05)*glucose + log(1.25)*sex + log(0.95)*ed_dummy2 + log(0.8)*ed_dummy3 + log(0.7)*ed_dummy4))
tab MDD 

// apply logistic regression model
logit MDD glucose sex ed_dummy2 ed_dummy3 ed_dummy4
logistic MDD glucose sex ed_dummy2 ed_dummy3 ed_dummy4

// program for the simulation 
capture program drop sim_glucose
program define sim_glucose, rclass 
drop _all 
syntax[, obs(real 15000)]
	set obs `obs'
	gen glucose = rnormal(5.1, 0.9)
	gen sex = rbinomial(1, 0.4)
	gen education = irecode(runiform(), 0.38, 0.7, 0.92, 1)
	tab education, gen(ed_dummy) // generate dummy variables
	gen MDD = rbinomial(1, invlogit(-2.8+log(1.05)*glucose + log(1.25)*sex ///
			+ log(0.95)*ed_dummy2 + log(0.8)*ed_dummy3 + log(0.7)*ed_dummy4))
	logit MDD glucose sex ed_dummy2 ed_dummy3 ed_dummy4
	ret scalar est_b1 = _b[glucose]
	ret scalar est_se_b1 = _se[glucose]
	test glucose 
	ret scalar p = r(p)
end 

// generate one study 
sim_glucose

// simulate 1,000 studies
simulate est_b1 = r(est_b1) est_se_b1 = r(est_se_b1) p = r(p) ///
		,reps(1000) seed(20230302): sim_glucose

gen or1 = exp(est_b1)
gen se_or1 = exp(est_se_b1)
summarize or1 se_or1

// Simulated power 
count if p < 0.05 
di "Simulated Power = " r(N)/c(N)*100 "%"

// Simulation with different sample size
simulate est_b1 = r(est_b1) est_se_b1 = r(est_se_b1) p = r(p) ///
		,reps(1000) seed(20230302): sim_glucose, obs(60000)
count if p < 0.05 
di "Simulated Power = " r(N)/c(N)*100 "%"
