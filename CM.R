calculate <- function(target, badthre, input, output) {
  docs <- strsplit(input, " ")[[1]]
  result <- data.frame(method = character(), sensitivity = character(), specificity = character(), F1 = character(), logLikelihood = character(), pseudoRsquared = character())
  for (i in 1:length(docs)) {
    data <- read.csv(docs[i])
    
    if(target == "good"){
      TP <- sum(data$pred.score <= badthre & data$reference == "good")
      TN <- sum(data$pred.score > badthre & data$reference == "bad")
      FN <- sum(data$pred.score > badthre & data$reference == "good")
      FP <- sum(data$pred.score <= badthre & data$reference == "bad")
    }else{
      TP <- sum(data$pred.score >= badthre & data$reference == "bad")
      TN <- sum(data$pred.score < badthre & data$reference == "good")
      FN <- sum(data$pred.score < badthre & data$reference == "bad")
      FP <- sum(data$pred.score >= badthre & data$reference == "good")
    }
    
    sensitivity <- TP / (TP + FN)
    specificity <- TN / (TN + FP)
    precision <- TP / (TP + FP)
    recall <- TP / (TP + FN)
    F1 <- 2 * precision * recall / (precision + recall)
    loglikelihood <- sum(ifelse(data$reference == "bad", log(data$pred.score), log(1 - data$pred.score)))
    pnull <- sum(data$reference == "bad") / nrow(data)
    null_likelihood <- sum(ifelse(data$reference == "bad", 1 , 0 )) * log(pnull) + sum(ifelse(data$reference == "bad" , 0 , 1 )) * log(1 - pnull)
    pseudo_r2 <- 1 - loglikelihood / null_likelihood
    result <- rbind(result, data.frame(
      method = tools::file_path_sans_ext(basename(docs[i])), 
      sensitivity = round(sensitivity, digits = 2), 
      specificity = round(specificity, digits = 2), 
      F1 = round(F1, digits = 2), 
      logLikelihood = round(loglikelihood, digits = 2), 
      pseudoRsquared = round(pseudo_r2, digits = 2)))
  }
  final_row <- c("best",
                 result[which.max(result$sensitivity),1],
                 result[which.max(result$specificity),1],
                 result[which.max(result$F1),1],
                 result[which.max(result$logLikelihood),1],
                 result[which.max(result$pseudoRsquared),1])
  result <- rbind(result, final_row)
  result[is.na(result)] <- 0
  write.table(result, file = output,quote=F,sep=",", row.names = F)
}

# You could unmark the following cmd for local testing. Please mark it as a comment when uploading to GradeScope.
#calculate("bad", 0.5, "examples/method1.csv examples/method2.csv", "examples/output1_test.csv")
#calculate("bad", 0.4, "examples/method1.csv examples/method3.csv examples/method5.csv", "examples/output2_test.csv")
#calculate("good", 0.6, "examples/method2.csv examples/method4.csv examples/method6.csv", "examples/output3_test.csv")
