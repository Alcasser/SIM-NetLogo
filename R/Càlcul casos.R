# install.packages("rstudioapi") # run this if it's your first time using it to install
library(rstudioapi) # load it
# the following line is for getting the path of your current open file
current_path <- getActiveDocumentContext()$path 
# The next line set the working directory to the relevant one:
setwd(dirname(current_path ))

# Importem les dades de la prova pilot
library(readxl)
# Importa experiment 1
exp1 <- read_excel("exp1.xlsx", 
col_types = c("blank", "blank", "blank", "blank", "numeric"))
exp1 <- exp1$`mean-waiting-time / ticks-per-minute`
# Importa experiment 2
exp2 <- read_excel("exp2.xlsx", 
                   col_types = c("blank", "blank", "blank", "blank", "numeric"))
exp2 <- exp2$`mean-waiting-time / ticks-per-minute`
# Importa experiment 3
exp3 <- read_excel("exp3.xlsx", 
                   col_types = c("blank", "blank", "blank", "blank", "numeric"))
exp3 <- exp3$`mean-waiting-time / ticks-per-minute`
# Importa experiment 4
exp4 <- read_excel("exp4.xlsx", 
                   col_types = c("blank", "blank", "blank", "blank", "numeric"))
exp4 <- exp4$`mean-waiting-time / ticks-per-minute`

# Nombre de rèpliques
n <- length(exp1)

## RESULTATS EXPERIMENT 1
sink("Exp1.txt")
cat("Nombre de rèpliques =", n, "\n\n\n")
cat("CAS 1: capacitat (A) = 350 (-), exp sortides (B) = 4.0 (-)\n")
# Mitjana
X1 <- mean(exp1)
cat("Mitjana =", X1, "\n")
# Desviació
S1 <- sd(exp1)
cat("Desviació =", S1, "\n")
# Semi-amplada de l'interval de confiança
h1 <- qt(0.975, n-1) * S1/sqrt(n)
# Interval de confiança del 95%
IC1 <- c(X1 - h1, X1 + h1)
cat("Interval de confiança (α = 0.05) = [", IC1[1], ",", IC1[2], "]", "\n")
sink()

## RESULTATS EXPERIMENT 2
sink("Exp2.txt")
# Nombre de rèpliques
cat("Nombre de rèpliques =", n, "\n\n\n")
cat("CAS 2: capacitat (A) = 350 (-), exp sortides (B) = 1.0 (+)\n")
# Mitjana
X2 <- mean(exp2)
cat("Mitjana =", X2, "\n")
# Desviació
S2 <- sd(exp2)
cat("Desviació =", S2, "\n")
# Semi-amplada de l'interval de confiança
h2 <- qt(0.975, n-1) * S2/sqrt(n)
# Interval de confiança del 95%
IC2 <- c(X2 - h2, X2 + h2)
cat("Interval de confiança (α = 0.05) = [", IC2[1], ",", IC2[2], "]", "\n")
sink()

## RESULTATS EXPERIMENT 3
sink("Exp3.txt")
# Nombre de rèpliques
cat("Nombre de rèpliques =", n, "\n\n\n")
cat("CAS 3: capacitat (A) = 700 (+), exp sortides (B) = 4.0 (-)\n")
# Mitjana
X3 <- mean(exp3)
cat("Mitjana =", X3, "\n")
# Desviació
S3 <- sd(exp3)
cat("Desviació =", S3, "\n")
# Semi-amplada de l'interval de confiança
h3 <- qt(0.975, n-1) * S3/sqrt(n)
# Interval de confiança del 95%
IC3 <- c(X3 - h3, X3 + h3)
cat("Interval de confiança (α = 0.05) = [", IC3[1], ",", IC3[2], "]", "\n")
sink()

## RESULTATS EXPERIMENT 4
sink("Exp4.txt")
# Nombre de rèpliques
cat("Nombre de rèpliques =", n, "\n\n\n")
cat("CAS 4: capacitat (A) = 700 (+), exp sortides (B) = 1.0 (+)\n")
# Mitjana
X4 <- mean(exp4)
cat("Mitjana =", X4, "\n")
# Desviació
S4 <- sd(exp4)
cat("Desviació =", S4, "\n")
# Semi-amplada de l'interval de confiança
h4 <- qt(0.975, n-1) * S4/sqrt(n)
# Interval de confiança del 95%
IC4 <- c(X4 - h4, X4 + h4)
cat("Interval de confiança (α = 0.05) = [", IC4[1], ",", IC4[2], "]", "\n")
sink()


## GUARDEM RESUM DE RESULTATS
sink("Resum resultats.txt")
# Nombre de rèpliques
n <- length(exp1)
cat("Nombre de rèpliques =", n, "\n\n\n")
cat("CAS 1: capacitat (A) = 350 (-), exp sortides (B) = 4.0 (-) =", X1, "\n")
cat("CAS 2: capacitat (A) = 350 (-), exp sortides (B) = 1.0 (+) =", X2, "\n")
cat("CAS 3: capacitat (A) = 700 (+), exp sortides (B) = 4.0 (-) =", X3, "\n")
cat("CAS 4: capacitat (A) = 700 (+), exp sortides (B) = 1.0 (+) =", X4, "\n")
sink()