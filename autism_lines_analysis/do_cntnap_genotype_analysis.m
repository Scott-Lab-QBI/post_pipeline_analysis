%% Run pipeline genotype analysis for fake cntnap 


g1 = [7, 26, 38, 39];
g2 = [2, 3, 11, 16, 37];
g3 = [17, 23, 29, 30];
g4 = [15, 27, 31, 32, 40];


pipeline_output_path= 'Z:\CNTNAPGEN-Q4527\SPIM\Analysis';

genotypes = cell(4, 2);
genotypes{1, 1} = g1; genotypes{1, 2} = 'AB (WT)'; % WT
genotypes{2, 1} = g2; genotypes{2, 2} = 'ab (MT)'; % MUT
genotypes{3, 1} = g3; genotypes{3, 2} = 'aB'; %mut a qt b
genotypes{4, 1} = g4; genotypes{4, 2} = 'Ab'; % mutb wtA

sep_idxs = [1200];

autism_line_genotype_analysis;