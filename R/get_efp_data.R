if(getRversion() >= "2.15.1")  utils::globalVariables(c("."))

#' Get eFP browser data
#' @importFrom xml2 read_html
#' @importFrom magrittr %>%
#' @importFrom rvest html_nodes
#' @importFrom rvest html_attr
#' @param dataSource data source
#' @param modeInput mode. "Absolute", "Relative", "Compare"
#' @param primaryGene AGI code
#' @param secondaryGene AGI code
#' @param modeMask_low modeMask_low
#' @param modeMask_stddev modeMask_stddev
#' @param dry dry run
#' @export
get_efp_data <-
  function(
    dataSource,
    modeInput, #c("Absolute", "Relative", "Compare")
    primaryGene,
    secondaryGene = "None",
    modeMask_low = "None",
    modeMask_stddev = "None",
    dry = F
  ){
    query <-
      paste0(
        "http://bbc.botany.utoronto.ca/efp/cgi-bin/efpWeb.cgi?",
        "dataSource=", dataSource,
        "&modeInput=", modeInput,
        "&primaryGene=", primaryGene,
        "&secondaryGene=", secondaryGene,
        "&modeMask_low=", modeMask_low,
        "&modeMask_stddev=", modeMask_stddev
      )

    if(dry){
      return(query)
    }else{
      efp_html <- read_html(query)
      value_text <- efp_html %>% html_nodes("area") %>% html_attr("title")
      return(value_text)
    }
  }


#' Convert eFP data to data.frame
#' @importFrom magrittr %>%
#' @importFrom stringr str_detect
#' @importFrom dplyr data_frame
#' @importFrom stringr str_extract
#' @importFrom stringr str_sub
#' @importFrom dplyr mutate
#' @importFrom dplyr distinct
#' @param efpdata data source
#' @param modeInput mode. "Absolute", "Relative", "Compare"
#' @export
convert_rowdata2df <-
  function(efpdata, modeInput){
    temp <-
      switch(
        modeInput,
        "Absolute" = c("SD:", "Level.*,", "SD.*$", "level", "sd"),
        "Relative" = c("Value:", "Value.*,", "Fold.*$", "value", "fc")
      )

    df <-
      efpdata %>%
      {.[str_detect(., temp[1])]} %>%
      {data_frame(
        sample = str_extract(., "^.*\\n") %>% str_sub(end = -3),
        v1 = str_extract(., temp[2]) %>% str_extract("[\\d.]+"),
        v2 = str_extract(., temp[3]) %>% str_extract("[\\d.]+")
      )} %>%
      mutate(
        v1 = as.numeric(.$v1),
        v2 = as.numeric(.$v2)
      ) %>%
      distinct
    colnames(df)[2:3] <- temp[4:5]
    df
  }


#' Get Absolute eFP browser data
#' @param primaryGene AGI code
#' @param dataSource dataSource
#' @export
get_efp_absolute <-
  function(primaryGene, dataSource = DATASOURCE[-12]){
    li <-
      lapply(
        dataSource,
        function(x){
          temp <-
            get_efp_data(
              dataSource = x,
              modeInput = "Absolute",
              primaryGene = primaryGene)
          temp <-
            convert_rowdata2df(temp, "Absolute")
          Sys.sleep(1)
          return(temp)
        }
      )
    names(li) <- dataSource
    li
  }

#' Get Relative eFP browser data
#' @param primaryGene AGI code
#' @param dataSource dataSource
#' @export
get_efp_relative <-
  function(primaryGene, dataSource = DATASOURCE[-12]){
    li <-
      lapply(
        dataSource,
        function(x){
          temp <-
            get_efp_data(
              dataSource = x,
              modeInput = "Relative",
              primaryGene = primaryGene)
          temp <-
            convert_rowdata2df(temp, "Relative")
          Sys.sleep(1)
          return(temp)
        }
      )
    names(li) <- dataSource
    li
  }
