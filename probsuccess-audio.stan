// Probability of success model
// Author: David Issa Mattos
// Date: 16 June 2020
//
//

data {
 int <lower=1> N_total; // Sample size
 int y[N_total]; // Result of the binomial
 int N_draw[N_total]; // Number of draws in the binomial
 
 real x_noise[N_total];//predictor for noise
 
 //To model each algorithm independently
 int <lower=1> N_algorithm; // Number of algorithms
 int algorithm_id[N_total]; //vector that has the id of each algorithm
 
 //To model the influence of each benchmark
 int <lower=1> N_bm;
 int bm_id[N_total];
}

parameters {
  //Fixed effect
  real a_alg[N_algorithm];//the mean effect given by the algorithms
  real b_noise[N_algorithm];//slope for the noise

  // //Random effect. The effect of the benchmarks
  real a_bm_norm[N_bm];//the mean effect given by the base class type
  real<lower=0> s;//std for the random effects
  
}

model {
  real p[N_total];
  
  //Fixed effect
  a_alg ~ normal(0,8.5);
  b_noise ~ normal(0,8.5);

  // //Random effects
  s ~ exponential(1.9);
  a_bm_norm ~ normal(0,1);

  for (i in 1:N_total)
  {
    
     p[i] = a_alg[algorithm_id[i]]+ a_bm_norm[bm_id[i]]*s + b_noise[algorithm_id[i]] * x_noise[i];
  }
  
  //Equivalent to: y~binomial(N, inverse_logit(a+bx=alpha))
  y ~ binomial_logit(N_draw,p);
}

//Uncoment this part to get the posterior predictives and the log likelihood
//But note that it takes a lot of space in the final model
 generated quantities{
   vector[N_total] y_rep;
   vector[N_total] log_lik;

   
   for(i in 1:N_total){
     real p;
     
     p = a_alg[algorithm_id[i]]+ a_bm_norm[bm_id[i]]*s + b_noise[algorithm_id[i]] * x_noise[i];
     y_rep[i] = binomial_rng(N_draw[i], inv_logit(p));
     
     //Log likelihood
      log_lik[i] = binomial_lpmf(y[i] | N_draw[i], inv_logit(p));
   }
 }
