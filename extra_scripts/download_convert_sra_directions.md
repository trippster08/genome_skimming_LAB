# Download SRA data
Copy this into the termina, replacing the two paths with your own before executing. I usually save the SRAs into data/sra/, and save sra_list.csv there as well, so you are putting the sra sequences and sra list in the same directory.
```
prefetch -O <path_to_output_sra_directory> --option-file <path_to_SRA_list.csv> --progress
```
