# Step 1: Prepare the data (for ages 60 and above)
# Define the Gompertz survival function
gompertz_survival <- function(b, eta, x) {
  Sx <- exp(-b / eta * (exp(eta * x) - 1))
  return(Sx)
}


data <- read.csv ("markov ONS stats.csv")


# Define the Gompertz mortality function q_x
gompertz_mortality <- function(b, eta, x) {
  Sx <- gompertz_survival(b, eta, x)
  qx <- 1 - Sx
  # Constrain qx to avoid numerical issues (values should be between 1e-10 and 1 - 1e-10)
  qx <- pmin(pmax(qx, 1e-10), 1 - 1e-10)
  return(qx)
}

# Step 2: Calculate the sample mean and variance of (observed data)
sample_mean <- mean(data)
sample_variance <- var(data)

# Step 3: Define the method to solve for b and eta using the Method of Moments
solve_parameters <- function(params) {
  b <- params[1]
  eta <- params[2]
  
  # Theoretical moments for the Gompertz distribution
  theoretical_mean <- log(eta + 1) / b
  theoretical_variance <- (log(eta + 1))^2 / b^2
  
  # Objective function: Sum of squared differences between sample moments and theoretical moments
  mean_diff_squared <- (sample_mean - theoretical_mean)^2
  variance_diff_squared <- (sample_variance - theoretical_variance)^2
  
  # Return the sum of squared differences (MoM estimation)
  return(mean_diff_squared + variance_diff_squared)
}

# Step 4: Set reasonable starting guesses for b and eta
start_params <- c(b = 0.1076842, eta = 1.086351e-05 )  # Reasonable initial guesses for b and eta

# Step 5: Perform optimization using the optim() function
optim_results <- optim(
  par = start_params,
  fn = solve_parameters,
  method = "L-BFGS-B",  # Constrained optimization method
  lower = c(0.8, 1.071e-05 ),  # Lower bounds for b and eta
  upper = c(0.15, 1.09e-05 )         # Upper bounds for b and eta
)

# Step 6: Extract optimized parameters (b and eta)
b_mom <- optim_results$par[1]
eta_mom <- optim_results$par[2]

# Step 7: Print the results
cat("Method of Moments Estimates:\n")
cat("b (scale parameter):", b_mom, "\n")
cat("eta (shape parameter):", eta_mom, "\n")


predicted_qx_mom <- gompertz_mortality(b_mom, eta_mom, deathstats_60on$Age)


# Step 9: Plot observed vs predicted qx for MoM
plot(deathstats_60on$Age, deathstats_60on$qx, type = "b", col = "blue",
     main = "Observed vs Predicted Mortality Rate (qx) using MoM",
     xlab = "Age", ylab = "Mortality Rate (qx)", pch = 16, cex = 1.2)
lines(deathstats_60on$Age, predicted_qx, col = "red", lwd = 2)  # Predicted qx using MoM
legend("topright", legend = c("Observed qx", "Predicted qx (MoM)"), col = c("blue", "red"), lty = 1, cex = 0.8)
print(predicted_qx)


# Plot observed vs predicted qx for Gompertz distribution
par(mfrow = c(1, 1))  # Single plot window

# Plot observed qx values
plot(deathstats_60on$Age, deathstats_60on$qx, type = "b", col = "blue",
     main = "Observed vs Predicted Mortality Rate (qx) using Gompertz Distribution",
     xlab = "Age", ylab = "Mortality Rate (qx)", pch = 16, cex = 1.2,
     xlim = c(min(deathstats_60on$Age), max(deathstats_60on$Age)), ylim = c(0, 0.5))

# Add predicted qx values (Gompertz) as a red line with increased line width
lines(deathstats_60on$Age, predicted_qx, col = "red", lwd = 2)  # Red line with increased thickness

# Add a legend to the plot to distinguish between observed and predicted qx
legend("topright", legend = c("Observed qx", "Predicted qx (Gompertz)"),
       col = c("blue", "red"), lty = 1, cex = 0.8)













# Load required libraries
library(flexsurv)

# Assuming you have UK mortality data for men aged 60 and above
# Replace this with your actual data
uk_mortality_data <- read_excel("markov_ONS_stat")

# Fit Gompertz distribution using MLE
gompertz_fit <- flexsurvreg(Surv(uk_mortality_data) ~ 1, dist = "gompertz")

# Extract estimated parameters
shape <- gompertz_fit$coefficients[1]
rate <- exp(gompertz_fit$coefficients[2])

# Print results
cat("Estimated Gompertz parameters:\n")
cat("Shape (b):", shape, "\n")
cat("Rate (η):", rate, "\n")

# Plot the fitted distribution
plot(gompertz_fit, main = "Fitted Gompertz Distribution")
```
