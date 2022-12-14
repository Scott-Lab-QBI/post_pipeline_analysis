%% AUTISM_LINE_GENOTYPE_ANALYSIS - Default analysis by genotype for pipeline
%   The default genotype based analysis to be run after all fish have been
%   individually processed by the pipeline.  
%
%   Args:
%       pipeline_output_path - A full path to a folder containing s2p
%           processed fish.
%       sep_idxs - Where the stimuli trains should be split (e.g. spont vs
%           auditory recordings 
%       genotypes - cell array where each row contains information about a
%           genotype. First column is the fish numbers included in this
%           genotype. second colmn is a string name for the genotype.
%
%   Example usage:
%       pipeline_genotype_analysis(pipeline_output_path, config)
%

analysis_dir = fullfile(pipeline_output_path, 'genotype_analysis');
if ~exist(analysis_dir, 'dir')
    mkdir(analysis_dir);
end


fprintf('-----------------THERE IS A RETURN HERE TO STOP ME OVERWRITING loaded variables.')
return;
% Load data manually
% load('C:\Users\uqjarno4\projects\matlab_path\data\cntnap\all_fish_std_fmt.mat');
% % Just for testing


% if exists, load mat file directly, else do fresh load
std_fmt_data_dir = fullfile(pipeline_output_path, 'std_fmt_output');
std_fmt_file = fullfile(std_fmt_data_dir, 'all_fish_std_fmt.mat');
if exist(std_fmt_file, 'file')
    if ~exist('TEST_LOADED', 'var')    
        fprintf('Found existing matlab file, loading that.\n');
        %load(std_fmt_file);
        load('data\cntnap\all_fish_std_fmt.mat', 'fish_numbers', 'ROI_centroids', 'fish_ncells', 'fish_numbers', 'stim_trains');
    end
    TEST_LOADED = 1;
else
    [ROI_centroids, fish_ncells, fish_numbers, stim_trains] = load_all_fish_standard_format(pipeline_output_path, sep_idxs, true, true, true);
    % Save result so we don't have to recompute
    save(std_fmt_file, 'stim_trains', 'ROI_centroids', 'fish_numbers', 'fish_ncells', '-v7.3');
end


%% Create useful variables
fish_number = '-all';

% Generate full roi -> fish mapping
roi_fish_idxs = zeros(size(stim_trains{1}, 1), 1);
fish_numbers_ints = cellfun(@str2num, fish_numbers);
last_idx = 1;
for i = 1 : numel(fish_numbers)
    fish_end = last_idx + fish_ncells(i) - 1;
    roi_fish_idxs(last_idx:fish_end) = fish_numbers_ints(i);
    last_idx = fish_end + 1;
end


% Now make genotype specific indxs
roi_genotype_idxs = zeros(size(stim_trains{1}, 1), 1);
fish_genotypes = zeros(size(fish_numbers));
for i = 1 : size(genotypes, 1)
    
    %Get which fish belong to this genotype + the indexs they are at in
    %fish_numbers (IB)
    [genotype_fish_nums, ~, IB] = intersect(genotypes{i}, fish_numbers_ints);
    fish_genotypes(IB) = i;
    
    for j = 1 : numel(genotype_fish_nums)
        roi_genotype_idxs(roi_fish_idxs == genotype_fish_nums(j)) = i;
    end
    
end

stim_train_names = {'Spont.', 'Aud. train'};




%% 
% plot average raw trace and average delta trace
figure('Position', [1, 1, 1920, 1080]);
last_idx = 1;
sep_idxs = [sep_idxs, size(stim_trains{1}, 2)]; % Last idx is seperation
for st = 1 : numel(stim_trains)
    sep_idx = sep_idxs(st);
    %subplot(numel(stim_trains), 1, st * 2);
    %plot(mean(Suite2p_traces(:, last_idx:sep_idx),1));
    %title(sprintf('Mean raw trace stim train %d (fish%s)', st, fish_number)); ylabel('f');xlabel('frames');
    subplot(numel(stim_trains), 1, st);
    plot(mean(stim_trains{st},1));
    title(sprintf('Mean Df stim train: %s (fish%s)', stim_train_names{st}, fish_number));ylabel('df/f');xlabel('frames');
    last_idx = last_idx + sep_idx;
end
sgtitle('Mean brain wide df/f for stim trains');
saveas(gcf, fullfile(analysis_dir, sprintf('raw_vs_DF_traces_fish%s.png', fish_number)));

%% Assign each ROI to one of the 10 brain regions
load('I:\PIPEDATA-Q4414\Zbrain_Masks.mat', 'Zbrain_Masks');
PerBrainRegions = getPerBrainRegions(Zbrain_Masks, ROI_centroids);
RegionList={'Thalamus','Cerebellum','Semicircularis','Telencephalon','Tectum','Tegmentum','Habenula','Pretectum','MON','Hindbrain'};
h = figure;
h.Position = [100, 100, 1180, 1700]./2;
hold on
for i = 1 : length(RegionList)
    region_name = RegionList{i};
    in_region = PerBrainRegions.(region_name).idx;
    plot3(ROI_centroids(in_region, 2), ROI_centroids(in_region, 1), ROI_centroids(in_region, 3), '.')
end
title(sprintf('All ROIs in 10 main regions (fish%s)', fish_number));
saveas(gcf, fullfile(analysis_dir, sprintf('zbrain_warped_ROIs_regional_matlabfig_fish%s.fig', fish_number)));
saveas(gcf, fullfile(analysis_dir, sprintf('zbrain_warped_ROIs_regional_matlabfig_fish%s.png', fish_number)));


%% Draw 2D boundry and take still shots
[tx, ty, sx, sy] = getZbrainOutline(RegionList);
% Add outlines to previous regionwise plot
%plot3(tx, ty, mean(ROI_centroids(:, 3)) * ones(size(ty, 1), 1), 'linewidth', 10); % horizontal

figure; % Front on of fish
plot(ROI_centroids(:, 2), ROI_centroids(:, 3), '.');
hold on
plot(sx, sy)
title(sprintf('All ROIs from fish%s', fish_number));
saveas(gcf, fullfile(analysis_dir, sprintf('zbrain_warped_ROIs_front_fish%s.png', fish_number)));

h = figure; % Top view
h.Position = [100, 100, 1080, 1600]./2;
plot(ROI_centroids(:, 2), ROI_centroids(:, 1), '.');
hold on
plot(tx, ty);
title(sprintf('All ROIs from fish%s', fish_number));
saveas(gcf, fullfile(analysis_dir, sprintf('zbrain_warped_ROIs_top_fish%s.png', fish_number)));


%% for each region, plot the mean
PerBrainRegions = getPerBrainRegions(Zbrain_Masks, ROI_centroids);
for st = 1 : numel(stim_trains)
    h = figure('Position', [1, 1, 1920, 1080]);
    hold on
    for i = 1: numel(RegionList)
        subplot(4, 3, i);
        region_name = RegionList{i};
        region_rois = PerBrainRegions.(region_name).idx;
        stim_train = stim_trains{st};
        region_aud_dfs = stim_train(region_rois, :);
        plot(mean(region_aud_dfs))
        title(sprintf('%s mean df/f', region_name));
        xlabel('Frame'); ylabel('df/f');
    end
    sgtitle(sprintf('Stimulus train %d', st));
    saveas(h, fullfile(analysis_dir, sprintf('regional_mean_df_stim%d_fish%s.png', h_idx, fish_number)));
end


%% Number of ROIs per region
figure;
n_rois = zeros(numel(RegionList), numel(fish_numbers));
total_regional_rois = 0;
last_idx = 1;
for fish_idx = 1 : numel(fish_numbers)
    
    % Generate new PerbrianRegion 
    next_idx = fish_ncells(fish_idx);
    fish_ROI_centroids = ROI_centroids(last_idx:next_idx, :);
    fish_PerBrainRegions = getPerBrainRegions(Zbrain_Masks, fish_ROI_centroids);
    last_idx = fish_ncells(fish_idx);
    
    for region_idx = 1 : numel(RegionList)
        region_name = RegionList{region_idx};
        n_rois(region_idx, fish_idx) = numel(fish_PerBrainRegions.(region_name).idx);
        total_regional_rois = total_regional_rois + n_rois(region_idx);
    end
end
bar(n_rois', 'stacked');
title(sprintf('ROIs per brain region fish%s (%d total regional ROIs)', fish_number, total_regional_rois));
ax=gca; ax.YAxis.Exponent=0;
xtickangle(45)
xticklabels(RegionList)
xlabel('Region');ylabel('Number of ROIs');
legend(fish_numbers);
saveas(gca, fullfile(analysis_dir, sprintf('ROIs_per_region_fish%s.png', fish_number)));


%% Regression
regressor = ASD_standard_regressor();

% Plot regressor so we can visually check
figure;
imagesc(regressor);
title(sprintf('regressor used fish%s', fish_number));
saveas(gcf, fullfile(analysis_dir, sprintf('regressor_used_fish%s.png', fish_number)));

% Hardcode regression for stim_train 2 (audio), maybe make this
% configurable later with the config file.
reg_train = stim_trains{2};

% Do Regression 
model_basic=struct();
parfor i=1:size(reg_train,1)
    mdl=fitlm(regressor',reg_train(i,:));  %change here to use 2 regressor Hab(:,220 bla bla bla) 
    model_basic(i).coef=mdl.Coefficients;        
    model_basic(i).rsquared=mdl.Rsquared.Adjusted;
end

%See what the r2 looks like
rsq=[model_basic.rsquared];
figure;
histogram(rsq);
title(sprintf('All r2 values for linear regression fish%s', fish_number));
xlabel('r^2'); ylabel('count'); 
saveas(gcf, fullfile(analysis_dir, sprintf('r2_values_fish%s.png', fish_number)));


%% Now some regression analysis

idx_rsq=find(rsq>0.05);

% Look at where the neurons are that pass the rsq filter
figure('Position', [100, 100, 1080, 1600]./2);
hold on
for region_idx = 1 : numel(RegionList)
    region_name = RegionList{region_idx};
    region_rois = PerBrainRegions.(region_name).idx;
    shared = intersect(idx_rsq, region_rois);
    plot3(ROI_centroids(shared,2),ROI_centroids(shared,1),ROI_centroids(shared,3),'.');
end
% Draw outline
plot(tx, ty);
saveas(gcf, fullfile(analysis_dir, sprintf('aud_responsive_roi_locs_fish%s.png', fish_number)));

% Mean of all auditory responsive neurons
figure;
plot(mean(reg_train(idx_rsq, :)));
title(sprintf('Mean of auditory responsive neurons, fish%s', fish_number));
xlabel('Frame');
ylabel('mean df/f');
saveas(gcf, fullfile(analysis_dir, sprintf('aud_responsive_mean_df_fish%s.png', fish_number)));

% Mean of auditory responsive neurons by region
figure('Position', [1, 1, 1920, 1080]);
for region_idx = 1 : numel(RegionList)
    subplot(4, 3, region_idx);
    region_name = RegionList{region_idx};
    region_rois = PerBrainRegions.(region_name).idx;
    shared = intersect(idx_rsq, region_rois);
    region_resp_roi_dfs = reg_train(shared, :);
    plot(mean(region_resp_roi_dfs));
    title(sprintf('%s mean df/f', region_name));
    xlabel('Frame'); ylabel('df/f');
end
sgtitle(sprintf('Region wise mean of audio responsive rois fish%s', fish_number));
saveas(gcf, fullfile(analysis_dir, sprintf('aud_responsive_regional_mean_df_fish%s.png', fish_number)));

















%end