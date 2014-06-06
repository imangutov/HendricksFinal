% Bertrand liechtenstein & Iliar Mangutov & Shanshan Ni,
% Topics in economics, Final Project
function data = load_data()

data.factordata = xlsread('finm350_2013_hw2_factordata.xls');
data.year_index = 1;
data.excess_mkt_index = 2;
data.recession_index = 3;
data.gdp_growth_index = 4;
data.corporate_profit_growth_index = 5;

data.testassets = xlsread('finm350_2013_hw2_testassets.xls');

end
