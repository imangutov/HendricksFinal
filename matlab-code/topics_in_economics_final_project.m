% Bertrand liechtenstein & Iliar Mangutov & Shanshan Ni & Sean Filipov
% Topics in economics, Final Project

clearvars
% turn "from_mat_file" to false if you want to parse 
% excel files to get data. 
% otherwise it will just download "../data/data.mat" containing data
% previously parsed...
from_mat_file = true;
data = load_data(from_mat_file);

factors = data.factors;
factors_ndx = data.factors_ndx;
assets = data.assets;

asset_data_set = data.asset_data_set;
factor_data_set = data.factor_data_set;
predictor_indices = [factors_ndx.consumer_price; ...
                     factors_ndx.unemployment_rate_monthly_percent; ...
                     factors_ndx.vix_monthly_change;
                     factors_ndx.gdp;
                     factors_ndx.corporate_profits;
                     factors_ndx.divident_yield];

predictor_indices = predictor_indices - 1; % adjustment for timestamp

coefficient_estimates = zeros(size(assets,2)-1,size(predictor_indices,1));

lambdas = zeros(size(predictor_indices,1),1);

% Estimate individually each factor with every secutity
% (lecture 9, slide 5)
%for factor_ndx = 1:size(predictor_indices,1)
%    factor_data = factor_data_set{predictor_indices(factor_ndx)};
%    
%    asset_mean_returns = zeros(size(asset_data_set,2),1);
%    for asset_ndx=1:size(asset_data_set,2)
%        asset_data = asset_data_set{asset_ndx};
%        
%        common_timestamps = intersect(factor_data(:,1), asset_data(:,1));
%        f = get_intersect_array(common_timestamps, factor_data);
%        a = get_intersect_array(common_timestamps, asset_data);
%        asset_mean_returns(asset_ndx) = mean(a);
%        linear_regression_model = LinearModel.fit(f,a);
%        coefficient_estimates(asset_ndx,factor_ndx) = double(linear_regression_model.Coefficients(1,1))';
%    end
%     disp(factor_ndx);
%    lambdas(factor_ndx) = regress(asset_mean_returns,coefficient_estimates(:,factor_ndx));
%end


for asset_ndx=1:size(asset_data_set,2)
    asset_mean_returns(asset_ndx) = mean(asset_data_set{asset_ndx}(:,2));
end

% Report the mean of these 25 absolute value regression residuals
%fprintf('Pricing error absolute mean = %.5f\n',mean(abs(model_implied_risk_premia - asset_mean_returns)));
%
%y_hut = coefficient_estimates*lambdas;
%y = asset_mean_returns; %mean(assets(:,2:32),1)';
%yresid = y_hut - y;
%SSresid = sum(yresid.^2);
%SStotal = (length(y)-1)*var(y);
%R2_FACTOR2 = 1 - SSresid/SStotal;
%fprintf('R^2 mean for macro factor model = %.3f\n',R2_FACTOR2);

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %%  GMM
asset_mean_returns = mean(assets(:,2:end)); % in assets first column is time
gmm_estimates = zeros(size(assets,2)-1, size(predictor_indices,1));
factors_no_date = factors;
factors_no_date(:,1) = [];
for asset_ndx=2:size(assets,2)
    asset = assets(:,asset_ndx);
    out = ols_gmm(asset, factors_no_date, 12);
    gmm_estimates(asset_ndx-1,:) = out.b(2:size(predictor_indices,1)+1);
end

lambdas = gmm_estimates\asset_mean_returns(:);

out1 = ols_gmm(asset_mean_returns', gmm_estimates, 12);

model_implied_risk_premia = gmm_estimates*lambdas;

scatter(model_implied_risk_premia, asset_mean_returns,'MarkerFaceColor','blue');
xlabel('Model-implied risk premium of asset');
ylabel('Actual mean excess return of the asset');
title('Factor Model:Model-implied risk premium vs actual');

% Report the mean of these 25 absolute value regression residuals
fprintf('Pricing error absolute mean = %.5f\n',mean(abs(model_implied_risk_premia - asset_mean_returns')));

y_hut = gmm_estimates*lambdas;
y = asset_mean_returns'; %mean(assets(:,2:32),1)';
yresid = y_hut - y;
SSresid = sum(yresid.^2);
SStotal = (length(y)-1)*var(y);
R2_FACTOR2 = 1 - SSresid/SStotal;
fprintf('SSR = %.3f, SSD = %.3f, R^2 mean for macro factor model = %.3f\n',SSresid, SStotal,  R2_FACTOR2);

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %% Sensetivety
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for asset_ndx = 2:11
    standard_error = std(assets(:,asset_ndx))/sqrt(length(assets(:,asset_ndx)));
    asset_mean_returns(asset_ndx) = asset_mean_returns(asset_ndx) - ...
        standard_error * (binornd(1,0.5)*2-1)/2;  % randomly add or extract S.E.
end
lambdas_for_alternated_mean_returns =  gmm_estimates\asset_mean_returns(:);
model_implied_risk_premia = gmm_estimates*lambdas_for_alternated_mean_returns;

