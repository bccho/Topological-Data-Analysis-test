%% Load images
if (~exist('images', 'var'))
    images = loadMNISTImages('train-images-idx3-ubyte');
end
if (~exist('labels', 'var'))
    labels = loadMNISTLabels('train-labels-idx1-ubyte');
end

disp('Loaded images')

n = 1000;
images = images(:, 1:n);
labels = labels(1:n);
[sortedLabels, labelIndices] = sort(labels);

% Look at 2's:
labelIndices = labelIndices(sortedLabels == 2);
ind = 1;

%% Compute Betti intervals:

img = reshape_image(images(:, labelIndices(ind)), 0, false);
intervals = BC_compute_intervals(img, 3, 10, 50, 1, 0.2, 4, 10000);

intervals_dim0 = edu.stanford.math.plex4.homology.barcodes.BarcodeUtility.getEndpoints(intervals, 0, 0);
intervals_dim0_nt = intervals_dim0;
if (~isempty(intervals_dim0)) % filter noise
    intervals_dim0_nt = intervals_dim0(intervals_dim0(:,2) >= 2, :);
end
intervals_dim1 = edu.stanford.math.plex4.homology.barcodes.BarcodeUtility.getEndpoints(intervals, 1, 0);
intervals_dim1_nt = intervals_dim1;
if (~isempty(intervals_dim1))
    intervals_dim1_nt = intervals_dim1(intervals_dim1(:,2) >= 1, :);
end
intervals_dim2 = edu.stanford.math.plex4.homology.barcodes.BarcodeUtility.getEndpoints(intervals, 2, 0);
intervals_dim2_nt = intervals_dim2;
if (~isempty(intervals_dim2))
    intervals_dim2_nt = intervals_dim2(intervals_dim2(:,2) >= 1, :);
end

% Display results
disp(['Dim 0: ', num2str(size(intervals_dim0,1)), '; really ', num2str(size(intervals_dim0_nt,1))])
disp(['Dim 1: ', num2str(size(intervals_dim1,1)), '; really ', num2str(size(intervals_dim1_nt,1))])
disp(['Dim 2: ', num2str(size(intervals_dim2,1)), '; really ', num2str(size(intervals_dim2_nt,1))])

% stream = api.Plex4.createVietorisRipsStream(point_cloud, max_dimension, max_filtration_value, num_divisions);
% disp('Created Vietoris-Rips stream:'), disp(stream.getSize())
% persistence = api.Plex4.getModularSimplicialAlgorithm(max_dimension, 2);
% intervals = persistence.computeIntervals(stream);
% disp('Computed intervals')

% options.filename = 'lazyTwos';
% options.max_filtration_value = max_filtration_value;
% options.min_dimension = 1;
% options.max_dimension = max_dimension - 1;
% plot_barcodes(intervals, options);

% Show point cloud and image
figure
subplot(1,2,1)
scatter(point_cloud(:,1), 28 - point_cloud(:,2))
subplot(1,2,2)
imagesc(img)