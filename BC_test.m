clc

%% Load images and 'sort' by numeral
if (~exist('images', 'var'))
    images = loadMNISTImages('train-images-idx3-ubyte');
end
if (~exist('labels', 'var'))
    labels = loadMNISTLabels('train-labels-idx1-ubyte');
end

% Save memory
n = 1000;
images = images(:, 1:n);
labels = labels(1:n);
sidelength = 28;

% Look at only particular numerals
[sortedLabels, labelIndices] = sort(labels);
labelIndices = labelIndices(sortedLabels == 2);
ind = 1;

%% Compute Betti intervals
img = reshape_image(images(:, labelIndices(ind)), 0, false);
[intervals, point_cloud] = BC_compute_intervals(img, 2, 10, 100, 1, 0.5, 4, 10000, false);

%% Filter relevant intervals
intervals_dim0 = BC_filter_relevant_intervals(intervals, 0);
intervals_dim1 = BC_filter_relevant_intervals(intervals, 1);
betti_numbers = [intervals_dim0.size, intervals_dim1.size];

%% Display results

return
% Show point cloud and image
figure
subplot(1,2,1)
scatter(point_cloud(:,1), sidelength - point_cloud(:,2))
axis([0 sidelength 0 sidelength])
subplot(1,2,2)
imagesc(img)