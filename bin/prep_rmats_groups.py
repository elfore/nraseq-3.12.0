#!/usr/bin/env python3

import pandas as pd
import sys
import os

def prep_rmats_groups(csv_file, out_dir):
    df = pd.read_csv(csv_file)
    conditions = df['condition'].unique()
    
    if len(conditions) < 2:
        print("Need at least 2 conditions for rMATS comparison.")
        return

    # 这里我们只取前两个条件进行两两比较 (rMATS 原生支持一对一)
    c1, c2 = conditions[0], conditions[1]
    
    b1 = df[df['condition'] == c1]['sample'].tolist()
    b2 = df[df['condition'] == c2]['sample'].tolist()
    
    print(f"Condition 1: {c1} ({len(b1)} samples)")
    print(f"Condition 2: {c2} ({len(b2)} samples)")
    
    return c1, c2

if __name__ == "__main__":
    if len(sys.argv) < 3:
        print("Usage: prep_rmats_groups.py <samplesheet.csv> <out_dir>")
        sys.exit(1)
    
    prep_rmats_groups(sys.argv[1], sys.argv[2])
