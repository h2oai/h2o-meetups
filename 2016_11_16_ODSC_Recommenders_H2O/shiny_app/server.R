
# Define server logic for random distribution application
function(input, output) {
  
  # Return user's history
  userHistory <- reactive({
    user_data <- data[data$userId == input$user, ]
    user_data <- user_data[order(user_data$rating, decreasing = TRUE), ]
    return(user_data)
  })
  
 # Return user's top 10 recommendations
  userRecommendations <- reactive({
    user_recs <- predictions[predictions$userId == input$user, ]
    user_recs$final_predict <- input$cb_weight*user_recs$CB_predict + (1 - input$cb_weight) * user_recs$CF_predict
    user_recs <- user_recs[order(user_recs$final_predict, decreasing = TRUE), ]
    return(user_recs)
  })
  
  # Return's user's RMSE
  userRMSE <- reactive({
    user_test <- test[test$userId == input$user, ]
    user_test$final_predict <- input$cb_weight*user_test$CB_predict + (1 - input$cb_weight) * user_test$CF_predict
    rmse <- laply(c("CB_predict", "final_predict", "CF_predict"), function(type){
      sqrt(mean((user_test[[type]] - user_test$rating)^2))
    })
    return(rmse)
  })
  
  
  # Generate an HTML table view of the history
  output$likedMovies <- renderDataTable({
    history <- userHistory()
    history <- history[c(1:5), c("title", "genres", "rating"), with = FALSE]
    return(history)
  })
  
  output$dislikedMovies <- renderDataTable({
    history <- userHistory()
    history <- tail(history[, c("title", "genres", "rating"), with = FALSE], n = 5)
    return(history)
  })
  
  # Generate an HTML table view of the recommendations
  output$recommendations <- renderDataTable({
    user_recs <- userRecommendations()
    user_recs <- user_recs[c(1:min(nrow(user_recs), 10)), c("title", "final_predict"), with = FALSE]
    colnames(user_recs) <- c("Movie", "PredictedRating")
    
    user_recs$PredictedRating <- round(user_recs$PredictedRating, digits = 2)
    return(user_recs)
  })
  
  output$RMSE <- renderPlotly({
    
    rmse <- userRMSE()
    
    plot_ly(x = c("Content Based", "Hybrid", "Collaborative Filtering"), 
            y = rmse, type = "bar", marker = list(color="firebrick")) %>% 
      layout(yaxis = list(title = "Root Mean Squared Error"), 
             xaxis = list(title = "", tickangle = 45), margin = list(b = 140, r = 100))
    
  })
  
  
  output$latentFactors <- renderPlotly({
    
    history <- userHistory()
    liked_movies <- as.character(history[history$rating >=4, ]$movieId)
    not_liked_movies <- as.character(history[history$rating < 4, ]$movieId)
    recs <- userRecommendations()
    recs <- as.character(recs[c(1:10), ]$movieId)
    
    # Add Colors
    tsne_factors[tsne_factors$movieId %in% liked_movies, "color"] <- "liked"
    tsne_factors[tsne_factors$movieId %in% not_liked_movies, "color"] <- "disliked"
    tsne_factors[tsne_factors$movieId %in% recs, "color"] <- "recommended"
    #tsne_factors$color <- factor(tsne_factors$color, c("liked", "disliked", "recommended", "other"))
    tsne_factors <- tsne_factors[order(tsne_factors$color), ]
    
    plot_ly(data = tsne_factors, x = V1, y = V2, mode = "markers", 
            text = paste0("Movie: ", title), color = color, colors = c("firebrick", "forestgreen", "lightgrey", "orange")) %>%
      layout(yaxis = list(title = ""), xaxis = list(title = ""))
  })
  
  
 
  
}