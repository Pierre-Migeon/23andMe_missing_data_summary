

library(Hmisc)
summary <- read.table(file ="/Users/pierre/bioinformatics/23andme/missing_data/update2/data.summary.txt", header = TRUE, sep = "\t", row.names = 1)
#Plotting correlation between gene density and SNP density:
summary <- summary[-grep("MT", rownames(summary)),]
tiff("../output/gene_density_vs_SNP_density.tiff", width = 9, height = 6, units = 'in', res = 300)
plot(summary$SNP_density, summary$gene_density, col = "black", main = "Gene density as a function of SNP density", ylab = "Gene Density", xlab = "SNP density" )
minor.tick(nx = 3, ny = 3)
mod <- lm(summary$gene_density ~ summary$SNP_density, data = summary)
abline(mod, col ="purple")
legend("topright", text.col = "red", cex = 0.8,  legend=paste("R^2 = ",format(summary(mod)$adj.r.squared)), bty = "n")
legend("topright", text.col = "blue", cex = 0.8, legend=paste("\np = ",format(summary(mod)$coefficients[2,4])), bty = "n")
dev.off()
