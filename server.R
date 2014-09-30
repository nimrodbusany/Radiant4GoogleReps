shinyServer(function(input, output, session) {

	# source shared functions
	# source('../base/radiant.R', local = TRUE)
	source('radiant.R', local = TRUE)

	# source data & analysis tools
	R.utils::sourceDirectory('tools/analysis', recursive = TRUE, modifiedOnly = FALSE)
	R.utils::sourceDirectory('tools/data', recursive = TRUE, modifiedOnly = FALSE)
	R.utils::sourceDirectory('tools/app', recursive = TRUE, modifiedOnly = FALSE)
	# R.utils::sourceDirectory('../base/tools/data', recursive = TRUE)
	# R.utils::sourceDirectory('../base/tools/app', recursive = TRUE)

})
