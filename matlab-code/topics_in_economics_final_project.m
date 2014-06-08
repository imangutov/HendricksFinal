% Bertrand liechtenstein & Iliar Mangutov & Shanshan Ni & Sean Filipov
% Topics in economics, Final Project

clearvars
from_mat_file = true;
data = load_data(from_mat_file);

factors = data.factors;
factors_ndx = data.factors_ndx;
assets = data.asset_classes;
assets_inx = data.asset_classes_ndx;

% 2.1 CAPM
% OLS estimation 
%for asset_index=2:size(data.testassets,2)
%  ab = polyfit(data.factordata(:,data.excess_mkt_index),data.testassets(:,asset_index),1);
%  b(asset_index-1) = ab(1);
%  a(asset_index-1) = ab(2);
%end

% 2.2 use three macro variables to explain risk premia
predictors = [  factors(:,factors_ndx.consumer_price), ...
                factors(:,factors_ndx.unemployment_rate_monthly_percent), ...
                factors(:,factors_ndx.vix_monthly_change) ];
            
[num_of_timestamps, num_of_predictors] = size(predictors); 
coefficient_estimates = zeros(size(assets,2)-1,3);

for asset_index=2:size(assets,2)
  linear_regression_model = LinearModel.fit(predictors,assets(:,asset_index));
  coefficient_estimates(asset_index-1,:) = double(linear_regression_model.Coefficients(2:4,1))';
end


% 2.1.a Calculate the unconditional risk premium implied by the CAPM for these assets
%unconditional_risk_premium = b*mean(data.factordata(:,data.excess_mkt_index));
%testassets_excess_returns = data.testassets;
%testassets_excess_returns(:, 1) = [];

%testassets_excess_mean_returns = mean(testassets_excess_returns,1);

% 2.2.a The model-implied risk premia
lambdas = coefficient_estimates\testassets_excess_mean_returns(:);

% 2.2.b Report the estimates of the three lambdas
fprintf('lambda-recession = %.5f; lambda-GDP = %.5f; lambda-Corporate-Profit-Growth = %.5f\n',lambdas(1),lambdas(2),lambdas(3));

% 2.2.c Make a plot of the model-implied risk premia compared to the mean excess returns
model_implied_risk_premia = coefficient_estimates*lambdas;
scatter(model_implied_risk_premia,testassets_excess_mean_returns,'MarkerFaceColor','blue');
xlabel('Model-implied risk premium of asset');
ylabel('Actual mean excess return of the asset');
title('Factor Model:Model-implied risk premium vs actual');

% 2.2.d Report the mean of these 25 absolute value regression residuals
fprintf('Pricing error absolute mean = %.5f\n',mean(abs(model_implied_risk_premia'-testassets_excess_mean_returns)));

% 2.4 How do the models compare in ability to explain return variation of the test assets?
% R squared for CAPM model
for asset_index=1:size(testassets_excess_returns,2)
  y_hut = a(asset_index) + b(asset_index)*data.factordata(:,data.excess_mkt_index);
  y = testassets_excess_returns(:,asset_index);
  yresid = y - y_hut;
  SSresid = sum(yresid.^2);
  SStotal = (length(y)-1)*var(y);
  R2_CAPM(asset_index) = 1 - SSresid/SStotal;
end

% R squared for factor model
%for asset_index=1:size(testassets_excess_returns,2)
%  y_hut = predictors * coefficient_estimates(asset_index,:)';
%  y = testassets_excess_returns(:,asset_index);
%  yresid = y - y_hut;
%  SSresid = sum(yresid.^2);
%  SStotal = (length(y)-1)*var(y);
%  R2_FACTOR(asset_index) = 1 - SSresid/SStotal;
%end

y_hut = coefficient_estimates*lambdas;
y = mean(data.testassets(:,2:26),1)';
yresid = y_hut - y;
SSresid = sum(yresid.^2);
SStotal = (length(y)-1)*var(y);
R2_FACTOR2 = 1 - SSresid/SStotal;

fprintf('R^2 mean for CAPM = %.3f; R^2 mean for macro factor model = %.3f\n',mean(R2_CAPM),R2_FACTOR2);

% 2.5 
Rsharp_mkt = data.factordata(:,data.excess_mkt_index);
sharpe_ratio = 0.4;

gamma_func = @(factor) [var(factor), corr(Rsharp_mkt, factor), sharpe_ratio / var(factor) / corr(Rsharp_mkt, factor)]

recession_flag = 1 - data.factordata(:,data.recession_index);
gamma_recession = gamma_func(recession_flag);

GDP_growth = data.factordata(:,data.gdp_growth_index);
gamma_GDP_growth = gamma_func(GDP_growth);

corp_growth = data.factordata(:,data.corporate_profit_growth_index);
gamma_corp_growth = gamma_func(corp_growth);

fprintf('Risk aversion corresponding to inverted recession flag %.3f; corresponding to GDP flag %.3f, corporate profit growth %.3f\n',...
    gamma_recession(3), gamma_GDP_growth(3), gamma_corp_growth(3));

