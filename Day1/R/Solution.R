# Module 1
calculateFuelRequirement <- function(mass) {
  return(sum(floor(mass / 3) - 2))
}

modulesMass <- scan("input.txt")

total <- calculateFuelRequirement(modulesMass)

sprintf("Total fuel requirement: %s", total)

# Module 2
calculateFuelRequirement2 <- function(mass) {
  # Calculate fuel requirements for all modules
  fuel <- floor(mass / 3) - 2
  # Replace negative fuel with 0
  fuel[fuel < 0] <- 0
  # Call function recursively to calculate all modules' fuel requirements
  if (sum(fuel) > 0) {
    return(sum(fuel, calculateFuelRequirement2(fuel)))
  } else {
    return(0)
  }
}

total2 <- calculateFuelRequirement2(modulesMass)

sprintf("Total fuel requirement: %s", total2)

# Unit tests
library(testthat)

test_that("single number", {
  expect_equal(calculateFuelRequirement(12), 2)
  expect_equal(calculateFuelRequirement(14), 2)
  expect_equal(calculateFuelRequirement(1969), 654)
  expect_equal(calculateFuelRequirement(100756), 33583)
})

test_that("single number", {
  expect_equal(calculateFuelRequirement2(14), 2)
  expect_equal(calculateFuelRequirement2(1969), 966)
  expect_equal(calculateFuelRequirement2(100756), 50346)
  expect_equal(calculateFuelRequirement2(c(1969, 100756)), 51312)
})