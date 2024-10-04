# A simulation-based approach to teach biostatistics in health sciences
Despite the increasing relevance of statistics in health sciences, teaching styles in higher education are remarkably similar across disciplines: lectures covering the theory and methods, followed by application and computer exercises in given data sets. This often leads to challenges for students in comprehending fundamental statistical concepts essential for medical research. What ca we do about it? We propose to use simulations to teach statistics :chart_with_downwards_trend: in a medical context :hospital:. We describe our thought-process and many examples in three peer-reviewed papers: [Paper 1](https://mededu.jmir.org/2024/1/e52679/), [Paper II](https://doi.org/10.1080/26939169.2024.2394536), and [Paper III](https://www.tandfonline.com/doi/full/10.1080/09332480.2024.2348972).

## The Potential of Simulations in Public Health :teacher:
Let's start with an introduction to simulations in public health and epidemiology. In this [paper](https://www.tandfonline.com/doi/full/10.1080/09332480.2024.2348972), we collected our thoughts from multiple discussions about the importance of appreciating and embracing statistical thinking in public health research and education. We think that statistical simulations can play an important role in fostering statistical reasoning in public health and that they can be a great didactic tool for students to generate and learn from data. Two main points are of relevance here. First, simulations can foster critical thinking and improve our reasoning about public health problems by going from theoretical thoughts to practical implementation of designing a computer experiment. Second, simulations can support researchers and their students to better understand statistical concepts used when describing and analysing population health in terms of distributions. Overall, we advocate for the use of more simulations in public health research and education to strengthen statistical reasoning when studying the health of populations.

## DICE (Design, Interpret, Compute, Experiment) :game_die:
How can we teach statistics in health sciences? We propose a teaching and learning method that we call DICE (Design, Interpret, Compute, Experiment). That's how it works: Students will work in small groups to plan, generate, analyze, interpret, and communicate their own scientific investigation with simulations. With a focus on fundamental statistical concepts such as sampling variability, error probabilities, and the construction of statistical models, DICE offers a promising approach to learning how to combine substantive medical knowledge and statistical concepts. These are the steps involved in the group activity:

![DICE_flowchart-6](https://github.com/user-attachments/assets/48b347f4-97dc-43a9-97ba-1c1ff15305e4)

## Simulations to teach interaction effects :green_circle::yellow_circle:
How do we know that it works? We evaluated the approach in a 3-hour long workshop on teaching interaction effects to graduate students. In this [paper](https://doi.org/10.1080/26939169.2024.2394536), we describe the steps involved in organizing and implementing a simulation-based activity and present the results and evaluation from our workshop. Additionally, the article contains materials for students and teachers to get started with simulations and interaction effects. 

![interaction](https://github.com/user-attachments/assets/e2a1910b-040b-414f-ad8c-8c7ea093a207)

# Simple example
Let's go through a simple example: comapring expectations vs. theory. A longer description of the example is available [here](https://www.tandfonline.com/doi/full/10.1080/09332480.2024.2348972). Let us create a function or program that allows us to generate data for a single study with two variables, X and Y. We are interested in the effect of X on Y. The true effect is quantified as the OR of X (OR=3.9). 

```ruby

capture program drop sim_exp1
program define sim_exp1, rclass
	drop _all 
	local n = 1000
	local py_1 = .3
	local py_0 = .1
	local x_p = .2
	
	qui set obs `n'
	qui gen x = rbinomial(1, `x_p')
	qui gen y = .
	qui replace y = rbinomial(1, `py_1') if x == 1
	qui replace y = rbinomial(1, `py_0') if x == 0

	logit y x ,or
	return scalar est_b = _b[x]
	return scalar est_se_b = _se[x]
end

```

When we call the program, we simulate the study once under the outlined mechanisms.

```ruby

sim_exp1 

```

We can replicate the same study a large number of times to start reasoning in terms of distributions.

```ruby

simulate est_b = r(est_b)  est_se_b = r(est_se_b) , seed(23016) reps(1000) : sim_exp1

```

We can now compare what we expected versus what we observed after replicating the same study many times.

```ruby

summarize  est_b
di exp(r(mean))

* Expected mean and std deviation
di (60/140)/(80/720)
di sqrt(1/60+1/140+1/80+1/720)

scalar t_b = ln( (60/140)/(80/720) )
scalar t_se_b = sqrt(1/60+1/140+1/80+1/720)
di t_b+invnormal(.005)*t_se_b
di t_b+invnormal(.995)*t_se_b
di exp(t_b+invnormal(.005)*t_se_b)
di exp(t_b+invnormal(.995)*t_se_b)
summarize

```

We can visualise the sampling and theoretical distribution and see that the sampling distribution is approximately normal, centered around the mean of 3.9.

![figure_1](https://github.com/user-attachments/assets/11904739-2966-457a-850d-5c1dbf731e05)


## References
Thiesmeier, R. & Orsini, N. (2024). Rolling the DICE (Design, Interpret, Compute, Estimate): Interactive Learning of Biostatistics with Simulations.[JMIR].(https://mededu.jmir.org/2024/1/e52679/)

Orsini, N., Thiesmeier, R., & Båge, K. (2024). A Simulation-Based Approach to Teach Interaction Effects in Postgraduate Biostatistics Courses. [Journal of Statistics and Data Science Education](https://doi.org/10.1080/26939169.2024.2394536)

Thiesmeier, R. & Orsini, N. (2024) Teaching Statistics in Health Sciences: The Potential of Simulations in Public Health. [Chance](https://www.tandfonline.com/doi/full/10.1080/09332480.2024.2348972).
