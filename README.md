# Visualizing IRT through RMarkdown output
You can run the RMarkdown file directly on your computer and find an output like this:

<img width="1954" height="995" alt="Screenshot 2025-09-01 at 7 57 22 PM" src="https://github.com/user-attachments/assets/2fa1a17a-1e43-47da-a90e-7eb9486198ba" />



# Visualizing IRT through R Shiny
To run the codes on your local computer and upload to a Shinyapps.io website, first create your account here: https://www.shinyapps.io/.

Create a folder (e.g., 'Visualizing IRT_2025) that contains the R files (global.R, server.R, and ui.R).

Then, create a new R script and type the following: 

```install.packages("rsconnect") 

library(rsconnect)

rsconnect::setAccountInfo(name = 'yourname',
                          token = 'acquire through your Shinyapps',
                          secret = 'acquire through your Shinyapps') 
                            
rsconnect::deployApp('your folder path, for example: /Users/habui/Downloads/Visualizing IRT_2025')
```

  You will have a Shinyapps website similar to this: https://habui.shinyapps.io/visualizing_irt_2025/.

  # Other samples of IRT visualizations:
  1. https://aidenloe.github.io/irtplots.html
  2. https://github.com/xluo11/Rirt
  3. https://r.tquant.eu/tquant/KULeuven/IRT/app/
  
