# description -------------------------------------------------------------

# A Shiny app ...
# Author: Moritz Gold and Lars Schöbitz
# Date: 2020-07-16
# License: MIT License

# libraries ---------------------------------------------------------------

library(shiny)
library(shinydashboard)
library(openxlsx)
library(tidyverse)
library(ggpubr)
library(FactoMineR)
library(factoextra)
library(DT)


# load data ---------------------------------------------------------------

## data for tool 1/2

biowaste_nutrients <- read.xlsx(xlsxFile = here::here("data/waste_sum.xlsx"), sheet = 1) 
performance <- read.xlsx(xlsxFile = here::here("data/performance_sum.xlsx"), sheet = 1)

biowaste_nutrients_narrow <- read.xlsx(xlsxFile =here::here("data/waste_sum.xlsx"),sheet = 1) %>% 
  gather(7:14,key = Nutrient_parameter,value = value) 

## data for tool 3 = data for tool 2

## data for tool 4

performance_narrow <- read.xlsx(xlsxFile = here::here("data/performance_sum.xlsx"), sheet = 1) %>% 
  gather(11:16,key = Performance_indicator,value = value,na.rm = TRUE)


# ui ----------------------------------------------------------------------

ui <- dashboardPage(
  
  dashboardHeader(title = "BSFL-Explorer"),
  
  dashboardSidebar(
    sidebarMenu(
      menuItem("Introduction", tabName = "intro", icon = icon("info-circle")),
      menuItem("Nutrient composition", tabName = "tool2",icon=icon("chart-pie")),
      menuItem("Substrate mixture formulation", tabName = "tool3",icon=icon("mortar-pestle")),
      menuItem("Conversion performance", tabName = "tool4", icon=icon("chart-bar"))
    )
  ),
  
  dashboardBody(
    
    tabItems(
      
      # input introduction
      
      tabItem(tabName = "intro",
              fluidRow(
                box(width = 12, 
                    h2("Introduction to App: 'BSFL-Explorer'"),
                    h3("Performance of black soldier fly larvae with differnt biowastes"),
                    
                    hr(),
                    
                    p("Welcome to BSFL-explorer! A main challenge for planners and operators of black soldier fly larvae 
                    biowaste conversion is knowledge on the performance of different biowastes. This App provides and visualizes 
                    data regarding the conversion of biowastes with black soldier fly larvae."),
                    
                    h2("Features"),
                    
                    h3("Nutrient composition"), 
                    
                    h4("Goal"),   
                    p(),   
                    
                    h4("Background"),
                       
                    p("The substrate nutrient composition has a great influence on conversion performance. 
                      In general, substrates high in digestible nutrients (i.e. protein, digestible carbohydrates, lipid) and low 
                      in fibres and ash can be expected to have a highe conversion performance."), 
                    
                    p(),
                    
                    h3("Biowaste mixture formulation"),
                    
                    h4("Goal"),
                    
                    h4("Background"),
                    
                    h3("Conversion performance"),
                    
                    h4("Goal"),
                    
                    h4("Background"),
                    
                    h3("Additional resources"),
                    
                    p("step-by-step guide"),
                    
                    p("Gold M.,…, Mathys, A. (2020a). Biowaste treatment with black soldier fly larvae: Increasing performance 
                    through the formulation of biowastes based on protein and carbohydrates. Waste Management, 102, 319-329.",a(href="https://www.sciencedirect.com/science/article/pii/S0956053X19306658","Available here")), 
                    
                    p("Gold review"),
                    
                    p("Fonseca: Mixture"),
                    
                    p("feedipedia"),
                    
                    p("Food explorer database"),
                    
                    p("Nyakeri"),
                    
                    p("Lalander"),
                    
                    p("Fonseca: Flies are what they eat"),
                    
                    h2("Acknowledgements")
                
                    # textOutput(outputId = "introtext")
                )
              )),
      
      # input tool 2
      tabItem(tabName = "tool2",
              
              # first row
              fluidRow(
                box(width = 6, title = "Select substrate and nutrient parameter of your interest",
                    column(width = 6, checkboxGroupInput(inputId = "Substrate_groups", label = "Substrate groups",
                                                         choices = levels(as.factor(biowaste_nutrients_narrow$Diet_group)),selected = "Food waste")),  
                           
                          
                    
                    column(width = 6, checkboxGroupInput(inputId = "Nutrient_parameter",label = "Nutrient parameter",
                                                         choices = levels(as.factor(biowaste_nutrients_narrow$Nutrient_parameter)),selected = "Ash")),
                ),
                
                box(width = 6, title = "General nutrient composition of different biowaste groups", 
                    plotOutput("PCA_substrate_groups"),
                    checkboxInput(inputId = "Diet_label", label = "Add diet labels",value = FALSE)
                
                
                )
              ),
              
              # second row
              
              fluidRow(
                box(width = 12, title = "Nutrient composition (boxplot)",
                    plotOutput("Boxplot_substrate_groups")
              )
              ),
              
              # second row
              fluidRow(
                box(width = 12, title = "Nutrient composition (tabular form)",
                    dataTableOutput("Nutrient_composition_summary")
                )
              )
      ), # close tab item tool2
      
      # input tool 3
      tabItem(tabName = "tool3",
              fluidRow(
                box(width = 6, title = "Write a title",
                    
                    # TODO: Add tool 3 elements  
                    
                ),
                box(width = 6, title = "Write a title",
                    
                )
              )
      ), # close tab item tool3
      
      # input tool 4
      tabItem(tabName = "tool4",
              
              # first row
              fluidRow(
                box(width = 6, title = "Select substrate and conversion performance indicator of your interest",
                    
                    column(width = 6, checkboxGroupInput(inputId = "Substrate_groups_tool4", label = "Substrate groups", 
                                                         choices =  levels(as.factor(performance_narrow$Diet_group)), 
                                                         selected = "Food waste - Household")),
                    
                    column(width = 6, checkboxGroupInput(inputId = "Performance_indicator_tool4", label = "Performance indicator", 
                                                         choices = levels(as.factor(performance_narrow$Performance_indicator)), 
                                                         selected = "Bioconversion_rate_perc_DM"))
                    
                ),
                box(width = 6, title = "Performance indicator (boxplot)",
                    plotOutput("Boxplot_substrate_groups_tool4"),
                    
                ),
                
                # second row
                
                # second row
                fluidRow(
                  box(width = 12, title = "Performance indicator (tabular form)",
                      dataTableOutput("Performance_indicator_summary_tool4")
                  )
                )
                
              )
      ) # close tab item tool4
    ) # close tab items
  ) # close dashboard body
) # close dashbord page


# server ------------------------------------------------------------------

server <- function(input, output,session) { 
  
  
  # Introduction page -------------------------------------------------------
  
  # output$introtext <- renderText(
  #   "I suggest you write an introduction text to you app here. Cite relevant papers and add info that\n
  # helps people understand how the app works and what the tools are. As you can see, I have no clue how to do that nicely,\n
  # but search engines and StackOverflow will help you.")
  

  # Tool 2 ------------------------------------------------------------------

  substr_groups <- reactive({ paste(input$Substrate_groups, collapse = ", ") })
  
  # A test to check if the selected checkboxes work correctly
  
  # output$txt <- renderText({
  #   paste("You chose", substr_groups())
  # })
  
  # select Substrate groups based on input
  
  biowaste_nutrients_subset <- reactive({
    biowaste_nutrients %>% 
      select(-Glucose,-Starch,-Ash_insoluable) %>% 
      filter(Diet_group %in% input$Substrate_groups)  ## here was an issue: access the input Id with "input$"
  })
  
  biowaste_nutrients_clean <- reactive({
    biowaste_nutrients_subset() %>% 
      select(7:11)
  })
  
  # run PCA
  
  pca_biowaste_nutrients <- reactive({
    PCA(biowaste_nutrients_clean(), scale.unit = TRUE)
  })
  
  
  # A test to see if the table renders as wanted
  
  # output$table <- renderTable({
  #   biowaste_nutrients_clean()
  # })
  
  
  # produce output based on manipulated data
  
  output$PCA_substrate_groups <- renderPlot({
    
    # Check for required value in Substrate_groups and Nutrient_parameter before calculating plot
    
    req(input$Substrate_groups != 0)
    req(input$Nutrient_parameter != 0)
    
    fviz_pca_biplot(pca_biowaste_nutrients(),
                    geom.ind = "point",
                    fill.ind = biowaste_nutrients_subset()$Diet_group,
                    pointshape = 21, pointsize = 4,
                    palette = "jco",
                    ggtheme = theme_minimal(),
                    arrowsize = 1,
                    labelsize = 4,
                    mean.point = FALSE,
                    legend.title = "Substrates",
                    alpha.var= 0.5,
                    repel = TRUE)
  })
  
    
  biowaste_nutrients_narrow_subset <-
    
    reactive({
      
      # select Substrate groups based on input
      
      biowaste_nutrients_narrow %>% 
        
        filter(Diet_group %in% input$Substrate_groups & Nutrient_parameter %in% input$Nutrient_parameter)
      
    })
  
  
  # calculate descriptive statistics
  
  biowaste_nutrients_stats <- reactive({
    biowaste_nutrients_narrow_subset() %>% 
      group_by(Diet_group,Nutrient_parameter) %>% 
      summarise(n = n(),
                mean = round(mean(value,na.rm = TRUE), 1),
                sd = round(mean(value,na.rm = TRUE), 1),
                median = round(median(value,na.rm = TRUE), 1),
                max = round(max(value,na.rm = TRUE), 1),
                min = round(min(value,na.rm = TRUE), 1))
  })
  
  
  # produce boxplot output based on manipulated data
  
  output$Boxplot_substrate_groups <- renderPlot({
    
    # Check for required value in Substrate_groups and Nutrient_parameter before calculating plot
    
    req(input$Substrate_groups != 0)
    req(input$Nutrient_parameter != 0)
    
    biowaste_nutrients_narrow_subset()  %>% 
      ggplot(aes(Diet_group,value)) +
      geom_boxplot() +
      #geom_point() +
      ## Alternative which shows the overlying points a little nicer
      geom_jitter(width = 0.1) + 
      labs(y = "% dm", x="", title = "Biowaste nutrients") +
      facet_wrap(~Nutrient_parameter) +
      coord_flip()
  })
  
  
  # produce summmary table 
  
  output$Nutrient_composition_summary <- renderDT({biowaste_nutrients_stats()})  
  
  
  # Tool 3 ------------------------------------------------------------------
  
  # TODO: Add server parts of tool 3
  
  # Tool 4 ------------------------------------------------------------------
  
  observe({
    
    Performance_indicator_availability <- performance_narrow %>% filter(Diet_group  %in% input$Substrate_groups_tool4)
    
    updateCheckboxGroupInput(session, "Performance_indicator_tool4",
                             label = "Performance indicator",
                             choices = levels(as.factor(Performance_indicator_availability$Performance_indicator))
    )
  })
  
  
  performance_summary_narrow_subset <-
    
    reactive({
      # select Substrate groups based on input
      performance_narrow %>% 
        filter(
          Diet_group %in% input$Substrate_groups_tool4 & 
            Performance_indicator %in% input$Performance_indicator_tool4
          )
      
    })
  
  
  # calculate descriptive statistics
  
  performance_narrow_stats <- reactive({
    
    performance_summary_narrow_subset() %>% 
      group_by(Diet_group, Performance_indicator) %>% 
      summarise(n = n(),
                mean = round(mean(value, na.rm = TRUE), 1),
                sd = round(mean(value, na.rm = TRUE), 1),
                median = round(median(value, na.rm = TRUE), 1),
                max = round(max(value,na.rm = TRUE), 1),
                min = round(min(value,na.rm = TRUE), 1))
  })
  
  
  # produce boxplot output based on manipulated data
  
  output$Boxplot_substrate_groups_tool4 <- renderPlot({
    
    req(input$Performance_indicator_tool4 != 0)
    
    performance_summary_narrow_subset()  %>% 
      ggplot(aes(Diet_group, value)) +
      geom_boxplot() +
      geom_point() +
      labs(y = "% dm", x="", title = "Biowaste nutrients") +
      facet_wrap(~Performance_indicator) +
      coord_flip()
  })
  
  
  # produce summmary table 
  
  output$Performance_indicator_summary_tool4 <- renderDT({ performance_narrow_stats() })
  
}


# app ---------------------------------------------------------------------


shinyApp(ui, server)

