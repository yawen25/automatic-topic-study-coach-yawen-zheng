library(shiny)
library(shinyjs)

# Define UI for app that draws a histogram ----
ui <- fluidPage(
    useShinyjs(),
    titlePanel("Automatic Study Topic Coach"),
    sidebarLayout(
        sidebarPanel(
            #-------------------------------
            # test on starting page
            radioButtons(
                "RBstart",
                "Welcome to the test",
                selected = T,
                choiceNames = c(
                    "data analyst",
                    "Data Science",
                    "Information Security",
                    "Project Manager",
                    "Text Analytics"
                ),
                choiceValues = 1:5
            ),
            actionButton("start", "start test"),
            
            # ------------------------------
            
            shinyjs::hidden(actionButton("backButton","Prev")),
            shinyjs::hidden(actionButton("goButton", "Next")),
            shinyjs::hidden(actionButton('submitButton', 'Submit')),
            shinyjs::hidden(actionButton('hintButton','Hints')),
            shinyjs::hidden(actionButton("toMain","back")),
            actionButton("scoreButton", "studentScore")
        ),
        mainPanel(
            shinyjs::hidden(textOutput("question")),
            shinyjs::hidden(uiOutput("answers")),
            # shinyjs::hidden(tableOutput("hint")),
            shinyjs::hidden(tableOutput("grade")),
            shinyjs::hidden(textOutput("test")),
            shinyjs::hidden(textOutput("test2")),
            shinyjs::hidden(tableOutput("scoretable")),
            shinyjs::hidden(downloadButton("download", "download the table")),
            shinyjs::hidden(textInput("nameInput", "name")),
            shinyjs::hidden(textInput("passwordInput", "password")),
            shinyjs::hidden(actionButton("loginButton", "login")),
            # create two plots
            shinyjs::hidden(plotOutput("histogram")),
            shinyjs::hidden(plotOutput("bp"))
        )
    )
)