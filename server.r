library(shinyjs)
library(dplyr)


#drfortino
NAME = "drfortino"
PASSWORD = "drfortino"

# load CSV file
f_testAnswer = read.csv("test_answer.csv") # , fileEncoding = "UTF-8-BOM")
f_testQuestion = read.csv("test_question.csv") # , fileEncoding = "UTF-8-BOM")
f_test= read.csv("test.csv") # , fileEncoding = "UTF-8-BOM")
f_domain = read.csv("Domain.csv") # , fileEncoding = "UTF-8-BOM")
f_testHints = read.csv("test_hints.csv") # , fileEncoding = "UTF-8-BOM")

# colnames(f_domain)[1] <- "Test"
# colnames(f_test)[1] <- "Test"
# colnames(f_testAnswer)[1] <- "Test"
# colnames(f_testQuestion)[1] <- "Test"
# colnames(f_testHints)[1] <- "Test"



testQA <- merge(f_testQuestion,f_testAnswer ,all.X= T, all.Y = T) %>% 
    dplyr::arrange(Test, Question)



# define some reusable functions

#----------------func 0-----------------
# a query to select between test
get_test<- function(num){
    testQA[testQA$Test == num, ]
}
#---------------------------------------

# ---------------func 1-----------------
# get questions for selected test
get_questions <- function(test_df,num){
    paste(test_df$Question[num],".",test_df$Problem[num])
}
# --------------------------------------

get_hint <- function(test_id, question_id) {
    
    hints <- f_testHints %>% filter(Test == test_id & Question == question_id)
    
    if(nrow(hints) == 1) {
        div(fluidRow(column(width = 12, h5("Hints:"))),
            # fluidRow(
            #     column(width = 4, p(hints[[1,5]])),
            #     column(width = 4, p(hints[[1,6]])),
            #     column(width = 4, p(hints[[1,7]]))
            # ))
            tags$table(
                tags$tr(
                    tags$th("Session"),
                    tags$th("Page1"),
                    tags$th("Page2"),
                    tags$th("Page3")
                ),
                tags$tr(
                    tags$td(hints[[1,4]]),
                    tags$td(hints[[1,5]]),
                    tags$td(hints[[1,6]]),
                    tags$td(hints[[1,7]])
                ),
                class = "table table-striped table-bordered"
                
            )
        )
            
    } else {
        NULL
    }
}

# ---------------func 2-----------------
# get answers for selected test
get_answers<- function(test_df, num){
    rowVal = as.list(test_df[num,])
    out = c()
    for (i in 5:length(rowVal)) {
        if(rowVal[i] != ""){
            out <- c(out,as.character(rowVal[i]))
        }
    }
    out
}
# --------------------------------------


# ---------------func 3-----------------
# to random select answers and record the right one
shuffle_answers <- function(test_df){
    correct_answer = c()
    for (i in 1:nrow(test_df)) {
        r = test_df[i, -c(1:4)]
        answers = r[r != ""]
        num_valid_answer = length(answers)
        s = sample(num_valid_answer)
        correct_answer <- c(correct_answer, which(s == 1))
        
        test_df[i, c(5:(4 + num_valid_answer))] = answers[s]
    } 
    foo <- vector("list", length = 2)
    names(foo) <- c("test_df", "correctAnswer")
    foo$test_df = test_df
    foo$correctAnswer = correct_answer
    foo
}
# --------------------------------------

# ---------------func 4-----------------
# get correct answer
get_correct_answer <- function(correctAnswer, num){
    correctAnswer[testQA$Test == num]
}
# --------------------------------------

# ---------------func 5-----------------
# after record all the answers, generate the domain grade
domainGrade <- function(domainList, answerList){
    c = rep(0,max(domainList)) # [0 for _ in range(max(domainList))]
    d = rep(0,max(domainList))
    for(i in 1:length(domainList)){
        c[domainList[i]] = c[domainList[i]] + answerList[i]
        d[domainList[i]] = d[domainList[i]] + 1
    }
    c/d
}
# --------------------------------------

# changed
assamble_table <- function(domainG,t,grade){
    if(length(domainG)< 7) {domainG = c(domainG, rep(0,2))}
    result = data.frame(
        test = t,
        # percentage
        domain_1 = paste0(as.integer(domainG[1] * 100), "%"),
        domain_2 = paste0(as.integer(domainG[2] * 100), "%"),
        domain_3 = paste0(as.integer(domainG[3] * 100), "%"),
        domain_4 = paste0(as.integer(domainG[4] * 100), "%"),
        domain_5 = paste0(as.integer(domainG[5] * 100), "%"),
        domain_6 = paste0(as.integer(domainG[6] * 100), "%"),
        domain_7 = paste0(as.integer(domainG[7] * 100), "%"),
        total_score = paste0(as.integer(grade / 50 * 100), "%")
    )
    result
} 

#changed domain name
assamble_table_special <- function(domainG,t,grade){
    if(length(domainG)< 7) {domainG = c(domainG, rep(0,2))}
    result = data.frame(
        test = t,
        # percentage
        domain_1 = paste0(as.integer(domainG[1] * 100), "%"),
        domain_2 = paste0(as.integer(domainG[2] * 100), "%"),
        domain_3 = paste0(as.integer(domainG[3] * 100), "%"),
        domain_4 = paste0(as.integer(domainG[4] * 100), "%"),
        domain_5 = paste0(as.integer(domainG[5] * 100), "%"),
        domain_6 = paste0(as.integer(domainG[6] * 100), "%"),
        domain_7 = paste0(as.integer(domainG[7] * 100), "%"),
        total_score = paste0(as.integer(grade / 50 * 100), "%")
    )
    colnames(result)[1] = "Test"
    colnames(result)[2:8] = f_domain[f_domain$Test == t, c("name")]
    colnames(result)[9] = "Total_score"
    result
} 

#changed
assamble_bar <- function(domainG, grade) {
    if(length(domainG)< 7) {domainG = c(domainG, rep(0,2))}
    res = c()
    for (i in 1:7) {
        res = c(res, domainG[i] * 100)
    }
    res = c(res, grade / 50 * 100)
    res
}

# ---------------initiating-----------------
foo = shuffle_answers(testQA)
testQA = foo$test_df 
correctAnswer = foo$correctAnswer
# ------------------------------------------

server <- function(input, output, session) {
    
    # initiatives
    counters <- reactiveValues()
    counters$page <- 0
    counters$n <- 0 
    counters$selection <- vector(length = 0) 
    counters$hint <- vector(length = 0)
    counters$test <- testQA
    counters$correctAnswer <- c()
    counters$grade <- 0
    
    #-----------------------------------------------------------------------------
    # switch between test, javascript include
    observeEvent(input$start,{
        if(!is.null(input$RBstart)){
            counters$test <- get_test(input$RBstart)
            counters$correctAnswer <- get_correct_answer(correctAnswer,input$RBstart)
            counters$n <- nrow(counters$test)
            counters$selection <- vector(length = counters$n)
            counters$hint <- vector("logical", length = counters$n) # initial value is FALSE
            shinyjs::hide("RBstart")
            shinyjs::hide("start")
            shinyjs::hide("scoreButton")
            shinyjs::show("goButton")
            shinyjs::show("backButton")
            shinyjs::show("question")
            shinyjs::show("answers") 
            shinyjs::show("submitButton")
            shinyjs::show("toMain")
            shinyjs::show("hintButton")
        }
    })
    
    
    observeEvent(input$hintButton,{
        
        counters$hint[counters$page %% counters$n + 1] = !counters$hint[counters$page %% counters$n + 1]
        
    })
    
    
    observeEvent(input$submitButton,{
        shinyjs::hide("goButton")
        shinyjs::hide("backButton")
        shinyjs::hide("question")
        shinyjs::hide("submitButton")
        shinyjs::hide("answers")
        shinyjs::hide("hintButton")
        shinyjs::show("grade")
        shinyjs::show("histogram")
        shinyjs::show("bp")
        # changed, show "back" button
        shinyjs::show("toMain")
        
        # shinyjs::show("scoretable")
        # update to file
        domainG = domainGrade(
            counters$test$Domain,
            as.integer(counters$correctAnswer == counters$selection)
        )
        result = assamble_table(domainG, input$RBstart, counters$grade)
        if(!file.exists("test_result.csv")){
            write.csv(result,"test_result.csv",row.names = F)
        }else{
            f = read.csv("test_result.csv")
            f = rbind(f, result)
            write.csv(f,"test_result.csv",row.names = F)
        }
    })
    
    viewscore <- observeEvent(input$scoreButton,{
        shinyjs::hide("RBstart")
        shinyjs::hide("start")
        shinyjs::show("toMain")
        shinyjs::show("nameInput")
        shinyjs::show("passwordInput")
        shinyjs::show("loginButton")
    })
    
    backscore<- observeEvent(input$toMain,{
        shinyjs::show("RBstart")
        shinyjs::show("start")
        shinyjs::show("scoreButton")
        shinyjs::hide("toMain")
        shinyjs::hide("nameInput")
        shinyjs::hide("passwordInput")
        shinyjs::hide("loginButton")
        shinyjs::hide("scoretable")
        shinyjs::hide("download")
        shinyjs::hide("bp")
        shinyjs::hide("grade")
        shinyjs::hide("histogram")
        shinyjs::hide("question")
        shinyjs::hide("answers") 
        shinyjs::hide("submitButton")
        shinyjs::hide("goButton")
        shinyjs::hide("hintButton")
        shinyjs::hide("backButton")
        
    })
    #-----------------------------------------------------------------------
    
    page_forward <- observeEvent(input$goButton,{
        # ---------- test------------
        if(!is.null(input$answerButton)){
            counters$selection[counters$page+1] <- input$answerButton
        }
        # ---------------------------
        counters$grade <- sum(counters$correctAnswer == counters$selection)
        counters$page <- counters$page + 1
    })
    
    page_backward <- observeEvent(input$backButton,{
        counters$page <- counters$page - 1
    })
    
    output$question <- renderText({
        get_questions(counters$test, counters$page %% counters$n + 1)
    })
    
    output$answers <- renderUI({
        div(
            radioButtons("answerButton", "select from following",
                         choiceNames = get_answers(counters$test, counters$page%%counters$n + 1),
                         selected = counters$selection[counters$page %% counters$n + 1],
                         choiceValues = 1:length(get_answers(counters$test, counters$page%%counters$n + 1))
            ),
            
            if(counters$hint[counters$page %% counters$n + 1] == TRUE) {
                get_hint(input$RBstart, counters$page %% counters$n + 1)
            } else {
                NULL
            }
            
        )
    })
    
    
    output$grade <- renderTable({
        assamble_table_special(
            domainGrade(
                counters$test$Domain,
                as.integer(counters$correctAnswer == counters$selection)
            ), 
            input$RBstart, 
            counters$grade
        )
    })
    
    
    output$histogram <- renderPlot({
        #plot
        barplot(
            assamble_bar(
                domainGrade(
                    counters$test$Domain,
                    as.integer(counters$correctAnswer == counters$selection)
                ),
                counters$grade
            ), 
            width=0.1,
            names=c("1", "2", "3", "4", "5", "6", "7", "total score"),
            ylim=c(0,100),
            yaxp=c(0, 100, 10),
            space=1,
            xlab="Domain",
            ylab="Percentage",
            font.lab=2,
            cex.lab=1.25,
            font.axis=2,
            col="pink",
            las=1
        )
        # draw a 70 line
        abline(h=70, col="Red")
    })
    
    # box plot
    output$bp <- renderPlot({
        # read file
        f = read.csv("test_result.csv")
        colnames(f)[1] <- "Test"
        res <- c()
        # fetch file's test == input$RBstart
        t = f[f$Test==input$RBstart, ]
        # iterate domain id + total_score
        for (j in (1:8)){
            # iterate t's rows
            for (i in 1:nrow(t)){
                # collect data
                res = c(res, as.integer(sub("%","",t[i, j+1])))
            }
        }
        # cast c into matrix
        m <- matrix(res, nrow=8, byrow=TRUE)
        # collect domain into boxplot
        boxplot(m[1, ], m[2, ], m[3, ], m[4, ], m[5, ], m[6, ], m[7, ], m[8, ],
                ylim=c(0,100),
                names=c("1", "2", "3", "4", "5", "6", "7", "total score"),
                yaxp=c(0, 100, 10),
                font.axis=2,
                font.lab=2,
                xlab="Domain",
                ylab="Percentage")
        # draw a 70 line
        abline(h=70, col="Red")
    })
    
    output$scoretable <- renderTable({
        read.csv("test_result.csv")
    })
    
    output$download <- downloadHandler(
        filename = function(){
            paste("studentScore","csv",sep=".")
        },
        content = function(file){
            f = read.csv("test_result.csv")
            write.csv(f,file = file,row.names = F)
        }
    )
    
    
    
    # -------------this is for unit testing-----------------
    output$test <- renderPrint({
        counters$test$Domain
    })
    
    output$test2 <- renderPrint({
        as.integer(counters$correctAnswer == counters$selection)
    })
    # -------------------------------------------------
    
    # -------------this is for password-----------------
    observeEvent(input$loginButton,{
        if(input$nameInput == NAME && input$passwordInput == PASSWORD){
            shinyjs::hide("loginButton")
            shinyjs::show("scoretable")  
            shinyjs::show("download")
            shinyjs::hide("nameInput")
            shinyjs::hide("passwordInput")
            shinyjs::hide("scoreButton")
        }
    })
    # -------------------------------------------------
    
}
