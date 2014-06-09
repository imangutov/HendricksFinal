% Bertrand liechtenstein & Iliar Mangutov & Shanshan Ni & Sean Filipov
% Topics in economics, Final Project
% TODO quaterly - 'gdp-percent-change-quarterly.xls' & 'corporate-profits-after-tax-quaterly-percent-change.xls'

function [factors, indices, factor_data_set] = load_factors()
  factor_files ={ 'consumer-price-index-for-all-urban-consumers-percent-change-monthly.xls' ...
                  'sp500-divident-yield-per-month.xls' ...
                  'unemployment-rate-change-from-year-ago-percent.xls' ...
                  'unemployment-rate-monthly-change-percent.xls' ...
                  'unemployment-rate-monthly-percent.xls' ...
                  'vix-monthly-change-percent.xls'};
  for file_index = 1:size(factor_files,2)
    file_name = strcat('..\data\factors\', factor_files{file_index});
    [factor_data,~,raw_data] = xlsread(file_name);%factor_files{file_index});
    dates_list = datenum(raw_data(2:end,1));
    data_dates = year(dates_list)*100+month(dates_list);
    factor_data = [data_dates factor_data];
    if(~isempty(strfind(factor_files{file_index}, 'sp500-divident-yield-per-month.xls')))
      factor_data = grpstats(factor_data,factor_data(:,1)); % dividents are couple of times per month, average by months
    end
    factor_data = sortrows(factor_data,-1);  
    factor_data_set{file_index} = factor_data;
    clear dates_list raw_data data_dates factor_data;
  end
  clear factor_files;
  
  factor_data = factor_data_set{1,1};
  timestamp_array = factor_data(:,1);
  for factor_index = 2:size(factor_data_set,2)
    factor_data = factor_data_set{1,factor_index};
    timestamp_array=intersect(timestamp_array,factor_data(:,1));
  end
  
  % added GDP
  [GDB_data,~,raw_data] = xlsread('../data/factors/GDP.xls','A21:B289')
  dates_list = datenum(raw_data(:,1));
  data_dates = year(dates_list)*100+month(dates_list);
  GDP = [data_dates, GDB_data];
  factor_data_set{file_index+1} = GDP;
  
  %TODO - do not assume 6 factors, run in loop
  factors = horzcat(timestamp_array,...
                    get_intersect_array(timestamp_array,factor_data_set{1,1}),...
                    get_intersect_array(timestamp_array,factor_data_set{1,2}),...
                    get_intersect_array(timestamp_array,factor_data_set{1,3}),...
                    get_intersect_array(timestamp_array,factor_data_set{1,4}),...
                    get_intersect_array(timestamp_array,factor_data_set{1,5}),...
                    get_intersect_array(timestamp_array,factor_data_set{1,6}));
  factors = sortrows(factors,-1);
  indices.date = 1;
  indices.consumer_price = 2;
  indices.divident_yield = 3;
  indices.unemployment_rate_year_ago_chng = 4;
  indices.unemployment_rate_monthly_change_percent = 5;
  indices.unemployment_rate_monthly_percent = 6;
  indices.vix_monthly_change = 7;
  indices.GDP = 8;
end