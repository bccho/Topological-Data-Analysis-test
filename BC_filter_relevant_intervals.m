function [relevant_endpoints] = BC_filter_relevant_intervals(intervals, dimension, minimum_length)
%BC_filter_relevant_intervals Returns significant or relevant intervals
%given a list of intervals
%   Detailed explanation goes here

import edu.stanford.math.plex4.*;

%% Get endpoints
endpoints = edu.stanford.math.plex4.homology.barcodes.BarcodeUtility.getEndpoints(intervals, dimension, false);

%% Concatenate endpoints
ii = 1;
while ii < size(endpoints, 1)
    row = endpoints(ii, :);
    
    % Skip if right endpoint is infinity
%     if row(2) == Inf
%         ii = ii + 1;
%         continue
%     end
    
    %% Find concatenatable intervals
    % Find the first interval whose left endpoint = this right endpoint
    matchind = find(endpoints((ii+1):end, 1) == row(2), 1);
    if ~isempty(matchind)
        matchrow = endpoints(ii + matchind, :);

        % Union these two intervals and refresh the endpoint list
        endpoints = [ endpoints(1:(ii-1), :);
                      row(1), matchrow(2);
                      endpoints((ii+1):(ii + matchind-1), :);
                      endpoints((ii + matchind+1):end, :) ];
    else
        % Find the first interval whose right endpoint = this left endpoint
        matchind = find(endpoints((ii+1):end, 2) == row(1), 1);
        
        if ~isempty(matchind)
            matchrow = endpoints(ii + matchind, :);
            
            % Union these two intervals and refresh the endpoint list
            endpoints = [ endpoints(1:(ii-1), :);
                          matchrow(1), row(2);
                          endpoints((ii+1):(ii + matchind-1), :);
                          endpoints((ii + matchind+1):end, :) ];
        else
            ii = ii + 1;
            continue
        end
    end
end

%display(endpoints)

%% Filter out small intervals
% if ~isempty(endpoints)
%     relevant_endpoints = endpoints(endpoints(:,2) - endpoints(:,1) >= minimum_length, :);
% else
%     relevant_endpoints = endpoints;
% end

if ~isempty(endpoints)
    relevant_endpoints = endpoints(endpoints(:,2) >= minimum_length, :);
else
    relevant_endpoints = endpoints;
end

end

