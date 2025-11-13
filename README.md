# PepMapViz: Peptide Mapping and Visualization Tool

PepMapViz is an R package that helps researchers visualize peptides mapped to protein sequences. It can highlight mutations, post-translational modifications, and compare different experimental conditions through an easy-to-use web interface.

## 🚀 Quick Start: Run the Shiny App

**Want to use PepMapViz right away?** Follow these simple steps to get the interactive web application running on your computer:

### Method 1: Docker (Recommended - Easiest!)

If you have Docker installed on your computer, this is the fastest way:

1. **Download this repository:**
   - Click the green "Code" button above
   - Select "Download ZIP"
   - Extract the ZIP file to a folder on your computer

2. **Open Terminal/Command Prompt:**
   - **Windows:** Press `Windows + R`, type `cmd`, press Enter
   - **Mac:** Press `Cmd + Space`, type "Terminal", press Enter
   - **Linux:** Press `Ctrl + Alt + T`

3. **Navigate to the downloaded folder:**
   ```bash
   cd path/to/PepMapViz-main
   ```
   (Replace `path/to/PepMapViz-main` with the actual path where you extracted the files)

4. **Run the Docker container:**
   ```bash
   docker-compose up
   ```

5. **Open your web browser and go to:**
   ```
   http://localhost:3838
   ```

🎉 **That's it!** The PepMapViz app should now be running in your browser.

To stop the app, press `Ctrl + C` in the terminal.

---

### Method 2: Install R and Run Locally

If you don't have Docker or prefer to run R directly:

#### Step 1: Install Required Software

1. **Install R:**
   - Go to https://cran.r-project.org/
   - Download and install R for your operating system

2. **Install RStudio (Optional but Recommended):**
   - Go to https://posit.co/download/rstudio-desktop/
   - Download and install RStudio Desktop

#### Step 2: Download and Install PepMapViz

1. **Download this repository** (same as Method 1, steps 1-3)

2. **Open R or RStudio**

3. **Set your working directory to the downloaded folder:**
   ```r
   setwd("path/to/PepMapViz-main")
   ```

4. **Install required packages:**
   ```r
   # Install renv for package management
   install.packages("renv")
   
   # Restore the project environment
   renv::restore()
   ```

5. **Install PepMapViz:**
   ```r
   # Install devtools if you haven't already
   install.packages("devtools")
   
   # Install PepMapViz from the current directory
   devtools::install(".")
   ```

#### Step 3: Run the Shiny App

```r
# Load the package
library(PepMapViz)

# Launch the interactive web app
run_pepmap_app()
```

The app will open in your default web browser automatically!

---

## 💡 What Can You Do With PepMapViz?

- **Map peptides** to protein sequences
- **Identify domains** and regions of interest
- **Highlight mutations** and variations
- **Visualize post-translational modifications**
- **Compare** different experimental conditions
- **Analyze mass spectrometry** results at the peptide level

## 📊 Using Your Own Data

Once the app is running, you can:
1. Upload your own peptide data files
2. Configure visualization parameters
3. Generate interactive plots
4. Export results for publications

The app supports multiple data formats including PEAKS, MaxQuant, Spectronaut, and others.

---

## 🛠 Troubleshooting

### Docker Issues
- **Docker not found:** Install Docker from https://docker.com
- **Permission denied:** Try running with `sudo` (Linux/Mac)
- **Port 3838 in use:** Stop other applications using that port

### R Installation Issues
- **Package installation fails:** Update R to the latest version
- **Missing dependencies:** Run `install.packages(c("shiny", "ggplot2", "DT"))` first
- **renv restore fails:** Delete the `renv` folder and try `install.packages("devtools"); devtools::install(".")`

### Need Help?
- Check the [Issues page](https://github.com/stefftaelman/PepMapViz/issues) for common problems
- Create a new issue if you encounter bugs
- Review the example data in the `inst/extdata/` folder

---

## 📋 For Advanced Users

### Command Line Usage Example

``` r
library(PepMapViz)

# Read all files from a folder
folder_path <- system.file("extdata/example_PEAKS_result", package = "PepMapViz")
resulting_df <- combine_files_from_folder(folder_path)
meta_data_path <- system.file("extdata/example_PEAKS_metadata", package = "PepMapViz")
meta_data_df <- combine_files_from_folder(meta_data_path)
resulting_df <- merge(
  x = resulting_df,
  y = meta_data_df,
  by = "Source File",
  all.x = TRUE  # Left join behavior
)

# Strip the sequence 
striped_data_peaks <- strip_sequence(resulting_df, "Peptide", "Sequence", "PEAKS")

# Extract modifications information
PTM_table <- data.frame(PTM_mass = c("15.99", ".98", "57.02"),
                        PTM_type = c("Ox", "Deamid", "Cam"))
converted_data_peaks <- obtain_mod(
  striped_data_peaks,
  "Peptide",
  "PEAKS",
  seq_column = NULL,
  PTM_table,
  PTM_annotation = TRUE,
  PTM_mass_column = "PTM_mass"
)

# Match peptide sequence with provided sequence and calculate positions
whole_seq <- data.frame(
  Epitope = c("Boco", "Boco"),
  Chain = c("HC", "LC"),
  Region_Sequence = c("QVQLVQSGAEVKKPGASVKVSCKASGYTFTSYYMHWVRQAPGQGLEWMGEISPFGGRTNYNEKFKSRVTMTRDTSTSTVYMELSSLRSEDTAVYYCARERPLYASDLWGQGTTVTVSSASTKGPSVFPLAPCSRSTSESTAALGCLVKDYFPEPVTVSWNSGALTSGVHTFPAVLQSSGLYSLSSVVTVPSSNFGTQTYTCNVDHKPSNTKVDKTVERKCCVECPPCPAPPVAGPSVFLFPPKPKDTLMISRTPEVTCVVVDVSHEDPEVQFNWYVDGVEVHNAKTKPREEQFNSTFRVVSVLTVVHQDWLNGKEYKCKVSNKGLPSSIEKTISKTKGQPREPQVYTLPPSREEMTKNQVSLTCLVKGFYPSDIAVEWESNGQPENNYKTTPPMLDSDGSFFLYSKLTVDKSRWQQGNVFSCSVMHEALHNHYTQKSLSLSPGK", 
                      "DIQMTQSPSSLSASVGDRVTITCRASQGISSALAWYQQKPGKAPKLLIYSASYRYTGVPSRFSGSGSGTDFTFTISSLQPEDIATYYCQQRYSLWRTFGQGTKLEIKRTVAAPSVFIFPPSDEQLKSGTASVVCLLNNFYPREAKVQWKVDNALQSGNSQESVTEQDSKDSTYSLSSTLTLSKADYEKHKVYACEVTHQGLSSPVTKSFNRGEC"
  )
)
matching_result <- match_and_calculate_positions(
  converted_data_peaks,
  'Sequence',
  whole_seq,
  match_columns = NULL,
  sequence_length = c(10, 30),
  column_keep = c(
    "PTM_mass",
    "PTM_position",
    "reps",
    "Area",
    "Donor",
    "PTM_type"
  )
)

# Quantify matched peptide sequences by PSM
matching_columns = c("Chain", "Epitope")
distinct_columns = c("Donor")
data_with_psm <- peptide_quantification(
  whole_seq,
  matching_result,
  matching_columns,
  distinct_columns,
  quantify_method = "PSM",
  with_PTM = TRUE,
  reps = TRUE
)
region <- data.frame(
  Epitope = c("Boco", "Boco", "Boco", "Boco", "Boco", "Boco"),
  Chain = c("HC", "HC", "HC", "HC", "LC", "LC"),
  Region = c("VH", "CH1", "CH2", "CH3", "VL", "CL"),
  Region_start = c(1,119,229,338,1,108),
  Region_end = c(118,228,337,444,107,214)
)
result_with_psm <- data.frame()
for (i in 1:nrow(region)) {
  chain <- region$Chain[i]
  region_start <- region$Region_start[i]
  region_end <- region$Region_end[i]
  region_name <- region$Region[i]

  temp <- data_with_psm[data_with_psm$Chain == chain & 
                          data_with_psm$Position >= region_start & 
                          data_with_psm$Position <= region_end, ]
  temp$Region <- region_name

  result_with_psm <- rbind(result_with_psm, temp)
}
  
head(result_with_psm)
```

```         
##   Character Position Chain Epitope PSM Donor   PTM PTM_type Region
## 1         Q        1    HC    Boco   0    D1 FALSE     <NA>     VH
## 2         V        2    HC    Boco   0    D1 FALSE     <NA>     VH
## 3         Q        3    HC    Boco   0    D1 FALSE     <NA>     VH
## 4         L        4    HC    Boco   0    D1 FALSE     <NA>     VH
## 5         V        5    HC    Boco   0    D1 FALSE     <NA>     VH
## 6         Q        6    HC    Boco   0    D1 FALSE     <NA>     VH
```

``` r
# Plotting peptide in whole provided sequence
domain <- data.frame(
  domain_type = c("VH", "CH1", "CH2", "CH3", "VL", "CL", "CDR H1", "CDR H2", "CDR H3", "CDR L1", "CDR L2", "CDR L3"),
  Chain = c("HC", "HC", "HC", "HC",  "LC", "LC", "HC", "HC", "HC",  "LC", "LC", "LC"),
  Epitope = c("Boco", "Boco", "Boco", "Boco", "Boco", "Boco", "Boco", "Boco", "Boco", "Boco", "Boco", "Boco"),
  domain_start = c(1, 119, 229, 338, 1, 108, 26, 50, 97, 24, 50, 89),
  domain_end = c(118, 228, 337, 444, 107, 214, 35, 66, 107,  34, 56, 97),
  domain_color = c("black", "black", "black", "black", "black", "black", "#F8766D", "#B79F00", "#00BA38", "#00BFC4", "#619CFF", "#F564E3"),
  domain_fill_color = c("white", "white", "white", "white", "white", "white", "yellow", "yellow", "yellow", "yellow", "yellow", "yellow"), 
  domain_label_y = c(1.7, 1.7, 1.7, 1.7, 1.7, 1.7, 1.4, 1.4, 1.4, 1.4, 1.4, 1.4)
)
x_axis_vars <- c("Region")
y_axis_vars <- c("Donor")
column_order <- list(
    Donor = "D1,D2,D3,D4,D5,D6,D7,D8",
    Region = "VH,CH1,CH2,CH3,VL,CL"
)
PTM_color <- c(
  "Ox" = "red",
  "Deamid" = "cyan",
  "Cam" = "blue",
  "Acetyl" = "magenta"
)
label_filter = list(Donor = "D1")
```

```{r psm-plot, fig.width=30, fig.height=6, echo=TRUE, message=FALSE, warning=FALSE}
library(PepMapViz)
p_psm <- create_peptide_plot(
  data_with_psm,
  y_axis_vars,
  x_axis_vars,
  y_expand = c(0.2, 0.2),
  x_expand = c(0.5, 0.5),
  theme_options = list(legend.box = "horizontal", legend.position = "bottom"),
  labs_options = list(title = "PSM Plot", x = "Position", fill = "PSM"),
  color_fill_column = 'PSM',
  fill_gradient_options = list(),  # Set the limits for the color scale
  label_size = 1.3,
  add_domain = TRUE,
  domain = domain,
  domain_start_column = "domain_start",
  domain_end_column = "domain_end",
  domain_type_column = "domain_type",
  domain_border_color_column = "domain_color",
  domain_fill_color_column = "domain_fill_color",
  add_domain_label = TRUE,
  domain_label_size = 2,
  domain_label_y_column = "domain_label_y",
  domain_label_color = "black",
  PTM = TRUE,
  PTM_type_column = "PTM_type",
  PTM_color = PTM_color,
  add_label = TRUE,
  label_column = "Character",
  label_filter = label_filter,
  label_y = 1,
  column_order = column_order
)
print(p_psm)
```

![Example PSM plot](inst/extdata/example_plot.png)

---

## ⚙️ System Requirements

- **For Docker method:** Docker Desktop installed
- **For R method:** R version 4.0 or higher
- **Operating Systems:** Windows, macOS, or Linux
- **Browser:** Chrome, Firefox, Safari, or Edge
- **Memory:** At least 4GB RAM recommended

## 📁 Project Structure

- `inst/shiny_apps/PepMapVizApp/` - Shiny web application
- `R/` - Core R functions and algorithms  
- `inst/extdata/` - Example datasets for testing
- `man/` - Documentation files
- `Docker*` - Docker configuration files for easy deployment

## 🔄 Updates and Contributing

This is a fork of the original [Genentech/PepMapViz](https://github.com/Genentech/PepMapViz) with enhanced Docker support and improved ease of use.

### Getting Updates
To get the latest features from the original repository:
```bash
git pull upstream master
```

### Contributing
1. Fork this repository
2. Create a feature branch
3. Make your changes
4. Submit a pull request

---

## 📄 License

This project is licensed under the MIT License.

**Original work:** Copyright (c) 2024, Genentech, Inc.  
**Docker enhancements:** Copyright (c) 2025, stefftaelman

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

## 🙏 Acknowledgments

- Original PepMapViz package developed by Genentech, Inc.
- Docker containerization and usability improvements by stefftaelman
- Built with R, Shiny, ggplot2, and other amazing open-source tools
