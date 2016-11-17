library(shiny)

# Define UI for random distribution application 
fluidPage(
  
  # Application title
  titlePanel("Movie Recommender"),
  
  # Sidebar with controls to select the random distribution type
  # and number of observations to generate. Note the use of the
  # br() element to introduce extra vertical spacing
  sidebarLayout(
    sidebarPanel(
      selectInput("user", "User ID:", unique(data$userId)),
      br(),
      
      sliderInput("cb_weight", 
                  "Content Based Weight:", 
                  value = 0.5,
                  min = 0, 
                  max = 1),
      
      br(),
      plotlyOutput("RMSE")
    ),
    
    # Show a tabset that includes a plot, summary, and table view
    # of the generated distribution
    mainPanel(
      tabsetPanel(type = "tabs", 
                  tabPanel("Recommendations", dataTableOutput("recommendations")),
                  tabPanel("Latent Factors", plotlyOutput("latentFactors")),
                  tabPanel("History", 
                           h2("Liked Movies"),
                           dataTableOutput("likedMovies"),
                           h2("Disliked Movies"),
                           dataTableOutput("dislikedMovies"))
      )
    )
  )
)