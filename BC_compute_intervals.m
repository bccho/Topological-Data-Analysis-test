function [intervals, point_cloud] = BC_compute_intervals(image, max_dimension, num_divisions, num_landmark_points, nu, threshold, init_MFV, max_stream_size, show_messages)
%BC_compute_intervals Computes Betti intervals given an image
%   Default values:
%       max_dimension = 3
%       num_divisions = 10
%       num_landmark_points = 50
%       nu = 1
%       threshold = 0.5
%       init_MFV = 6
%       max_stream_size = 10000
%       show_messages = false

import edu.stanford.math.plex4.*;

%% Default parameter values
if ~exist('max_dimension', 'var') || isempty(max_dimension)
    max_dimension = 3;
end

if ~exist('num_divisions', 'var') || isempty(num_divisions)
    num_divisions = 10;
end

if ~exist('num_landmark_points', 'var') || isempty(num_landmark_points)
    num_landmark_points = 50;
end

if ~exist('nu', 'var') || isempty(nu)
    nu = 1;
end

if ~exist('threshold', 'var') || isempty(threshold)
    threshold = 0.5;
end

if ~exist('init_MFV', 'var') || isempty(init_MFV)
    init_MFV = 6;
end

if ~exist('max_stream_size', 'var') || isempty(max_stream_size)
    max_stream_size = 10000;
end

if ~exist('show_messages', 'var') || isempty(show_messages)
    show_messages = false;
end

%% Prepare point cloud
[row,col] = find(image > threshold); % threshold image
point_cloud = [col, row];
if show_messages
    disp('Computed point cloud:'), disp(size(point_cloud))
end

%% Set up for lazy witness stream: sequential min/max landmark selection
num_landmark_points = min(num_landmark_points, size(point_cloud,1));
landmark_selector = api.Plex4.createMaxMinSelector(point_cloud, num_landmark_points);
R = landmark_selector.getMaxDistanceFromPointsToLandmarks();
if show_messages
    disp('Selected landmark points:');
    disp(R)
end
max_filtration_value = init_MFV;

%% Set up stream
stream = streams.impl.LazyWitnessStream(landmark_selector.getUnderlyingMetricSpace(), landmark_selector, max_dimension, max_filtration_value, nu, num_divisions);
stream.finalizeStream()
if show_messages
    disp('Created lazy witness stream:'), disp(stream.getSize())
end

% Modify max filtration value until it becomes reasonable
while (stream.getSize() > max_stream_size)
    max_filtration_value = max_filtration_value * 0.9;
    stream = streams.impl.LazyWitnessStream(landmark_selector.getUnderlyingMetricSpace(), landmark_selector, max_dimension, max_filtration_value, nu, num_divisions);
    stream.finalizeStream()
    if show_messages
        disp(['Created lazy witness stream: MFV = ', num2str(max_filtration_value)]), disp(stream.getSize())
    end
end

%% Compute intervals
persistence = api.Plex4.getModularSimplicialAlgorithm(max_dimension, 2);
intervals = persistence.computeIntervals(stream);

end

