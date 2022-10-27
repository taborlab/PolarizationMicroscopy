clc;clear;
close all;
%% Load files
% Generate by field location ('XY') image arrays for:
% Both imaging channels
% Negative (XY1-8) and positive (XY9-16) controls

folder = 'Images/';
sample = 'final_processed';
for j = 1:8
    if j+8 > 9
        spacer = '';
    else
        spacer = '0';
    end
    neg_ch1{j} = imread([folder sample '_XY0' num2str(j) '_C1.tif']);
    neg_ch2{j} = imread([folder sample '_XY0' num2str(j) '_C2.tif']);
    pos_ch1{j} = imread([folder sample '_XY' spacer num2str(j+8) '_C1.tif']);
    pos_ch2{j} = imread([folder sample '_XY' spacer num2str(j+8) '_C2.tif']);

    %Trim edges
    neg_ch1{j} = neg_ch1{j}(20:1000,20:480);
    neg_ch2{j} = neg_ch2{j}(20:1000,20:480);
    pos_ch1{j} = pos_ch1{j}(20:1000,20:480);
    pos_ch2{j} = pos_ch2{j}(20:1000,20:480);
end

%% Obtain fluorescence totals

neg_ch1_sum = [];
neg_ch2_sum = [];
pos_ch1_sum = [];
pos_ch2_sum = [];

% Image minus background (full image median). Fluorescent cells contribute to the
% whole-image pixel intensity sum
for j = 1:8
    neg_ch1_sum = [neg_ch1_sum sum(neg_ch1{j}(:)-median(neg_ch1{j}(:)))];
    neg_ch2_sum = [neg_ch2_sum sum(neg_ch2{j}(:)-median(neg_ch2{j}(:)))];
    pos_ch1_sum = [pos_ch1_sum sum(pos_ch1{j}(:)-median(pos_ch1{j}(:)))];
    pos_ch2_sum = [pos_ch2_sum sum(pos_ch2{j}(:)-median(pos_ch2{j}(:)))];
end

% Compute fluorescence anisotropy for negative and positive control
% samples. Here ch1 is perpendicular and ch2 is parallel
r1 = (neg_ch2_sum-neg_ch1_sum)./(neg_ch1_sum+neg_ch2_sum);
r2 = (pos_ch2_sum-pos_ch1_sum)./(pos_ch1_sum+pos_ch2_sum);

%% Plotting

% Plot whole-image polarization values relative to the negative control
close all;
figure('Units', 'inches', 'Position', [0 0 5 5]);hold on;

series1 = -[median(r1); median(r2)]+median(r1);
series1error = [std(r1) std(r2)];
labels = {'mNG','mNG-mNG'};

c1 = [0 176 80]/255; c2 = [.6 .6 .6];c3 = [0 0 0];
b1 = bar(series1,0.5,'FaceColor',c1,'EdgeColor',c3,'LineWidth',1,'BaseValue',0);

nbars = size(series1, 2);
x = [];
for i = 1:nbars
    x = [x ; b1(i).XEndPoints];
end
errorbar(x',series1,series1error,'k','linestyle','none','LineWidth',1,'CapSize',5)

rng('default')
xvar = .04*normrnd(0,1,[1,8]);
scatter(xvar+1,-r1+median(r1),'k','MarkerFaceColor','w')
scatter(xvar+2,-r2+median(r1),'k','MarkerFaceColor','w')

pbaspect([1,1,1]);
set(gca, 'YGrid', 'on', 'XGrid', 'off'); box on;
set(gca,'LineWidth',2,'FontSize',16,'FontName','Arial')
ylim([-.01 .04]);
xlim([.25 2.75]);
set(gca, 'XTick', 1:2, 'XTickLabel', labels);
ylabel('-\DeltaFP','FontSize',16,'FontName','Arial')