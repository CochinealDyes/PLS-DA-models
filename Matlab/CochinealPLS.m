function [Xcal Xtest] = CochinealPLS()
%This function is used to import and preprocess cochineal chromatographic
%data in order to make a PLS model using the eigenvector PLS toolbox. A
%tutorial in word explains how to do this. Please refer to the word
%tutorial if anything is unclear.

%Created 2016 by Ana Serrano and André van den Doel


%Parameters

%selection of chromatographic regions for alignment (it can be convenient to select a larger part of the spectrum for alginment than for analysis, because the boundaries are fixed and this way peaks at the edges of the region of interest can also be shifted):
RT1=13; 
RT2=24; 

%selection of chromatographic regions for PLSDA analysis (regions that contain all peaks of interest):
RTfinal={14.5,17.5,20.5,24}; %Make sure that there is an even number of boundaries, because the regions between 1st and 2nd element, 3rd and 4th element, etc. are selected. So in this case between 14.5 and 17.5 minutes and between 20.5 and 24 minutes).

%Correlation optimized warping parameters:
RefSample=498; %Sample number of the calibration sample that you want to use as a reference for alignment (if you use multiple input files, the samples are concatenated and you may need to add the number of samples in previous files (e.g. if you want to select the 12th sample of the 2nd file and the first file contains 70 samples, then the sample number is 82).
Seg=16;
Slack=9;

%ALS baseline correction parameters:
lambda=1e7; %Default 1e7
p=0.005; %Default 0.005







%% Load data
CurrFolder=pwd;


%calibration data
disp('Select file(s) containing calibration samples');
[FILENAMEc, PATHNAMEc] = uigetfile([CurrFolder '\*.xlsx'],'MultiSelect','on');
if ~iscell(FILENAMEc)
    FILENAMEc={FILENAMEc};
end

%test data
disp('Select file(s) containing test samples');
[FILENAMEt, PATHNAMEt] = uigetfile([CurrFolder '\*.xlsx'],'MultiSelect','on');
if ~iscell(FILENAMEt)
    FILENAMEt={FILENAMEt};
end

%calibration data
Xcal=[];
labels_cal=[];
for i=1:length(FILENAMEc)
    X=xlsread([PATHNAMEc '\' FILENAMEc{i}],'Chromatograms'); %import cochineal data
    X=X(4:end,:);
    X(isnan(X))=0; %change empty cells to 0
    if i==1
        RTcal=X(:,1)';
    end
    Xcal=[Xcal; X(:,2:end)'];
    labels=xlsread([PATHNAMEc '\' FILENAMEc{i}],'Labels');
    labels_cal=[labels_cal ; labels(:,end)];
end
nCal=size(Xcal,1);

%test data
Xtest=[];
for i=1:length(FILENAMEt)
    X=xlsread([PATHNAMEt '\' FILENAMEt{i}],'Chromatograms'); %import cochineal data
    X=X(4:end,:);
    X(isnan(X))=0; %change empty cells to 0
    if i==1
        RTtest=X(:,1)';
    end
    Xtest=[Xtest; X(:,2:end)'];
end
nTest=size(Xtest,1);




%% select a region of the chromatogram
idx1=find(RTcal>RT1,1); 
idx2=find(RTcal>RT2,1);
Xcal_regions=Xcal(:,idx1:idx2);
RTcal_regions=RTcal(idx1:idx2);

idx1=find(RTtest>RT1,1); 
idx2=find(RTtest>RT2,1);
Xtest_regions=Xtest(:,idx1:idx2);
% RTtest_regions=RTtest(idx1:idx2);

Xregions=[Xcal_regions;Xtest_regions];


%% alginment using correlation optimized warping

Xref=Xregions(RefSample,:);
cd('Warping')
    [~,XWarped_cal,~] = cow(Xref,[Xref; Xregions(1:nTest,:)],Seg,Slack,[1 1 0 0 0]);
    [~,XWarped_test,~] = cow(Xref,[Xref; Xregions(nTest+1:end,:)],Seg,Slack,[1 1 0 0 0]);
    XWarped=[XWarped_cal(2:end,:);XWarped_test(2:end,:)];
cd(CurrFolder)



%Plot original spectra
figure('name','Original spectra')
hold on
A=hsv(size(Xregions,1));
for i=1:size(Xregions,1)
    plot(RTcal_regions,Xregions(i,:),'color',A(i,:))
end

%Plot warped spectra
figure('name','Aligned spectra')
hold on
A=hsv(nCal);
for i=1:nCal
    plot(RTcal_regions,XWarped(i,:),'color',A(i,:))
end
for i=nCal+1:size(XWarped,1)
    plot(RTcal_regions,XWarped(i,:),'color','k')
end




%% baseline correction
for i=1:size(XWarped,1)
    [z] = baselineALS(XWarped(i,:)', lambda,p);
    Xbaseline(i,:)=XWarped(i,:)-z';
end

%plot baseline corrected spectra
figure('name','Baseline corrected spectra')
hold on
A=hsv(size(Xbaseline,1));
for i=1:size(Xbaseline,1)
    plot(RTcal_regions,Xbaseline(i,:),'color',A(i,:))
end



%% Final select region of chromatogram

idx=cell(size(RTfinal));
for i=1:size(RTfinal,2)
    idx{i}=find(RTcal_regions>RTfinal{i},1); 
end

Xnew=[];
RTnew=[];
for i=1:2:size(RTfinal,2)-1
    Xnew=[Xnew Xbaseline(:,[idx{i}:idx{i+1}])];
    RTnew=[RTnew RTcal_regions([idx{i}:idx{i+1}])];
end



%% Standard normal variate scaling:
[Xscaled] = SNV(Xnew);


%% meancenter

% split model data (bugs and aged samples) and data you want to predict
Xcal=Xscaled(1:nCal,:); %bugs/nonaged and aged samples
Xtest=Xscaled(nCal+1:end,:); %historical samples

Xcal=bsxfun(@minus,Xcal,mean(Xcal)); %mean center all variables
Xtest=bsxfun(@minus,Xtest,mean(Xtest)); %mean center all variables

%add labels to calibration data for easier use in PLS toolbox
Xcal=[labels_cal Xcal];




end

