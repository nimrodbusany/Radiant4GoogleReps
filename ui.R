shinyUI(navbarPage("NS-Radiant4GoogleDataset", id = "nav_radiant", inverse = TRUE, collapsable = TRUE,

  tabPanel("Data", uiOutput('data_ui_and_tabs')),

  navbarMenu("Random",
    tabPanel("Sampling", uiOutput("ui_random"))
  ),

  navbarMenu("R",
    tabPanel("Report", uiOutput("report")),
    tabPanel("Code", uiOutput("rcode"))
  ),

  tabPanel("State", uiOutput("state")),

  # tabPanel("About", includeRmd("../base/tools/app/about.Rmd"))
  tabPanel("About", includeRmd("tools/app/about.Rmd"))
))
