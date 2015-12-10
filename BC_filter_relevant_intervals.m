function [relevant_endpoints] = BC_filter_relevant_intervals(intervals, dimension, latest_formation, earliest_extinction)
%BC_filter_relevant_intervals Returns significant or relevant intervals
%given a list of intervals
%   Filters intervals by:
%       latest_formation    = upper bound for left endpoint (cannot form
%                             later than this)
%       earliest_extinction = lower bound for right endpoint (cannot end
%                             earlier than this)

import edu.stanford.math.plex4.*;

%% Get endpoints
endpoints = edu.stanford.math.plex4.homology.barcodes.BarcodeUtility.getEndpoints(intervals, dimension, false);

%% Concatenate endpoints
ii = 1;
while ii < size(endpoints, 1)
    row = endpoints(ii, :);
    
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
    relevant_endpoints = endpoints((endpoints(:,2) >= earliest_extinction) & (endpoints(:,1) <= latest_formation), :);
else
    relevant_endpoints = endpoints;
end

end

