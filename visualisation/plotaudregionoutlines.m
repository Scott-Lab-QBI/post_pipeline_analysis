function [] = plotaudregionoutlines(region_idxs, alpha, aud_region_colours)

    if ~exist("region_idxs", "var")
        region_idxs = 1:10;
    end
    if ~exist("alpha", "var")
        alpha = 0.1;
    end

    load('audregionsoutlines.mat');

    %% Draw aud sensitive region outlines
    if (~exist('LOADED_OUTLINES', 'var') || ~strcmp(LOADED_OUTLINES, 'aud')) && ~exist('aud_region_colours', 'var')
        %load('audregionsoutlines.mat');
        aud_region_colours = {[1, 0, 0], [0, 1, 0], [0, 0, 1], [1, 0.5, 0], [1, 0.25, 0.5], [0.5, 0, 0.25], [0.5, 0.5, 0.5], [0.25, 0.5, 0], [0.85, 0.8, 0.15], [0.5, 0, 1]};
        %aud_region_colours = tab10(10);
        %aud_region_colours = {'red','green','yellow','green','magenta','cyan', 'blue','black','blue','red'};
    
        LOADED_OUTLINES = 'aud';
    end
    
    hold on
    for i = region_idxs
        trimesh(region_triangulations{i}, 'facealpha', alpha, 'facecolor', aud_region_colours{i}, 'linestyle', 'none');
    end
    set(gca, 'YDir','reverse')

end