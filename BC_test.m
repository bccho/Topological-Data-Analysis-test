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
max_dimension = 3;
num_divisions = 10;
num_landmark_points = 50;
nu = 1;

% Prepare point cloud
img = reshape_image(images(:,labelIndices(ind)), 0, false);
[row,col] = find(img > 0.5); % threshold image
point_cloud = [col, row];
disp('Computed point cloud:'), disp(size(point_cloud))

% Set up for lazy witness stream: sequential min/max landmark selection
num_landmark_points = min(num_landmark_points, size(point_cloud,1));
landmark_selector = api.Plex4.createMaxMinSelector(point_cloud, num_landmark_points);
disp('Selected landmark points:');
R = landmark_selector.getMaxDistanceFromPointsToLandmarks();
disp(R)
max_filtration_value = 6; %R * 6;

% Set up stream
stream = streams.impl.LazyWitnessStream(landmark_selector.getUnderlyingMetricSpace(), landmark_selector, max_dimension, max_filtration_value, nu, num_divisions);
stream.finalizeStream()
disp('Created lazy witness stream:'), disp(stream.getSize())

while (stream.getSize() > 10000) % modify filtration value until it becomes reasonable
    max_filtration_value = max_filtration_value * 0.9;
    stream = streams.impl.LazyWitnessStream(landmark_selector.getUnderlyingMetricSpace(), landmark_selector, max_dimension, max_filtration_value, nu, num_divisions);
    stream.finalizeStream()
    disp(['Created lazy witness stream: MFV = ', num2str(max_filtration_value)]), disp(stream.getSize())
end

% Compute intervals
persistence = api.Plex4.getModularSimplicialAlgorithm(max_dimension, 2);
intervals = persistence.computeIntervals(stream);
disp('Computed intervals:')
intervals_dim0 = edu.stanford.math.plex4.homology.barcodes.BarcodeUtility.getEndpoints(intervals, 0, 0);
intervals_dim0_nt = intervals_dim0;
if (~isempty(intervals_dim0)) % filter noise
    intervals_dim0_nt = intervals_dim0(intervals_dim0(:,2) >= 2, :);
end
intervals_dim1 = edu.stanford.math.plex4.homology.barcodes.BarcodeUtility.getEndpoints(intervals, 1, 0);
intervals_dim1_nt = intervals_dim1;
if (~isempty(intervals_dim1))
    intervals_dim1_nt = intervals_dim1(intervals_dim1(:,2) >= 0.5, :);
end
intervals_dim2 = edu.stanford.math.plex4.homology.barcodes.BarcodeUtility.getEndpoints(intervals, 2, 0);
intervals_dim2_nt = intervals_dim2;
if (~isempty(intervals_dim2))
    intervals_dim2_nt = intervals_dim2(intervals_dim2(:,2) >= 0.5, :);
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