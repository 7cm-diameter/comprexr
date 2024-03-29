#' @export
align_with <- function(data, eventsrow, element, seqrow, onset, offset) {
  refs <- data[data[eventsrow] == element, ][, seqrow]
  onsets <- refs + onset
  offsets <- refs  + offset
  in_ranges <- lapply(seq_len(length(refs)), function(i) {
      in_range <- data[onsets[i] <= data[seqrow] & data[seqrow] <= offsets[i], ]
      in_range[seqrow] <- in_range[seqrow] - refs[i]
      in_range$serial <- rep(i, nrow(in_range))
      in_range
    })
  do.call(rbind, in_ranges)
}

#' @importFrom stringr str_split
get_metedata_from_filename <- function(filename) {
  metadata_elements <- unlist(str_split(basename(filename), pattern = "_"))
  subject <- metadata_elements[1]
  condition <- metadata_elements[2]
  date <- parse_date_into_int(metadata_elements[3])
  return(c(subject = subject, condition = condition, date = date))
}

#' @importFrom stringr str_split
parse_date_into_int <- function(date, year = T, month = T, day = T,
                                hour = F, min = F) {
  date_elements <- unlist(str_split(date, pattern = "-"))
  elements_used <- c(year, month, day, hour, min)
  parsed_date <- as.character()
  for (i in seq_len(length(elements_used))) {
    if (elements_used[i]) {
      parsed_date <- paste0(parsed_date, date_elements[i])
    }
  }
  return(parsed_date)
}

#' @importFrom stringr str_split
#' @export
add_metadata_to_df <- function(data, filename) {
  metadata <- get_metedata_from_filename(filename)
  n <- nrow(data)
  metadf <- data.frame(subject = rep(metadata["subject"], n),
                       condition = rep(metadata["condition"], n),
                       date = rep(metadata["date"], n))
  return(cbind(metadf, data))
}

#' @export
zip <- function(lists, names) {
  nlist <- length(lists)
  v <- unlist(lists)
  mat <- matrix(v, ncol = nlist)
  lapply(seq_len(nrow(mat)), function(i) {
    l <- as.list(mat[i, ])
    names(l) <- names
    l
  })
}
