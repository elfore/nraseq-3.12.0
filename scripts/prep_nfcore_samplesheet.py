#!/usr/bin/env python3
import csv
import sys
import os

def prep_samplesheet(input_csv, output_csv):
    required_cols = ['sample', 'fastq_1', 'fastq_2', 'strandedness']
    
    if not os.path.exists(input_csv):
        print(f"Error: {input_csv} does not exist.")
        sys.exit(1)
        
    with open(input_csv, 'r') as f_in, open(output_csv, 'w', newline='') as f_out:
        # Ignore comments
        lines = [line for line in f_in if not line.strip().startswith('#')]
        
        if not lines:
            print("Error: Empty input CSV.")
            sys.exit(1)
            
        # Parse CSV
        reader = csv.DictReader(lines)
        writer = csv.DictWriter(f_out, fieldnames=required_cols)
        
        # Check if all required columns are present
        for col in required_cols:
            if col not in reader.fieldnames:
                print(f"Error: Input CSV must contain '{col}' column.")
                sys.exit(1)
                
        writer.writeheader()
        
        for row in reader:
            # Filter only required columns
            filtered_row = {col: row[col] for col in required_cols}
            writer.writerow(filtered_row)
            
    print(f"Successfully generated nf-core compatible samplesheet: {output_csv}")

if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("Usage: python prep_nfcore_samplesheet.py <input.csv> <output.csv>")
        sys.exit(1)
        
    prep_samplesheet(sys.argv[1], sys.argv[2])
