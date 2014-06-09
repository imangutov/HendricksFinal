function out = ols_gmm(Y,X,lags)
%
% olsRobust.m
% calculate OLS test stats adjusted for heteroskedasticity and serial correlation
% automatically adds a column of 1's to regressors
%
% Y. Column of observations
% X. n by k matrix of regressors---NOT including column of ones
% LAGS. Number of lags used in Newey-West correction
% OUT. Structure of output variables.


%%% Default arguments
if nargin<3
    lags = 12;
end






%% OLS Estimation

[n,k] = size(X);
X1 = [ones(n,1),X];


out.b = (X1'*X1)\(X1'*Y);
resids = Y - X1*out.b;


sigma2_epsilon = mean(resids.^2);
devs_y = Y - ones(n,1)*mean(Y);
sigma2_y = mean(devs_y.^2);

out.R2 = (1-sigma2_epsilon./sigma2_y)';






%% Heteroskedasticity-adjusted X*Sigma*X

XSigmaX_het = 0;
for ii=1:n
    XSigmaX_het = XSigmaX_het + resids(ii)^2* X1(ii,:)'*X1(ii,:);
end





%% Adjust XSigmaX for serial corr using Newey-West weighting

XSigmaX_ser = 0;

    for ll=1:lags
        weight = 1 - (ll/(lags+1));
        for jj= ll+1:n
            XSigmaX_ser = XSigmaX_ser + weight * resids(jj)*resids(jj-ll) * ...
                (X1(jj,:)'*X1(jj-ll,:) + X1(jj-ll,:)'*X1(jj,:));
        end
    end




%% Save results

% classic OLS inference (for comparison)
out.classic.varb = (X1'*X1)\(eye(k+1)*(resids'*resids)/(n-k-1));
out.classic.seb = sqrt(diag(out.classic.varb));
out.classic.tstat = out.b ./ out.classic.seb;
out.classic.pval = 2*(1 - cdf('t',abs(out.classic.tstat),n-k-1));

% GMM robust standard errors and inference
out.gmm.varb = ((X1'*X1)\(XSigmaX_het + XSigmaX_ser))/(X1'*X1);
out.gmm.seb = sqrt(diag(out.gmm.varb));
out.gmm.tstat = out.b./out.gmm.seb;
out.gmm.pval = 2*(1 - cdf('t',abs(out.gmm.tstat),n-k-1));
    

