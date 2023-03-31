library(data.table)
library(tidyverse)
library(readxl)


export_path = "../../../../../home/zpg/Documents/ma_thesis"
setwd("../../project2/databases/bfi/bfi-tax_deed/new_version")
file_list = list.files()

text_data_files = file_list[str_detect(file_list,"_data.txt")&str_detect(file_list,"hist_property_basic1")]

counts_files = file_list[str_detect(file_list,"cnts")]

hpb = read_excel(path="Historical Property Basic_v1.xlsx")
pbv2 = read_excel("university_of_chicago_booth_school_of_business_property_basic2_300000278746860_20210728_110001_meta/Property Basic_v2.xlsx")
# There are a whole bunch of other sheets here, might be interesting
# Seems like they have the definitions of the codes used 
# excel_sheets("university_of_chicago_booth_school_of_business_property_basic2_300000278746860_20210728_110001_meta/Property Basic_v2.xlsx")

sr = read_delim("SampleRecords.txt",delim='|')
sr_names = names(sr)
core_cols = c("CLIP","NUMBER OF BUILDINGS","NUMBER OF UNITS","MUNICIPALITY NAME",
              "SITUS STREET ADDRESS","SITUS CITY","SITUS COUNTY","SITUS STATE",
              "SITUS ZIP CODE",
             "FIPS CODE","YEAR BUILT",
              "EFFECTIVE YEAR BUILT","ACRES","LAND SQUARE FOOTAGE",
             "UNIVERSAL BUILDING SQUARE FEET","BUILDING SQUARE FEET")
sr_core = sr %>% select(all_of(core_cols))
#head(sr_core)
example_file = read_delim(
  "university_of_chicago_booth_school_of_business_hist_property_basic1_300000278746866_10_20210728_161501_data.txt",
  delim='|',col_types=cols_only(`CLIP`=col_guess(),
                                `NUMBER OF BUILDINGS`=col_integer(),
                                `NUMBER OF UNITS`=col_integer(),
                                `MAILING CITY`=col_character(),
                                `MAILING STATE`=col_character(),
                                `FIPS CODE`=col_character(),
                                `YEAR BUILT`=col_integer(),
                                `EFFECTIVE YEAR BUILT`=col_integer()),n_max=10**6)

# This is just counts per county of how many properties there are
counts_1 = read_delim("university_of_chicago_booth_school_of_business_hist_property_basic1_300000278746866_01_20210728_180000_cnts.txt",
                          delim='|')
counts_2 = read_delim("university_of_chicago_booth_school_of_business_hist_property_basic1_300000278746866_02_20210728_174501_cnts.txt",
                             delim='|')
counts_3 = read_delim("university_of_chicago_booth_school_of_business_hist_property_basic1_300000278746866_03_20210728_173001_cnts.txt",
                      delim='|')

# Grand Total 153073066
counts_non_hist = read_delim("university_of_chicago_booth_school_of_business_property_basic2_300000278746860_20210728_110001_meta/university_of_chicago_booth_school_of_business_property_basic2_300000278746860_20210728_110001_cnts.txt",
                             delim="|")

example_xlsx = read_excel("university_of_chicago_booth_school_of_business_hist_property_basic1_300000278746866_01_20210728_180000_meta/University_of_Chicago_Booth_School_of_Bu_1097967_University_of_Chicago_Booth_School_of_Bu_2021-07-28_001.xlsx")

# for (i in 1:length(text_data_files)){
#file_i = text_data_files[i]
n_total = 153073066 # got from grand total at end of counts file
chunk_size=2*(10**6)
n_chunks = round(n_total/chunk_size)+1
hist_property_basics1_fname = "university_of_chicago_booth_school_of_business_hist_property_basic1_300000278746866_01_20210728_180000_data.txt"
property_basic2_fname = "university_of_chicago_booth_school_of_business_property_basic2_300000278746860_20210728_110001_data.txt"
#col_names_vec = names(read_delim(
#  hist_property_basics1_fname,n_max=0,delim="|"))
#new_dir_name = "hist_property_basic1_01_20210728_180000_data"
new_dir_name = "property_basic2_20210728_110001_data"
col_names_vec_alt = names(fread(file=property_basic2_fname,nrows=0))
core_cols_ordered = col_names_vec_alt[col_names_vec_alt %in% core_cols]
core_col_nums = which(col_names_vec_alt %in% core_cols_ordered)
ifelse(!dir.exists(file.path(export_path,new_dir_name)),
       dir.create(file.path(export_path,new_dir_name)),F)
print(n_chunks)
for (i in 1:n_chunks){
print(str_glue("CHUNK {i}"))
#data_i = read_delim(
#    hist_property_basics1_fname,
#    delim='|',
#    col_names = col_names_vec,
#    col_types=cols_only(`CLIP`=col_guess(),
#                                  `NUMBER OF BUILDINGS`=col_integer(),
#                                  `NUMBER OF UNITS`=col_integer(),
#                                  `FIPS CODE`=col_character(),
#                                  `YEAR BUILT`=col_integer(),
#                                  `EFFECTIVE YEAR BUILT`=col_integer()),
#    skip = (i-1)*chunk_size,
#    n_max=chunk_size)


data_i = fread(file = property_basic2_fname,
            #   nrows=100,
            #  skip = 5,
              # sep = "|",
            col.names = core_cols_ordered,
              header=F,
             select=core_col_nums,
              skip = (i-1)*chunk_size,
             nrows=chunk_size
)
data_subset = data_i %>%
  filter(`NUMBER OF UNITS`>=3&(is.na(`YEAR BUILT`)==F|is.na(`EFFECTIVE YEAR BUILT`)==F))
write.csv(data_subset,file=str_glue("{export_path}/{new_dir_name}/chunk_{i}.csv"),
          row.names=F)

}

########
non_hist_data = read_delim(
  "university_of_chicago_booth_school_of_business_property_basic2_300000278746860_20210728_110001_data.txt",
  delim='|',col_types=cols_only(`CLIP`=col_guess(),
                                `NUMBER OF BUILDINGS`=col_integer(),
                                `NUMBER OF UNITS`=col_integer(),
                                `MAILING CITY`=col_character(),
                                `MAILING STATE`=col_character(),
                                `YEAR BUILT`=col_integer(),
                                `EFFECTIVE YEAR BUILT`=col_integer()),n_max=10**4)
nrow(non_hist_data %>% filter(`NUMBER OF UNITS`>5))
nrow(non_hist_data %>% filter(`NUMBER OF UNITS`>5))/nrow(non_hist_data)


#write.csv(example_file,file=str_glue("{export_path}/example_records.csv"))
#write.csv(pbv2,file=str_glue("{export_path}/data_dictionary_pbv2.csv"))
#write.csv(sr,file=str_glue("{export_path}/full_sample_records.csv"))

#new_dir = str_glue("{export_path}/property_basic2_20210728_110001_meta_test/")
#dir.create(new_dir)
#source_folder = "university_of_chicago_booth_school_of_business_property_basic2_300000278746860_20210728_110001_meta/"
#files_to_copy = list.files(source_folder)
#file.copy(source_folder,new_dir)