clc;clear;
close all;
%% Load files
% Generate filter angle ('T') by field location ('XY') image arrays for:
% Both imaging channels
% Negative (XY1-8) and positive (XY9-16) controls

folder = 'Images/';
sample = 'rotation_processed_';
for i = 1:9
    for j = 1:8
        if j+8 > 9
            spacer = '';
        else
            spacer = '0';
        end
        neg_ch1{i,j} = imread([folder sample 'T' num2str(i) '_XY0' num2str(j) '_C1.tif']);
        neg_ch2{i,j} = imread([folder sample 'T' num2str(i) '_XY0' num2str(j) '_C2.tif']);
        pos_ch1{i,j} = imread([folder sample 'T' num2str(i) '_XY' spacer num2str(j+8) '_C1.tif']);
        pos_ch2{i,j} = imread([folder sample 'T' num2str(i) '_XY' spacer num2str(j+8) '_C2.tif']);
        
        %Trim edges
        neg_ch1{i,j} = neg_ch1{i,j}(20:1000,20:480);
        neg_ch2{i,j} = neg_ch2{i,j}(20:1000,20:480);
        pos_ch1{i,j} = pos_ch1{i,j}(20:1000,20:480);
        pos_ch2{i,j} = pos_ch2{i,j}(20:1000,20:480);
    end
end

%% Obtain fluorescence totals

neg_ch1_sum = [];
neg_ch2_sum = [];
pos_ch1_sum = [];
pos_ch2_sum = [];
for j = 1:8
    neg_ch1_sum_hold = [];
    neg_ch2_sum_hold = [];
    pos_ch1_sum_hold = [];
    pos_ch2_sum_hold = [];

    % Image minus background (full image median). Fluorescent cells contribute to the
    % whole-image pixel intensity sum
    for i = 1:9
        neg_ch1_sum_hold = [neg_ch1_sum_hold; sum(neg_ch1{i,j}(:)-median(neg_ch1{i,j}(:)))];
        neg_ch2_sum_hold = [neg_ch2_sum_hold; sum(neg_ch2{i,j}(:)-median(neg_ch2{i,j}(:)))];
        pos_ch1_sum_hold = [pos_ch1_sum_hold; sum(pos_ch1{i,j}(:)-median(pos_ch1{i,j}(:)))];
        pos_ch2_sum_hold = [pos_ch2_sum_hold; sum(pos_ch2{i,j}(:)-median(pos_ch2{i,j}(:)))];
    end
    neg_ch1_sum = [neg_ch1_sum neg_ch1_sum_hold];
    neg_ch2_sum = [neg_ch2_sum neg_ch2_sum_hold];
    pos_ch1_sum = [pos_ch1_sum pos_ch1_sum_hold];
    pos_ch2_sum = [pos_ch2_sum pos_ch2_sum_hold];
end

%% Processing

angles = [0:22.5:180];

% Normalize filter angle-dependent values within every cell
neg_ch1_norm = neg_ch1_sum./mean(neg_ch1_sum);
neg_ch2_norm = neg_ch2_sum./mean(neg_ch2_sum);
pos_ch1_norm = pos_ch1_sum./mean(pos_ch1_sum);
pos_ch2_norm = pos_ch2_sum./mean(pos_ch2_sum);
%Combine all samples for Ch1 and Ch2 separately
all_ch1 = [neg_ch1_norm pos_ch1_norm];
all_ch2 = [neg_ch2_norm pos_ch2_norm];

% Correct photobleaching (2nd order polynomial, heavy weighting on first and last values
% First and last values should be equal (180 degree rotation) so any difference is from photobleaching
w = 60;
fitobj1 = fit([1:9]',median(all_ch1')','poly2','Weights',[w ones(1,7) w]);
fitobj2 = fit([1:9]',median(all_ch2')','poly2','Weights',[w ones(1,7) w]);
for i = 1:9
    all_ch1(i,:) = all_ch1(i,:) - fitobj1(i);
    all_ch2(i,:) = all_ch2(i,:) - fitobj2(i);
end
% Fit sine wave
fitobj1 = fit(angles',median(all_ch1')','SmoothingSpline');
fitobj2 = fit(angles',median(all_ch2')','SmoothingSpline');
%% Plotting

c1 = [255 194 10]/255;
c2 = [12 123 220]/255;

x = 0:1:180;
y1 = fitobj1(x);
y2 = fitobj2(x);
rng('default')
xvar = 1*normrnd(0,1,[1,length(all_ch1)]);

figure('Units', 'inches', 'Position', [0 0 5 5]);hold on;
scatter([find(y1==min(y1)) find(y1==max(y1))],[min(y1) max(y1)],50,'k','^','MarkerFaceColor',c1)
scatter([find(y2==min(y2)) find(y2==max(y2))],[min(y2) max(y2)],50,'k','v','MarkerFaceColor',c2)
legend('Filter 1', ...
        'Filter 2', ...
        'Location', 'NorthWest', 'AutoUpdate', 'off', 'FontSize',16, 'FontName', 'Arial')

for i = 1:9
    scatter(xvar+angles(i),all_ch1(i,:),15,'^','MarkerEdgeColor','none','MarkerFaceColor',c1,'MarkerFaceAlpha',.5)
end
plot(x,y1,'Color','k','LineWidth',1)
scatter([find(y1==min(y1)) find(y1==max(y1))],[min(y1) max(y1)],50,'k','^','MarkerFaceColor',c1)
set(gca,'FontSize',16,'FontName','Arial','LineWidth',2,'XTick',[0:45:180],'YTick',[-.15:.05:.15]);
xlim([0 180]);ylim([-.15 .15]);
grid on;box on;pbaspect([1 1 1])
ylabel('Normalized cellular fluorescence (a.u.)','FontSize',16,'FontName','Arial')
xlabel('Filter angle (degrees)','FontSize',16,'FontName','Arial')

for i = 1:9
    scatter(xvar+angles(i),all_ch2(i,:),15,'^','MarkerEdgeColor','none','MarkerFaceColor',c2,'MarkerFaceAlpha',.5)
end
plot(x,y2,'Color','k','LineWidth',1)
scatter([find(y2==min(y2)) find(y2==max(y2))],[min(y2) max(y2)],50,'k','v','MarkerFaceColor',c2)
set(gca,'FontSize',16,'FontName','Arial','LineWidth',2,'XTick',[0:45:180],'YTick',[-.15:.05:.15]);
xlim([0 180]);ylim([-.15 .15]);
grid on;box on;pbaspect([1 1 1])
ylabel('Normalized cellular fluorescence (a.u.)','FontSize',16,'FontName','Arial')
xlabel('Filter angle (degrees)','FontSize',16,'FontName','Arial')