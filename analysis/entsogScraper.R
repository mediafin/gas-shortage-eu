entsog_codes <- entsog_points %>% filter(!is.na(entsog_id)) %>% distinct(entsog_id)
df_entsog <- data.frame()

for (i in seq(1, nrow(entsog_codes))) {
  temp_phys <- entsog::eg_op(indicator = "Physical Flow", pointDirection = entsog_codes[[i, "entsog_id"]],
                             from = "2015-01-01", 
                             to = Sys.Date(), 
                             periodType = "day")
  
  df_entsog <- bind_rows(df_entsog, temp_phys)
  
}

df_entsog %>% write_csv("data/entsog/entsog-all.csv")