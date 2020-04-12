# Generate data for donors
n_donors <- 2000

donor_id <- 1:n_donors
name <- do.call(paste0, replicate(5, sample(LETTERS, n_donors, TRUE), FALSE))
gender <- sample(c("M", "F"), n_donors, replace = TRUE, prob = c(0.45, 0.55))
donors <- data.frame(donor_id = donor_id, name = name, gender = gender)

# Generate data for gifts
n_transactions <- 10000
start_date <- as.Date('2005/01/01')
end_date <- as.Date('2008/10/31')

transaction_id <- 1:n_transactions
donor_id <- sample(donor_id, n_transactions, replace = TRUE)
date <- sample(seq(start_date, end_date, by="day"), n_transactions, replace = TRUE)
amount <- round(runif(n_transactions, min = 20, max = 120), 0)
campaign <- sample(paste("campaign", 1:12), n_transactions, replace = TRUE)
gifts <- data.frame(transaction_id = transaction_id, donor_id = donor_id,
                    date = date, amount = amount, campaign = campaign)

# Write data to text files
write.table(donors, "donors.txt", sep = "\t", row.names = FALSE, quote = FALSE)
write.table(gifts, "gifts.txt", sep = "\t", row.names = FALSE, quote = FALSE)
