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

% 1. Estimate B parameters (5 asset classes -> 6 parameters)
for asset_index=2:size(assets,2)
  linear_regression_model = LinearModel.fit(predictors,assets(:,asset_index));
  coefficient_estimates(asset_index-1,:) = double(linear_regression_model.Coefficients(2:4,1))';
end

assets_excess_returns = assets;
assets_excess_returns(:, 1) = [];
assets_excess_mean_returns = mean(assets_excess_returns,1);

% 2. Estimate factor premia
lambdas = regress(assets_excess_mean_returns',coefficient_estimates);

% 3. Compare the model implied risk premia with the mean return
model_implied_risk_premia = coefficient_estimates*lambdas;

scatter(model_implied_risk_premia, assets_excess_mean_returns,'MarkerFaceColor','blue');
xlabel('Model-implied risk premium of asset');
ylabel('Actual mean excess return of the asset');
title('Factor Model:Model-implied risk premium vs actual');

% 2.2.d Report the mean of these 25 absolute value regression residuals
fprintf('Pricing error absolute mean = %.5f\n',mean(abs(model_implied_risk_premia' - assets_excess_mean_returns)));

y_hut = coefficient_estimates*lambdas;
y = mean(assets(:,2:6),1)';
yresid = y_hut - y;
SSresid = sum(yresid.^2);
SStotal = (length(y)-1)*var(y);
R2_FACTOR2 = 1 - SSresid/SStotal;

fprintf('R^2 mean for CAPM = %.3f; R^2 mean for macro factor model = %.3f\n',mean(R2_CAPM),R2_FACTOR2);

