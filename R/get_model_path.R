#' Get file path for model files
#'
#' For internal use
#'
#' @template param_model.name
#' @param file.name Optional. File name; if NULL, return path to model directory
#' @param dir.name Directory name for files (for local files, must be in main project directory)
#' @template param_local
#'
#' @return A file name complete with file path
get_model_path = function(
    model.name,
    file.name,
    dir.name = "models",
    local = FALSE
){
  if(local & !file.exists(here::here(dir.name))) stop(paste0("No local `", dir.name,"` folder found in main project directory."))

  if(is.null(model.name)) model.name = ""
  if(is.null(file.name)) file.name = ""

  # Construct path
  path = fs::path(
    dir.name,
    model.name,
    file.name
  )

  # Get out name and check corresponding dir/file exists
  if(local){
    out.name = here::here(path)
    if(!fs::file_exists(path)) return(NULL)
  } else {
    out.name = try(fs::path_package(path, package = "EPACmodel"), silent = TRUE)
    # return NULL if package file not found
    if("try-error" %in% class(out.name)) return(NULL)
  }

  return(out.name)
}
