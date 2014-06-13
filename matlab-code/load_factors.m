% Bertrand liechtenstein & Iliar Mangutov & Shanshan Ni & Sean Filipov
% Topics in economics, Final Project

function [factors, indices, factor_data_set] = load_factors()
  factors_directory = '..\data\factors\';
  factor_files ={ 'consumer-price-index-for-all-urban-consumers-percent-change-monthly.xls' ...
                  'unemployment-rate-monthly-percent.xls' ...
                  'vix-monthly-change-percent.xls' ...
                  'gdp.xls' ...
                  'corporate-profits-after-tax-quaterly-percent-change.xls' ...
                  'sp500-divident-yield-per-month.xls'};
  for file_index = 1:size(factor_files,2)
    file_name = strcat(factors_directory, factor_files{file_index});
    [factor_data,~,raw_data] = xlsread(file_name);
    dates_list = datenum(raw_data(2:end,1));
    data_dates = year(dates_list)*100+month(dates_list);
    factor_data = [data_dates factor_data];
    if(~isempty(strfind(factor_files{file_index}, 'sp500-divident-yield-per-month.xls')))
      factor_data = grpstats(factor_data,factor_data(:,1)); % dividents are couple of times per month, average by months
    end
    if strcmp(factor_files{file_index} ,'gdp.xls')==1 || strcmp(factor_files{file_index} ,'corporate-profits-after-tax-quaterly-percent-change.xls')==1
      factor_data = interpolate_quaterly_to_monthly(factor_data);
    end
    factor_data = sortrows(factor_data,-1);  
    factor_data_set{file_index} = factor_data;
    clear dates_list raw_data data_dates factor_data;
  end
  clear factor_files;
  
  GDB_value = factor_data_set{4}(:,2);
  GDB_dates = factor_data_set{4}(:,1);
  GDB_value = 12*(GDB_value(2:end)-GDB_value(1:end-1))./GDB_value(1:end-1);
  GDP = [GDB_dates(2:end,1), GDB_value];
  factor_data_set{4} = GDP;
  
  factor_data = factor_data_set{1,1};
  timestamp_array = factor_data(:,1);
  for factor_index = 2:size(factor_data_set,2)
    factor_data = factor_data_set{1,factor_index};
    timestamp_array=intersect(timestamp_array,factor_data(:,1));
  end
  
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
  indices.unemployment_rate_monthly_percent = 3;
  indices.vix_monthly_change = 4;
  indices.gdp = 5;
  indices.corporate_profits = 6;
  indices.divident_yield = 7;

end