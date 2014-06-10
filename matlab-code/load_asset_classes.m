% Bertrand liechtenstein & Iliar Mangutov & Shanshan Ni & Sean Filipov
% Topics in economics, Final Project
function [asset_classes, indices, asset_data_set] = load_asset_classes()
%  files = {'bnd_vanguard_total_bond_market_etf_monthly.xls' ...
%           'lsc_snp_commodity_trends_indicator_monthly.xls' ...
%           'rwr_spdr_dow_jones_reit_etf_monthly.xls' ...
%           'shv_ishares_short_treasury_bond_monthly.xls' ...
%           'spy_us_equities_spdr_snp_500_monthly.xls' ...
%           'gld_spdr_gold_shares_etf_monthly.xls'};

  files = {'rwr_spdr_dow_jones_reit_etf_monthly.xls' ...
           'spy_us_equities_spdr_snp_500_monthly.xls' ...
           'gld_spdr_gold_shares_etf_monthly.xls'};
  close_price_index = 4;
           
  for file_index = 1:size(files,2)
    file_name = strcat('..\data\asset-and-asset-classes\', files{file_index});
    [level_data,~,raw_data] = xlsread(file_name);
    dates_list = datenum(raw_data(2:end,1));
    data_dates = year(dates_list)*100+month(dates_list);
    asset_data = [data_dates level_data(:,close_price_index)];
    assets{file_index} = asset_data;
  end
  clear file_index raw_data level_data dates_list data_dates close_price_index files asset_data;

  % get intersect with the risk free rate.
  for asset_index = 1:size(assets,2)
    asset_data = assets{1,asset_index};
    returns = 12.0 * (asset_data(1:end-1,2)-asset_data(2:end,2))./asset_data(2:end,2);
    assets{1,asset_index}(1:end-1,2) = returns;
    assets{1,asset_index}(end,:) = [];
  end
  
  asset_data_set = assets;
  
  asset = assets{1,1};
  timestamp_array = asset(:,1);
  for ndx = 2:size(assets,2)
    asset = assets{1,ndx};
    timestamp_array = intersect(timestamp_array,asset(:,1));
  end
  
  %TODO - do not assume 6 assets, run in loop
  asset_classes = horzcat(timestamp_array,...
                    get_intersect_array(timestamp_array,assets{1,1}),...
                    get_intersect_array(timestamp_array,assets{1,2}),...
                    get_intersect_array(timestamp_array,assets{1,3}));
%                    get_intersect_array(timestamp_array,assets{1,4}),...
%                    get_intersect_array(timestamp_array,assets{1,5}),...                    
%                    get_intersect_array(timestamp_array,assets{1,6}));
  asset_classes = sortrows(asset_classes,-1);

  indices.date = 1;
%  indices.bnd_vanguard_total_bond_market_etf_monthly = 2;
%  indices.lsc_snp_commodity_trends_indicator_monthly = 3;
  indices.rwr_spdr_dow_jones_reit_etf_monthly = 2;
%  indices.shv_ishares_short_treasury_bond_monthly = 5;
  indices.spy_us_equities_spdr_snp_500_monthly = 3;
  indices.gld_spdr_gold_shares_etf_monthly = 4;  

end