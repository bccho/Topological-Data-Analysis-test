clc

%% Load images and 'sort' by numeral
if (~exist('images', 'var'))
    images = loadMNISTImages('train-images-idx3-ubyte');
end
if (~exist('labels', 'var'))
    labels = loadMNISTLabels('train-labels-idx1-ubyte');
end

% Save memory
n = 100;
images = images(:, 1:n);
labels = labels(1:n);
sidelength = 28;

% Look at only particular numerals
[sortedLabels, labelIndices] = sort(labels);
labelIndices = labelIndices(sortedLabels == 6);
ind = 1;

%% Loop through all of one particular numeral
thresholds = [0, 0.25, 0.5, 0.75];
nThresholds = length(thresholds);

chart_dim0 = 5;
chart_dim1 = 5;
betti_numbers = cell(length(labelIndices), nThresholds);
betti_chart = cell(chart_dim0, chart_dim1);

for ind = 1:length(labelIndices)
    img = reshape_image(images(:, labelIndices(ind)), 0, false);
    
    %% Loop through thresholds
    for iTh = 1:nThresholds
        thres = thresholds(iTh);
        
        % Compute Betti intervals
        [intervals, point_cloud] = BC_compute_intervals(img, 2, 10, 100, 1, thres, 4, 10000, false);
        
        % Filter relevant intervals
        intervals_dim0 = BC_filter_relevant_intervals(intervals, 0, 2);
        intervals_dim1 = BC_filter_relevant_intervals(intervals, 1, 1);
        
        % Compute Betti numbers and increment relevant position on chart
        bn = [size(intervals_dim0, 1), size(intervals_dim1, 1)];
        betti_numbers{ind}{iTh} = bn;
%         betti_chart{bn(1)+1, bn(2)+1} = [betti_chart{bn(1)+1, bn(2)+1}, ind];
        
        disp([num2str(ind), ' (', num2str(thres), ')', ': ', num2str(bn)])
    end
end

%% Display results
% cnt = 0;
% for dim0 = 1:chart_dim0
%     for dim1 = 1:chart_dim1
%         arr = betti_chart{dim0, dim1};
%         n = length(arr);
%         if n > 0
%             cnt = cnt + 1;
%             nrows = floor(sqrt(n));
%             ncols = ceil(n / nrows);
%             
%             figure
%             for ii = 1:n
%                 subplot(nrows,ncols,ii)
%                 imagesc(reshape_image(images(:, labelIndices(arr(ii))), 0, false));
%                 axis off
%                 title(num2str(arr(ii)))
%             end
%             set(gcf,'name',num2str([dim0-1, dim1-1]),'numbertitle','off')
%         end
%     end
% end
% disp([num2str(cnt), ' types detected.'])

return

% Show point cloud and image
figure
subplot(1,2,1)
scatter(point_cloud(:,1), sidelength - point_cloud(:,2))
axis([0 sidelength 0 sidelength])
subplot(1,2,2)
imagesc(img)
