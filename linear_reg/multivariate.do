clear all 
set obs 5000
set seed 20230223
gen pa = rbinomial(1, .3)
gen ha = rbinomial(1, .4)
gen waist = rnormal(90-2*pa-1*ha,12)
gen response= rbinomial(1, .4)
keep if response == 1 
regress waist pa ha 

capture program drop sim_waist
program define sim_waist, rclass 
drop _all 
	set obs 5000
	gen pa = rbinomial(1, .3)
	gen ha = rbinomial(1, .4)
	gen waist = rnormal(90-2*pa-1*ha,12)
	gen response= rbinomial(1, .4)
	keep if response == 1 
	regress waist pa ha 
	
	return scalar est_b1 = _b[pa]
	return scalar est_se_b1 = _se[pa]
	return scalar est_b2 = _b[ha]
	return scalar est_se_b2 = _se[ha]
	test pa 
	return scalar p_pa = r(p)
	test ha  
	return scalar p_ha = r(p)
	testparm pa ha
	return scalar p_com = r(p)
end 

simulate est_b1 = r(est_b1) est_se_b1 = r(est_se_b1) /// 
	est_b2 = r(est_b2) est_se_b2 = r(est_se_b2) /// 
	p_pa = r(p_pa) p_ha = r(p_ha) p_com = r(p_com), reps(1000) seed(20230323): sim_waist

count if p_pa < 0.05 
di "Simulated power of an independent effect of PA = " r(N)/c(N)*100 "%"

count if p_ha < 0.05 
di "Simulated power of an independent effect of HA = " r(N)/c(N)*100 "%"

count if p_com < 0.05
di "Simulated power of a joint effect of PA and HA = " r(N)/c(N)*100 "%"
