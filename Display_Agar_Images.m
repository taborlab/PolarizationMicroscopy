clc;clear;
close all;
folder = 'Images/';

sample = ['rotation_processed_T1_XY03_C1.tif'];
mNG_im = imread([folder sample],1);
mNG_im = mNG_im(310:710,50:450);
mNG_im(1,1) = 0; mNG_im(1,2) = 65536;

I = medfilt2(mNG_im,[3,3]);
[m n] = size(I);
figure('Units', 'inches', 'Position', [0 0 5.0 5.0]);imshow(I,'Border','tight')
annotation('line','Units','Normalized','Position',[.025 .90 .1923 0],'Color','w','LineWidth',2)
text(25,20,'10 \mum','Color','w','FontName','Arial','FontSize',16)
caxis([500 3000])
