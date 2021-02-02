clc
close all
clear all

% Input Image
[I,path]=uigetfile('*.jpg','select a input image');
str=strcat(path,I);
s=imread(str);

figure;
imshow(s);
title('Input image','FontSize',25);

%%%ANISOTROPIC DIFFUSION FILTERING Parameters%%%
% k= kappa controls conduction as a function of gradient.  If kappa is low small intensity gradients are able to block conduction and hence diffusion
% across step edges.  A large value reduces the influence of intensity gradients on conduction.
% delta t controls speed of diffusion (you usually want it at a maximum of 0.25)
% step is used to scale the gradients in case the spacing between adjacent pixels differs in the x,y and/or z axes
%Diffusion equation 1 favours high contrast edges over low contrast ones.
%Diffusion equation 2 favours wide regions over smaller ones.

%%Filtering
num_iter = 20;
    dt = 1/5; %delta t[maximum shoud be 0.25 for stability]
    k = 15; %kappa
    o = 1; %option
    disp('Preprocessing . . .');
    inp = anisodiff(s,num_iter,dt,k,o);
    inp = uint8(inp);
    
inp=imresize(inp,[256,256]);
if size(inp,3)>1
    inp=rgb2gray(inp);
end

sout=imresize(inp,[256,256]);
t0=80;
th=t0+((max(inp(:))+min(inp(:)))./2);
for i=1:1:size(inp,1)
    for j=1:1:size(inp,2)
        if inp(i,j)>th
            sout(i,j)=1;
        else
            sout(i,j)=0;
        end
    end
end

%% Morphological Operation

label=bwlabel(sout);
stats=regionprops(logical(sout),'Solidity','Area','BoundingBox');
density=[stats.Solidity];
area=[stats.Area];
high_dense_area=density>0.6;
max_area=max(area(high_dense_area));
tumor_label=find(area==max_area);
tumor=ismember(label,tumor_label);

if max_area>100

else
    h = msgbox('No Tumor!!','status');
    disp('no tumor');
    return;
end
            
%% Tumor indicated by Bounding box

box = stats(tumor_label);
wantedBox = box.BoundingBox;


%% All Shown Together

figure
subplot(221);imshow(s);title('Input image','FontSize',20);
subplot(222);imshow(inp);title('Filtered image','FontSize',20);

subplot(223);imshow(inp);title('Bounding Box','FontSize',20);
hold on;rectangle('Position',wantedBox,'EdgeColor','r');hold off;

subplot(224);imshow(tumor);title('tumor alone','FontSize',20);

