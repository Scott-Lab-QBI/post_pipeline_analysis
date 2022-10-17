function [ PerBrainRegions ] = getPerBrainRegions(Zbrain_Masks, ROI_centroids)
%% getPerBrainRegions - Return a struct of brain regions with which ROIs they contain
%   A bit of a hacktogether function of some commonly used code which
%   focuses on the top 10 brain regions we typically study. Returns a
%   struct where elements are brain regions containing lists of the ROIs
%   within the brain region. ROIs are indexed based on their linear indexes
%   within ROI_centroids. 
%
%   Use of PerBrainRegions is as follows:
%       PerBrainRegions = getPerBrainRegions( ... );
%       thalamus_idxs = PerBrainRegions.Thalamus.idx;
%
%   Parameters:
%       Zbrain_Masks - a matrix Gilles made out of Zbrain data, I don't
%           know what operations he applied but these matrices are changed
%           from the default zbrains data so ensure you have Gilles copy,
%           can be found in the PIPEDATA RDM (if at UQ still). 
%       ROI_centroids - matrix of ROI spatial position of size (#rois x 3)
%
%
%   Preconditions:
%       Assumes ROIs have been appropriately rotated according to Zbrain_Masks 
%
%

% Round just in case the ROIs weren't already rounded
ROI_correct = round(ROI_centroids);
RegionList = {'Thalamus','Cerebellum','Semicircularis','Telencephalon','Tectum','Tegmentum','Habenula','Pretectum','MON','Hindbrain'};

%% Assign all ROIs to a region
PerBrainRegions=struct();
for i=1:length(RegionList)
    regionName=RegionList{i};
    if strcmp(regionName,'Telencephalon')
        Mask=Zbrain_Masks{294,3};
        
    elseif strcmp(regionName,'Hindbrain')
        Hindbrain_Mask=Zbrain_Masks{259,3};
        Mask=Zbrain_Masks{131,3};
        IsInEyes_temp=ismember(Hindbrain_Mask,Mask,'rows');IsInEyes_temp=find(IsInEyes_temp==1);%remove cerebellum
        Hindbrain_Mask(IsInEyes_temp,:)=[];
        Mask=Zbrain_Masks{295,3};
        IsInEyes_temp=ismember(Hindbrain_Mask,Mask,'rows');IsInEyes_temp=find(IsInEyes_temp==1);%remove MON
        Hindbrain_Mask(IsInEyes_temp,:)=[];
        Mask=Hindbrain_Mask;
        
    else
        Mask=[];
        IndexC=strfind({Zbrain_Masks{:,2}}, regionName);
        IndexC=find(not(cellfun('isempty', IndexC)));
        for j=IndexC
            if isempty(Mask)
                Mask=Zbrain_Masks{j,3};
            else
                Mask=vertcat(Mask,Zbrain_Masks{j,3});
            end
        end
    end
    Mask=unique(Mask,'rows');
    IsInBrainRegion=ismember(ROI_correct,Mask,'rows'); 
    PerBrainRegions.(regionName).idx=find(IsInBrainRegion==1);    
end

end