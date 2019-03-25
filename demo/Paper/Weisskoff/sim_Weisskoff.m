clear; close all; clc;
% generate image with random noise (0.1%)
m = MrImage(rand(51,51,5,200)+1000);

% make ROIs
for n = 1:20
    m_roi{n} = MrImage(zeros(m.dimInfo.nSamples(1:3)));
    m_roi{n}.data(27-n:25+n, 27-n:25+n, 2:4) = 1;
    m_roi{n}.plot;
end

% extract data
m.extract_rois(m_roi);
m = m.smooth(3);
m.extract_rois(m_roi);
m.compute_roi_stats();

% compute coefficient of variation (CV)
for n = 1:40
    CV(n) = std(m.rois{n}.perVolume.mean)/mean(m.rois{n}.perVolume.mean);
end

% plot results
figure; plot(1:20, CV(1:20), 1:20, CV(21:40));
legend('random', 'smoothed');
fh = figure; plot(log10(1:20), log10(CV(1:20)), log10(1:20), log10(CV(21:40)));
legend('random', 'smoothed');