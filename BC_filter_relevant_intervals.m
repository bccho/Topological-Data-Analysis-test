function [relevant_intervals] = BC_filter_relevant_intervals(intervals, dimension)
%BC_filter_relevant_intervals Returns significant or relevant intervals
%given a list of intervals
%   Detailed explanation goes here

import edu.stanford.math.plex4.*;

minimum_length = 1;
temp_intervals = intervals.getIntervalsAtDimension(dimension);
relevant_intervals = homology.barcodes.BarcodeUtility.filterIntervalsByMinimumLength(temp_intervals, minimum_length);

end

