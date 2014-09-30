###############################
# Sampling 
###############################

output$uiView_vars2 <- renderUI({
  vars <- varnames()
  selectInput("view_vars", "Select variables to show:", choices  = vars, 
    selected = state_init_multvar("view_vars",vars, vars), multiple = TRUE, selectize = FALSE)
})

output$dataviewer2 <- renderDataTable({

  if(is.null(input$view_vars)) return()
  
  dat <- getdata()
  if(!all(input$view_vars %in% colnames(dat))) return()
  if(input$view_select != "") {
    selcom <- input$view_select
    selcom <- gsub(" ", "", selcom)

    seldat <- try(do.call(subset, list(dat,parse(text = selcom))), silent = TRUE)

    if(!is(seldat, 'try-error')) {
      if(is.data.frame(seldat)) {
        dat <- seldat
        seldat <- NULL
      }
    }
  }
 
  as.data.frame(dat[, input$view_vars, drop = FALSE])
 

}, options = list(bSortClasses = TRUE, bCaseInsensitive = TRUE, 
  aLengthMenu = c(10, 20, 30, 50), iDisplayLength = 10))


output$tabs_data2 <- renderUI({

	tabsetPanel(id = "datatabs2",
		tabPanel("Data",dataTableOutput("dataviewer2"))
	)

})


output$ui_random <- renderUI({

  list(
   includeCSS("www/style.css"),
    tags$head(
      tags$script(src = "js/jquery-ui.custom.min.js"),
      tags$script(src = "js/busy.js"),
      tags$script(src = 'https://c328740.ssl.cf1.rackcdn.com/mathjax/latest/MathJax.js?config=TeX-AMS-MML_HTMLorMML',
        type = 'text/javascript')
    ),
	sidebarLayout(	
		sidebarPanel(
			wellPanel(
				numericInput("rnd_sample_size", "Sample size:", min = 1, 
					value = state_init("rnd_sample_size",1)),
				actionButton('SampleFromData', 'Sample from data')
			),
			 wellPanel(
			  radioButtons(inputId = "saveAs2", label = "Save data:", c(".rda" = "rda", ".csv" = "csv", "clipboard" = "clipboard"), 
				selected = "rda"),
			  checkboxInput("man_add_descr","Add/edit data description", FALSE),
			  conditionalPanel(condition = "input.man_add_descr == true",
				actionButton('updateDescr', 'Update description')
			  ),
			  conditionalPanel(condition = "input.saveAs2 == 'clipboard'",
				actionButton('saveClipData2', 'Copy data')
			  ),
			  conditionalPanel(condition = "input.saveAs2 != 'clipboard' && input.man_add_descr == false",
				downloadButton('downloadData2', 'Save')
			  )
			),
			wellPanel(
			  uiOutput("uiView_vars2"), 
			  returnTextInput("view_select", "Subset (e.g., price > 5000)", state_init("view_select"))
			),
			helpAndReport('Random','random',inclMD("tools/help/random.md"))		
		),
		mainPanel(id = "datatabs2", dataTableOutput("dataviewer2"))
	),
	mainPanel(id = "mainSideBar")
	)
})

updateFileCounter <- function(name) {
  
  name = paste0(name,"(1)")
  values$lastCounter <- "(1)"
  while (name %in% values[['datasetlist']]) {
    m <- regexpr("\\(\\d*\\)",name, perl=TRUE)
    match1 = regmatches(name, m)
    ma = sub("\\(","",match1)
    ma = sub("\\)","",ma)
    ma
    da = as.numeric(ma) + 1
    da
    match1 = regmatches(name, m) <- paste0("(",da,")")
	values$lastCounter <- paste0("(",da,")")
  }
  
  print(name)
  return(name)
}

observe({
  if(is.null(input$SampleFromData) || input$SampleFromData == 0) return()
  isolate({
		selDat <- random( input$datasets, input$rnd_sample_size )
		fName <- paste0('sample_',input$datasets)
		fName = updateFileCounter(fName)
		values[[fName]] <- as.data.frame(selDat)
		values[['datasetlist']] <- unique(c(fName,values[['datasetlist']]))
		values$datasetInRand <- input$datasets
		values$sampleMode = TRUE 
	})
})

random <- function(datasets, rnd_sample_size) {
	
	# example list of names obtained from http://listofrandomnames.com
	dat <- values[[input$datasets]]	
	selDat <- dat[sample(1:nrow(dat), rnd_sample_size),, drop = FALSE]
	return(selDat)

}

# saving data
observe({
  # 'saving' data to clipboard
  if(is.null(input$saveClipData2) || input$saveClipData2 == 0) return()
  isolate({
    os_type <- .Platform$OS.type
    if (os_type == 'windows') {
      write.table(getdata(), "clipboard", sep="\t", row.names=FALSE)
    } else { 
      write.table(getdata(), file = pipe("pbcopy"), row.names = FALSE, sep = '\t')
    }
    updateRadioButtons(session = session, inputId = "saveAs2", label = "Save data:", c(".rda" = "rda", ".csv" = "csv", "clipboard" = "clipboard"), selected = ".rda")
  })
})

output$downloadData2 <- downloadHandler(
  filename = function() { paste('sample_',input$datasets,'.',input$saveAs2, sep='') },
  content = function(file) {

    ext <- input$saveAs2
    robj <- paste('sample_',input$datasets)

    if(ext == 'rda') {
      if(input$man_data_descr != "") {

        # save data description
        dat <- getdata()
        attr(dat,"description") <- values[[paste0(robj,"_descr")]]
        assign(robj, dat)
        save(list = robj, file = file)
      } else {
        assign(robj, getdata())
        save(list = robj, file = file)
      }
    } else if(ext == 'csv') {
	print(paste("1-",robj))
	print(paste("2-",getdata()))
      assign(robj, getdata())
      write.csv(get(robj), file)
    }
  }
)


