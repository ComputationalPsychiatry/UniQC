% clear; close all; clc;
% generate image with random noise (1%)
m = MrImage(randn(51,51,5,200)+1);

doPlotRoi = false;

% make ROIs
for n = 1:20
    m_roi{n} = MrImage(zeros(m.dimInfo.nSamples(1:3)));
    m_roi{n}.data(27-n:25+n, 27-n:25+n, 3) = 1;
    if doPlotRoi
        m_roi{n}.plot;
    end
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

% rescale for different noise variance
% CV(21:40) = CV(21:40)*std(m.rois{1}.perVolume.mean)/std(m.rois{21}.perVolume.mean);

%% plot results
figure; plot(1:20, CV(1:20), 1:20, CV(21:40));
legend('random', 'smoothed');
fh = figure; plot(log10(1:20), log10(100*CV(1:20)), log10(1:20), log10(100*CV(21:40)));
legend('random', 'smoothed');
fh = figure; loglog(1:20, 100*CV(1:20), 1:20, 100*CV(21:40));
fh.CurrentAxes.XTick = [1 10 100];
fh.CurrentAxes.YTick = [0.01 0.1 1 10];
legend('random', 'smoothed');