# Visualizing IRT through R Shiny
To run the codes on your local computer and upload to a Shinyapps.io website, first create your account here: https://www.shinyapps.io/.

Create a folder (e.g., 'Visualizing IRT_2025) that contains the R files (global.R, server.R, and ui.R).

Then, create a new R script and type the following: <br>
`install.packages("rsconnect") <br>
library(rsconnect) <br>
rsconnect::setAccountInfo(name = 'yourname', <br>
                            token = 'acquire through your Shinyapps', <br>
                            secret = 'acquire through your Shinyapps') <br>
rsconnect::deployApp('your folder path, for example: /Users/habui/Downloads/Visualizing IRT_2025')` <br>

  You will have a Shinyapps website similar to this: https://habui.shinyapps.io/visualizing_irt_2025/

  # Other samples of IRT visualizations:
  1. https://aidenloe.github.io/irtplots.html
  2. https://github.com/xluo11/Rirt
  3. https://r.tquant.eu/tquant/KULeuven/IRT/app/
  
