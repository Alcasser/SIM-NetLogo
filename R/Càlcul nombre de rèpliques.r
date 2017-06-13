# install.packages("rstudioapi") # run this if it's your first time using it to install
library(rstudioapi) # load it
# the following line is for getting the path of your current open file
current_path <- getActiveDocumentContext()$path 
# The next line set the working directory to the relevant one:
setwd(dirname(current_path ))

# Importem les dades de la prova pilot
library(readxl)
exp1 <- read_excel("ProvaPilot-exp1.xlsx", 
col_types = c("blank", "blank", "blank", "blank", "numeric"))
exp1 <- exp1$`mean-waiting-time / ticks-per-minute`
exp2 <- read_excel("ProvaPilot-exp2.xlsx", 
                   col_types = c("blank", "blank", "blank", "blank", "numeric"))
exp2 <- exp2$`mean-waiting-time / ticks-per-minute`
exp3 <- read_excel("ProvaPilot-exp3.xlsx", 
                   col_types = c("blank", "blank", "blank", "blank", "numeric"))
exp3 <- exp3$`mean-waiting-time / ticks-per-minute`
exp4 <- read_excel("ProvaPilot-exp4.xlsx", 
                   col_types = c("blank", "blank", "blank", "blank", "numeric"))
exp4 <- exp4$`mean-waiting-time / ticks-per-minute`

# CÀLCUL NÚM. RÈPLIQUES EXPERIMENT 1
sink("repliquesExp1.txt")
# Nombre de rèpliques
n1 <- length(exp1)
cat("Nombre de rèpliques prova pilot =", n, "\n")
# Mitjana
X1 <- mean(exp1)
cat("Mitjana prova pilot =", X1, "\n")
# Desviació
S1 <- sd(exp1)
cat("Desviació prova pilot =", S1, "\n\n")

# Semi-amplada de l'interval de confiança de la prova pilot
h1 <- qt(0.975, n1-1) * S/sqrt(n1)
cat("Semi-amplada de l'interval de confiança de la prova pilot =", h1, "\n")

# Interval de confiança del 95%
IC1 <- c(X1 - h1, X1 + h1)
cat("Interval de confiança (α = 0.05) = [", IC1[1], ",", IC1[2], "]", "\n")

# Semi-interval de confiança desitjat (95% de confiança)
H1 <- 0.05 * X1
cat("Semi-amplada de l'interval de confiança desitjat (95% de confiança) =", H1, "\n")

# Nombre de rèpliques necessàries
N1 <- n1 * (h1/H1)^2
cat("\nNombre de rèpliques necessàries =", N1, "->", ceiling(N1), "\n")
sink()

# CÀLCUL NÚM. RÈPLIQUES EXPERIMENT 2
sink("repliquesExp2.txt")
# Nombre de rèpliques
n2 <- length(exp2)
cat("Nombre de rèpliques prova pilot =", n, "\n")
# Mitjana
X2 <- mean(exp2)
cat("Mitjana prova pilot =", X2, "\n")
# Desviació
S2 <- sd(exp2)
cat("Desviació prova pilot =", S2, "\n\n")

# Semi-amplada de l'interval de confiança de la prova pilot
h2 <- qt(0.975, n2-1) * S/sqrt(n2)
cat("Semi-amplada de l'interval de confiança de la prova pilot =", h2, "\n")

# Interval de confiança del 95%
IC2 <- c(X2 - h2, X2 + h2)
cat("Interval de confiança (α = 0.05) = [", IC2[1], ",", IC2[2], "]", "\n")

# Semi-interval de confiança desitjat (95% de confiança)
H2 <- 0.05 * X2
cat("Semi-amplada de l'interval de confiança desitjat (95% de confiança) =", H2, "\n")

# Nombre de rèpliques necessàries
N2 <- n2 * (h2/H2)^2
cat("\nNombre de rèpliques necessàries =", N2, "->", ceiling(N2), "\n")
sink()

# CÀLCUL NÚM. RÈPLIQUES EXPERIMENT 3
sink("repliquesExp3.txt")
# Nombre de rèpliques
n3 <- length(exp3)
cat("Nombre de rèpliques prova pilot =", n, "\n")
# Mitjana
X3 <- mean(exp3)
cat("Mitjana prova pilot =", X3, "\n")
# Desviació
S3 <- sd(exp3)
cat("Desviació prova pilot =", S3, "\n\n")

# Semi-amplada de l'interval de confiança de la prova pilot
h3 <- qt(0.975, n3-1) * S/sqrt(n3)
cat("Semi-amplada de l'interval de confiança de la prova pilot =", h3, "\n")

# Interval de confiança del 95%
IC3 <- c(X3 - h3, X3 + h3)
cat("Interval de confiança (α = 0.05) = [", IC3[1], ",", IC3[2], "]", "\n")

# Semi-interval de confiança desitjat (95% de confiança)
H3 <- 0.05 * X3
cat("Semi-amplada de l'interval de confiança desitjat (95% de confiança) =", H3, "\n")

# Nombre de rèpliques necessàries
N3 <- n3 * (h3/H3)^2
cat("\nNombre de rèpliques necessàries =", N3, "->", ceiling(N3), "\n")
sink()

# CÀLCUL NÚM. RÈPLIQUES EXPERIMENT 4
sink("repliquesExp4.txt")
# Nombre de rèpliques
n4 <- length(exp4)
cat("Nombre de rèpliques prova pilot =", n, "\n")
# Mitjana
X4 <- mean(exp4)
cat("Mitjana prova pilot =", X4, "\n")
# Desviació
S4 <- sd(exp4)
cat("Desviació prova pilot =", S4, "\n\n")

# Semi-amplada de l'interval de confiança de la prova pilot
h4 <- qt(0.975, n4-1) * S/sqrt(n4)
cat("Semi-amplada de l'interval de confiança de la prova pilot =", h4, "\n")

# Interval de confiança del 95%
IC4 <- c(X4 - h4, X4 + h4)
cat("Interval de confiança (α = 0.05) = [", IC4[1], ",", IC4[2], "]", "\n")

# Semi-interval de confiança desitjat (95% de confiança)
H4 <- 0.05 * X4
cat("Semi-amplada de l'interval de confiança desitjat (95% de confiança) =", H4, "\n")

# Nombre de rèpliques necessàries
N4 <- n4 * (h4/H4)^2
cat("\nNombre de rèpliques necessàries =", N4, "->", ceiling(N4), "\n")
sink()



sink("Resultat nombre de rèpliques.txt")
cat("CAS 1: capacitat (A) = 350 (-), exp sortides (B) = 4.0 (-) =", ceiling(N1), "\n")
cat("CAS 2: capacitat (A) = 350 (-), exp sortides (B) = 1.0 (+) =", ceiling(N2), "\n")
cat("CAS 3: capacitat (A) = 700 (+), exp sortides (B) = 4.0 (-) =", ceiling(N3), "\n")
cat("CAS 4: capacitat (A) = 700 (+), exp sortides (B) = 1.0 (+) =", ceiling(N4), "\n")
sink()