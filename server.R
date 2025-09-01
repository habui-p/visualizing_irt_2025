server <- function(input, output, session) {
  
  # Define parameters
  get_a <- reactive({
    if(input$model == "1PL (Rasch)"){
      a_default
    } else {
      sapply(1:5, function(i) input[[paste0("a", i)]])
    }
  })
  
  get_c <- reactive({
    if(input$model=="3PL") rep(input$c_slider,5) else rep(0,5)
  })
  
  # Shifted b values
  get_b <- reactive({
    b_default + input$b_shift
  })
  
  # P(theta) for each item
  p_mat <- reactive({
    th <- seq(-4,4,length.out=401)
    a <- get_a()
    b <- get_b()
    c <- get_c()
    sapply(1:5, function(j){
      if(input$model == "1PL (Rasch)"){
        1/(1 + exp(-(th - b[j])))
      } else if(input$model == "2PL"){
        1/(1 + exp(-a[j]*(th - b[j])))
      } else { # 3PL
        c[j] + (1 - c[j]) / (1 + exp(-a[j]*(th - b[j])))
      }
    })
  })
  
  # Item Information
  info_mat <- reactive({
    th <- theta_grid()
    a <- get_a()
    b <- get_b()
    c <- get_c()
    
    # Compute P(theta) for all items
    P <- sapply(1:5, function(j){
      if(input$model == "1PL (Rasch)") {
        1 / (1 + exp(-(th - b[j])))
      } else if(input$model == "2PL") {
        1 / (1 + exp(-a[j]*(th - b[j])))
      } else {  # 3PL
        c[j] + (1 - c[j]) / (1 + exp(-a[j]*(th - b[j])))
      }
    })
    
    if(input$model == "1PL (Rasch)") {
      P * (1 - P)
    } else if(input$model == "2PL") {
      sweep(P*(1 - P), 2, a^2, `*`)
    } else { # 3PL
      a_matrix <- matrix(a, nrow = nrow(P), ncol = ncol(P), byrow = TRUE)
      c_matrix <- matrix(c, nrow = nrow(P), ncol = ncol(P), byrow = TRUE)
      P_star <- (P - c_matrix) / (1 - c_matrix)
      (a_matrix^2) * P_star * (1 - P_star)
    }
  })
  
  theta_grid <- reactive(seq(-4, 4, length.out = 401))
  
  # Configurations for ICCs
  output$icc_plot <- renderPlot({
    th <- theta_grid()
    a <- get_a()
    b <- get_b()
    c <- get_c()
    
    # Subset based on selected items
    selected_items <- which(item_names %in% input$items)
    if(length(selected_items) == 0) return(NULL)  # nothing selected
    # P <- P[, selected_items, drop = FALSE]
    plot_items <- item_names[selected_items]
    
    # Compute P(theta) for selected items
    P <- sapply(selected_items, function(j){
      if(input$model == "1PL (Rasch)") {
        1 / (1 + exp(-(th - b[j])))
      } else if(input$model == "2PL") {
        1 / (1 + exp(-a[j]*(th - b[j])))
      } else {  # 3PL
        c[j] + (1 - c[j]) / (1 + exp(-a[j]*(th - b[j])))
      }
    })
    
    # Create dataframe for plotting 
    df <- data.frame(theta = rep(th, times = ncol(P)),
                     prob = as.vector(P),
                     item = factor(rep(plot_items, each = length(th)), levels = plot_items))
    
    # Add parameter labels if selected
    df_labels <- NULL
    if(input$show_params){
      df_labels <- lapply(seq_along(plot_items), function(i){
        idx <- selected_items[i]
        # Probability at marker
        theta_marker <- input$b_shift
        p_theta <- if(input$model == "3PL") {
          c[idx] + (1 - c[idx]) / (1 + exp(-a[idx]*(theta_marker - b[idx])))
        } else if(input$model == "2PL") {
          1 / (1 + exp(-a[idx]*(theta_marker - b[idx])))
        } else {  # 1PL
          1 / (1 + exp(-(theta_marker - b[idx])))
        }
        data.frame(
          theta = theta_marker,
          prob  = p_theta,
          label = paste0("a=", round(a[idx],2), ", b=", round(b[idx],2), ", c=", round(c[idx],2)),
          item  = plot_items[i]
        )
      })
      df_labels <- do.call(rbind, df_labels)
    }
    # Only map colors to the selected items
    selected_colors <- um_colors[match(plot_items, item_names)]
    names(selected_colors) <- plot_items
    
    # Plot ICCs
    p <- ggplot(df, aes(theta, prob, color = item)) +
      geom_line(size = 1.2) +
      geom_vline(xintercept = input$b_shift, linetype = "dashed") +
      coord_cartesian(ylim = c(0, 1)) +
      labs(
        title = paste("Item Characteristic Curves (ICC) -", input$model),
        x = expression(theta), 
        y = "Probability of Endorsing Item", 
        color = "Item"
      ) +
      scale_color_manual(values = selected_colors) + 
      theme_minimal(base_size = 14) +
      theme(
        plot.title = element_text(face = "bold", size = 16),
        legend.title = element_text(face = "bold"),
        legend.position = "top"
      )
    
    if(input$show_params){
      p <- p + geom_text(
        data = df_labels,
        aes(x = theta, y = prob, label = label, color = item),
        hjust = -0.1, vjust = -0.5, size = 3,
        show.legend = FALSE
      )
    }
    
    p})
  
  # Configurations for TCC
  output$tcc_plot <- renderPlot({
    th <- theta_grid(); P <- p_mat()
    tcc <- rowSums(P)
    ggplot(data.frame(theta = th, tcc = tcc), aes(theta, tcc)) +
      geom_line(size = 1.2, color = um_colors["teal"]) +
      labs(title = paste("Test Characteristic Curve (TCC) -", input$model),
           x = expression(theta), 
           y = "Expected Total Score") +
      scale_color_manual(values = um_colors) +
      theme_minimal(base_size = 14) +
      theme(
        plot.title = element_text(face = "bold", size = 16),
        legend.title = element_text(face = "bold"),
        legend.position = "top"
      )
  })
  
  # Configurations for IICs
  output$iic_plot <- renderPlot({
    th <- theta_grid()
    Imat <- info_mat()
    df <- data.frame(
      theta = rep(th, times = 5),
      info  = as.vector(Imat),
      item  = factor(rep(item_names, each = length(th)), levels = item_names)
    )
    
    ggplot(df, aes(x = theta, y = info)) +
      geom_line(size = 1.2, color = um_colors["blue"]) +
      geom_vline(xintercept = input$theta_marker, linetype = "dashed", color = um_colors["maize"]) +
      facet_wrap(~item, ncol = 3, scales = "free_y") +
      labs(
        title = paste("Item Information Curves (IIC) -", input$model),
        x = expression(theta),
        y = "Item information"
      ) +
      theme_minimal(base_size = 14) +
      theme(
        plot.title = element_text(face = "bold", size = 16),
        strip.background = element_rect(fill = um_colors["maize"], color = um_colors["blue"], size = 1.5),
        strip.text = element_text(color = um_colors["blue"], face = "bold", size = 12),
        panel.border = element_rect(color = um_colors["blue"], fill = NA, size = 1),
        panel.spacing = unit(0.5, "cm")
      )
  })
  
  # Configurations for TIC & SE
  output$tif_plot <- renderPlot({
    th <- theta_grid()
    Imat <- info_mat()
    tic <- rowSums(Imat)
    
    se <- sqrt(1 / tic)
    se_scaled <- se * max(tic) / max(se)
    
    df <- data.frame(theta = th, TIC = tic, SE = se_scaled)
    
    # Positions for line labels
    label_df <- data.frame(
      theta = max(th),
      value = c(tic[length(tic)], se_scaled[length(se_scaled)]),
      label = c("TIC", "SE"),
      color = c(um_colors["blue"], um_colors["red"])
    )
    
    ggplot(df, aes(x = theta)) +
      geom_line(aes(y = TIC, color = um_colors["blue"]), size = 1.3) +
      geom_line(aes(y = SE, color = um_colors["red"]), size = 1.2, linetype = "dashed") +
      geom_text(data = label_df, aes(x = theta, y = value, label = label, color = color),
                hjust = -0.1, vjust = 0.5, fontface = "bold") +
      labs(
        title = paste("Test Information Curve & Standard Error Distribution -", input$model),
        x = expression(theta),
        y = "Value"
      ) +
      theme_minimal(base_size = 14) +
      theme(
        plot.title = element_text(face = "bold", size = 16),
        legend.position = "none"  # hide legend
      ) +
      xlim(min(th), max(th) + 0.5)  # add extra space for labels
  })
  
  # Toggle/set collapsible descriptions for each graph
  observeEvent(input$toggle_icc, {toggle("icc_info")})
  observeEvent(input$toggle_tcc, {toggle("tcc_info")})
  observeEvent(input$toggle_iic, {toggle("iic_info")})
  observeEvent(input$toggle_tic, {toggle("tic_info")})
  
}