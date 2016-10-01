function CochinealProjections()
%Project test samples onto PLS model of training samples

%% define plot symbols and colors, legend and strict or most probable classfication.

%symbols and colors
symc={'s','d','^','p','s','^','d','p'}; %symbols of calibration samples. For colour and symbol options type 'help plot' in the matlab command window.
colc={'r','r','r','r','r','r','r','r'}; %colors of calibration samples


symt={'s','d','^','p','s','^','d','p'}; %symbols of test samples
colt={'b','b','b','b','b','b','b','b'}; %colors of test samples

%legend
lgnd={'class 1','class 2','class 3','class 4','class 5','class 6','class 7','class 8'};

%select classifcation method (strict or most probable)
pred='prob'; %options: 'strict' or 'prob' . 






%% load data

CurrFolder=pwd;

disp('Select file containing calibration scores and predictions');
[FILENAMEc, PATHNAMEc] = uigetfile([CurrFolder '\*.csv']);

disp('Select file containing test scores and predictions');
[FILENAMEt, PATHNAMEt] = uigetfile([CurrFolder '\*.csv']);


[~,Cal_txt,Cal_raw]=xlsread([PATHNAMEc '\' FILENAMEc]);
[~,Test_txt,Test_raw]=xlsread([PATHNAMEt '\' FILENAMEt]);


%% extract labels, predictions and scores

[Cal_classr, Cal_classc]=find(strcmp('Class Measured',Cal_raw)); %find the column with class labels of the calibration samples.
Cal_classes=Cal_raw(Cal_classr+1:end,Cal_classc);
Cal_classes=cell2mat(Cal_classes);

[Test_classr, Test_classc]=find(strcmp('Class Pred Strict',Test_raw)); %find the column with class labels of the calibration samples.
Test_classes_strict=Test_raw(Test_classr+1:end,Test_classc);
Test_classes_strict=cell2mat(Test_classes_strict);

[Test_classr, Test_classc]=find(strcmp('Class Pred Most Probable',Test_raw)); %find the column with class labels of the calibration samples.
Test_classes_prob=Test_raw(Test_classr+1:end,Test_classc);
Test_classes_prob=cell2mat(Test_classes_prob);

%extract scores of calibration samples
Tcal_idx=regexp(Cal_txt,'Scores on LV');
Tcal_idx=cellfun(@isempty,Tcal_idx);
[Tcalr, Tcalc]=find(~Tcal_idx);
Tcalr=Tcalr(1);
Tcal=Cal_raw(Tcalr+1:end,Tcalc);
Tcal=cell2mat(Tcal);

%extract scores of test samples
Ttest_idx=regexp(Test_txt,'Scores on LV');
Ttest_idx=cellfun(@isempty,Ttest_idx);
[Ttestr, Ttestc]=find(~Ttest_idx);
Ttestr=Ttestr(1);
Ttest=Test_raw(Ttestr+1:end,Ttestc);
Ttest=cell2mat(Ttest);

nPC=length(Tcalc);

VarExp=cell(1,nPC);
%extract variance explained per PC
for i=1:length(Tcalc)
    Var=Cal_raw{Tcalr,Tcalc(i)};
    Var=strsplit(Var,{'(','%'});
    VarExp{i}=Var{2};
end
    
    
%% plot projections    


for i=1:nPC-1
    for j=i+1:nPC
        
        %without test sample IDs
        figure('name',['Projections LV' num2str(i) ' vs LV' num2str(j)])
        hold on

        for k=unique(Cal_classes)'
            idx=Cal_classes==k;
            plot(Tcal(idx,i),Tcal(idx,j),'Marker',symc{k},'Color',colc{k},'LineStyle','none')
        end
        legend(lgnd)
        
             
        if strcmp(pred,'prob')
            for k=unique(Test_classes_prob)'
                idx=Test_classes_prob==k;
                plot(Ttest(idx,i),Ttest(idx,j)','Marker',symt{k},'Color',colt{k},'LineStyle','none','MarkerFaceColor',colt{k})
            end
        else
            for k=unique(Test_classes_strict)'
                if k~=0
                    idx=Test_classes_strict==k;
                    plot(Ttest(idx,i),Ttest(idx,j)','Marker',symt{k},'Color',colt{k},'LineStyle','none','MarkerFaceColor',colt{k})
                end
            end
        end
        
        xlabel(['LV ' num2str(i) ' (' VarExp{i} '%)'])
        ylabel(['LV ' num2str(j) ' (' VarExp{j} '%)'])
        
        
        
        %with test sample IDs
        figure('name',['Projections LV' num2str(i) ' vs LV' num2str(j)])
        hold on

        for k=unique(Cal_classes)'
            idx=Cal_classes==k;
            plot(Tcal(idx,i),Tcal(idx,j),'Marker',symc{k},'Color',colc{k},'LineStyle','none')
        end
        legend(lgnd)
        
             
        if strcmp(pred,'prob')
            for k=unique(Test_classes_prob)'
                idx=Test_classes_prob==k;
                plot(Ttest(idx,i),Ttest(idx,j)','Marker',symt{k},'Color',colt{k},'LineStyle','none','MarkerFaceColor',colt{k})
            end
        else
            for k=unique(Test_classes_strict)'
                if k~=0
                    idx=Test_classes_strict==k;
                    plot(Ttest(idx,i),Ttest(idx,j)','Marker',symt{k},'Color',colt{k},'LineStyle','none','MarkerFaceColor',colt{k})
                end
            end
        end
        
        if strcmp(pred,'prob')
            for k=1:size(Ttest,1)
                text(Ttest(k,i)+0.2,Ttest(k,j),num2str(k))
            end
        elseif strcmp(pred,'strict')
            for k=1:size(Ttest,1)
                if Test_classes_strict(k)~=0
                    text(Ttest(k,i)+0.2,Ttest(k,j),num2str(k))
                end
            end
        end
        
        xlabel(['LV ' num2str(i) ' (' VarExp{i} '%)'])
        ylabel(['LV ' num2str(j) ' (' VarExp{j} '%)'])
        
        
    end
end





