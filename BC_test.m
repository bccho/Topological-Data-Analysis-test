%% Load images and 'sort' by numeral
if (~exist('images', 'var'))
    images = loadMNISTImages('train-images-idx3-ubyte');
end
if (~exist('labels', 'var'))
    labels = loadMNISTLabels('train-labels-idx1-ubyte');
end

n = 1000;
images = images(:, 1:n);
labels = labels(1:n);

ind = 1;

img = reshape_image(images(:, labelIndices(ind)), 0, false);


%% Display results

% Show point cloud and image
figure
subplot(1,2,1)
scatter(point_cloud(:,1), 28 - point_cloud(:,2))
subplot(1,2,2)
imagesc(img)