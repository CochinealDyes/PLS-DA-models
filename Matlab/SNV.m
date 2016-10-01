function [X] = SNV(X)
%SNV applies standard normal variate scaling on matrix X (rows: samples,
%columns: variables). (Like autoscaling but sample wise instead of variable
%wise)

X=X';

%mean centering
X=bsxfun(@minus,X,mean(X)); %subtract column wise mean from every element (on transposed matrix, so row wise)

%column wise scaling (on transposed matrix, so actually row wise :).
X=bsxfun(@rdivide,X,std(X)); %divide by standard deviation

X=X';


end

