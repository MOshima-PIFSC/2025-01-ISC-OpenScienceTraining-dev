# example modified from an app generated using https://gallery.shinyapps.io/assistant/#
# with the following prompt:
# "Create an app that generates data from a von Bertalanffy growth curve with Lognormal error and plots it"

library(bslib)
library(ggplot2)

# Von Bertalanffy growth function with lognormal error
vb_growth_with_lognormal_error <- function(t, Linf, K, t0, cv) {
  # Generate perfect curve
  mu <- Linf * (1 - exp(-K * (t - t0)))
  
  # Add lognormal error
  # Convert CV to sigma parameter for lognormal distribution
  sigma <- sqrt(log(1 + cv^2))
  mu_log <- log(mu) - (sigma^2)/2
  exp(rnorm(length(t), mean = mu_log, sd = sigma))
}

ui <- page_sidebar(
  title = "Von Bertalanffy Growth Data Generator",
  sidebar = sidebar(
    numericInput("n_points", "Number of Data Points", value = 100, min = 10, max = 1000),
    numericInput("Linf", "Asymptotic Length (Linf)", value = 100, min = 0),
    numericInput("K", "Growth Coefficient (K)", value = 0.3, min = 0, max = 1, step = 0.1),
    numericInput("t0", "t0", value = -0.5, step = 0.1),
    numericInput("cv", "Coefficient of Variation", value = 0.1, min = 0, max = 1, step = 0.05),
    actionButton("generate", "Generate New Data", class = "btn-primary"),
    hr(),
    helpText("This app generates length-at-age data with multiplicative lognormal error.")
  ),
    card(
      card_header("Simulated Growth Data"),
      plotOutput("growth_plot")
    )
  
)

server <- function(input, output) {
  # Reactive value to store the generated data
  sim_data <- reactiveVal()
  
  # Generate new data when button is clicked
  observeEvent(input$generate, {
    # Generate random ages between 0 and 15
    age <- runif(input$n_points, 0, 15)
    
    # Calculate lengths with lognormal error
    length <- vb_growth_with_lognormal_error(
      age, 
      Linf = input$Linf,
      K = input$K,
      t0 = input$t0,
      cv = input$cv
    )
    
    # Store data
    sim_data(data.frame(Age = age, Length = length))
  })
  
  # Initialize data on startup
  observe({
    if (is.null(sim_data())) {
      age <- runif(input$n_points, 0, 15)
      length <- vb_growth_with_lognormal_error(
        age,
        Linf = input$Linf,
        K = input$K,
        t0 = input$t0,
        cv = input$cv
      )
      sim_data(data.frame(Age = age, Length = length))
    }
  })
  
  # Plot the data
  output$growth_plot <- renderPlot({
    req(sim_data())
    
    # Generate theoretical curve for comparison
    age_seq <- seq(0, 15, length.out = 100)
    length_seq <- input$Linf * (1 - exp(-input$K * (age_seq - input$t0)))
    curve_df <- data.frame(Age = age_seq, Length = length_seq)
    
    ggplot() +
      # Add theoretical curve
      geom_line(data = curve_df, aes(x = Age, y = Length),
                color = "blue", linewidth = 1.2, alpha = 0.5) +
      # Add scattered points
      geom_point(data = sim_data(), aes(x = Age, y = Length),
                color = "red", alpha = 0.6) +
      labs(
        x = "Age",
        y = "Length",
        title = "Von Bertalanffy Growth Data",
        subtitle = "Blue line = theoretical curve, Red points = simulated data"
      ) +
      theme_minimal() +
      theme(
        plot.title = element_text(hjust = 0.5),
        plot.subtitle = element_text(hjust = 0.5),
        text = element_text(size = 14)
      )
  })
}

shinyApp(ui, server)
