% Bertrand liechtenstein & Iliar Mangutov & Shanshan Ni & Sean Filipov
% Topics in economics, Final Project
function [factors risk_free_rate asset_classes_returns] = load_data()
  factors = load_factors();
  risk_free_rate = load_risk_free_rate();
  asset_classes_returns = load_asset_classes();
end
