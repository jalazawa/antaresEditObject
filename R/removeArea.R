#' Remove An Area From inputs
#'
#' @param name An area name
#' @param opts
#'   List of simulation parameters returned by the function
#'   \code{antaresRead::setSimulationPath}
#'
#' @return An updated list containing various information about the simulation.
#' @export
#' 
#' @importFrom antaresRead simOptions setSimulationPath readBindingConstraints
#'
#' @examples
#' \dontrun{
#' removeArea("fictive_area")
#' }
removeArea <- function(name, opts = antaresRead::simOptions()) {

  # name of the area can contain upper case in areas/list.txt (and use in graphics)
  # (and use in graphics) but not in the folder name (and use in all other case)
  list_name <- name
  name <- tolower(name)
  
  if (!name %in% opts$areaList)
    stop(paste(name, "is not a valid area"))

  # Input path
  inputPath <- opts$inputPath

  # Update area list
  areas <- readLines(file.path(inputPath, "areas/list.txt"))
  areas <- setdiff(areas, list_name)
  areas <- areas[!duplicated(areas)]
  areas <- paste(sort(areas), collapse = "\n")
  writeLines(text = areas, con = file.path(inputPath, "areas/list.txt"))


  # Area folder
  unlink(x =  file.path(inputPath, "areas", name), recursive = TRUE)


  # Hydro
  # ini
  if (file.exists(file.path(inputPath, "hydro", "hydro.ini"))) {
    hydro <- readIniFile(file = file.path(inputPath, "hydro", "hydro.ini"))
    if (!is.null(hydro$`inter-daily-breakdown`))
      hydro$`inter-daily-breakdown`[[name]] <- NULL
    if (!is.null(hydro$`intra-daily-modulation`))
      hydro$`intra-daily-modulation`[[name]] <- NULL
    if (!is.null(hydro$`inter-monthly-breakdown`))
      hydro$`inter-monthly-breakdown`[[name]] <- NULL
    writeIni(
      listData = hydro,
      pathIni = file.path(inputPath, "hydro", "hydro.ini"),
      overwrite = TRUE
    )
  }
  # allocation
  unlink(x = file.path(inputPath, "hydro", "allocation", paste0(name, ".ini")), recursive = TRUE)
  # capacity
  unlink(x = file.path(inputPath, "hydro", "common", "capacity", paste0("maxpower_", name, ".txt")), recursive = TRUE)
  # reservoir
  unlink(x = file.path(inputPath, "hydro", "common", "capacity", paste0("reservoir_", name, ".txt")), recursive = TRUE)
  # prepro
  unlink(x = file.path(inputPath, "hydro", "prepro", name), recursive = TRUE)
  # series
  unlink(x = file.path(inputPath, "hydro", "series", name), recursive = TRUE)


  # Links
  links_area <- as.character(getLinks(areas = name))
  if (length(links_area) > 0) {
    links_area <- strsplit(x = links_area, split = " - ")
    for (i in seq_along(links_area)) {
      area1 <- links_area[[i]][1]
      area2 <- links_area[[i]][2]
      opts <- removeLink(from = area1, to = area2, opts = opts)
    }
  }
  unlink(x = file.path(inputPath, "links", name), recursive = TRUE)
  alllinks <- list.files(path = file.path(inputPath, "links"), pattern = name, full.names = TRUE, recursive = TRUE)
  lapply(alllinks, unlink, recursive = TRUE)


  # Load
  unlink(x = file.path(inputPath, "load", "prepro", name), recursive = TRUE)
  unlink(x = file.path(inputPath, "load", "series", paste0("load_", name, ".txt")), recursive = TRUE)


  # Misc-gen
  unlink(x = file.path(inputPath, "misc-gen", paste0("miscgen-", name, ".txt")), recursive = TRUE)


  # Reserves
  unlink(x = file.path(inputPath, "reserves", paste0(name, ".txt")), recursive = TRUE)


  # Solar
  unlink(x = file.path(inputPath, "solar", "prepro", name), recursive = TRUE)
  unlink(x = file.path(inputPath, "solar", "series", paste0("solar_", name, ".txt")), recursive = TRUE)


  # Thermal
  unlink(x = file.path(inputPath, "thermal", "clusters", name), recursive = TRUE)
  unlink(x = file.path(inputPath, "thermal", "prepro", name), recursive = TRUE)
  unlink(x = file.path(inputPath, "thermal", "series", name), recursive = TRUE)


  # Wind
  unlink(x = file.path(inputPath, "wind", "prepro", name), recursive = TRUE)
  unlink(x = file.path(inputPath, "wind", "series", paste0("wind_", name, ".txt")), recursive = TRUE)

  
  
  # Remove binding constraints
  bc <- readBindingConstraints(opts = opts)
  bc_area <- lapply(
    X = bc,
    FUN = function(x) {
      all(grepl(pattern = name, x = names(x$coefs)))
    }
  )
  bc_area <- unlist(bc_area)
  bc_remove <- names(bc_area[bc_area])
  if (length(bc_remove) > 0) {
    for (bci in bc_remove) {
      opts <- removeBindingConstraint(name = bci, opts = opts)
    }
  }
  
  
  bindingconstraints <- readLines(
    con = file.path(inputPath, "bindingconstraints", "bindingconstraints.ini")
  )
  # bindingconstraints <- grep(pattern = name, x = bindingconstraints, value = TRUE, invert = TRUE)
  ind1 <- !grepl(pattern = paste0("^", name, "%"), x = bindingconstraints)
  ind2 <- !grepl(pattern = paste0("%", name, "\\s"), x = bindingconstraints)
  
  writeLines(
    text = paste(bindingconstraints[ind1 | ind2], collapse = "\n"), 
    con = file.path(inputPath, "bindingconstraints", "bindingconstraints.ini")
  )


  # Maj simulation
  suppressWarnings({
    res <- antaresRead::setSimulationPath(path = opts$studyPath, simulation = "input")
  })

  invisible(res)
}






#' @title Seek for a removed area
#'
#' @description Check if it remains trace of a deleted area in the input folder
#'
#' @param area An area
#' @param all_files Check files in study directory.
#' @param opts
#'   List of simulation parameters returned by the function
#'   \code{antaresRead::setSimulationPath}
#'
#' @return a named list with two elements
#' @export
#'
#' @examples
#' \dontrun{
#' checkRemovedArea("myarea")
#' }
checkRemovedArea <- function(area, all_files = TRUE, opts = antaresRead::simOptions()) {
  
  # Input path
  inputPath <- opts$inputPath
  
  
  # Search for files or directories named after the area searched
  inputFiles <- list.files(
    path = inputPath,
    pattern = if (all_files) "" else area,
    recursive = TRUE, include.dirs = TRUE, full.names = TRUE
  )
  
  areaResiduFiles <- grep(
    pattern = sprintf("[[:punct:]]+%s[[:punct:]]+|%s$", area, area), 
    x = inputFiles, 
    value = TRUE
  )
  
  
  # Check files content
  areaResidus <- vector(mode = "character")
  for (i in inputFiles) {
    if (!file.info(i)$isdir) {
      suppressWarnings({tmp <- readLines(con = i)})
      tmp <- paste(tmp, collapse = "\n")
      if (grepl(pattern = area, x = tmp)) {
        areaResidus <- append(areaResidus, i)
      }
    }
  }
  
  list(
    areaResiduFiles = areaResiduFiles,
    areaResidus = areaResidus
  )
  
}






