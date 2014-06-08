% Bertrand liechtenstein & Iliar Mangutov & Shanshan Ni & Sean Filipov
% Topics in economics, Final Project

function risk_free_rate = load_risk_free_rate()
  [free_rate_data,~,raw_data] = xlsread('libor-1-month-us-rates.xls');
  dates_list = datenum(raw_data(2:end,1));
  data_dates = year(dates_list)*100+month(dates_list);
  risk_free_rate = [data_dates free_rate_data(:,1)/100];
  risk_free_rate = sortrows(risk_free_rate,-1);
end