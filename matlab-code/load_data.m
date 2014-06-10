% Bertrand liechtenstein & Iliar Mangutov & Shanshan Ni & Sean Filipov
% Topics in economics, Final Project
function data = load_data(from_mat_file)
    data_file_name = '../data/data.mat'; 
    if (from_mat_file)
        data = load(data_file_name);
        data = data.data;
    else
        [data.factors data.factors_ndx data.factor_data_set] = load_factors();
        [asset_classes data.asset_classes_ndx asset_data_set] = load_asset_classes();
        [all_etfs, data.etfs_indices, etf_data_set] = load_etf(size(asset_classes,2)-1);
        data.risk_free_rate = load_risk_free_rate();
        
        data.asset_data_set = [asset_data_set, etf_data_set];

        common_timestamps = intersect(asset_classes(:,1),all_etfs(:,1));
        data.assets = [common_timestamps, ...
                       get_intersect_array(common_timestamps, asset_classes), ...
                       get_intersect_array(common_timestamps, all_etfs)];

        % convert asset returns to excess asset returns by extracting the
        % risk free rate.
        for asset_ndx = 1:size(data.asset_data_set,2)
            common_timestamps = intersect(data.asset_data_set{asset_ndx}(:,1),...
                                          data.risk_free_rate(:,1));
            risk_free_rate = get_intersect_array(common_timestamps, data.risk_free_rate);
            asset_return   = get_intersect_array(common_timestamps, data.asset_data_set{asset_ndx});
            asset_excess_return = asset_return - risk_free_rate;
            data.asset_data_set{asset_ndx} = [common_timestamps, asset_excess_return];
        end
        
        % chop off heads and tails, so all 3 matrix would overlap 
        % exactly 100%
        min_date = max([min(data.factors(:,1)), ...
                        min(data.assets(:,1)), ...
                        min(data.risk_free_rate(:,1)) ]);
        max_date = min([max(data.factors(:,1)), ...
                        max(data.assets(:,1)), ...
                        max(data.risk_free_rate(:,1))]);
        data.factors(data.factors(:,1) < min_date, :) = [];
        data.factors(data.factors(:,1) > max_date, :) = [];
        data.assets(data.assets(:,1) < min_date, :) = [];
        data.assets(data.assets(:,1) > max_date, :) = [];
        data.risk_free_rate(data.risk_free_rate(:,1) < min_date, :) = [];
        data.risk_free_rate(data.risk_free_rate(:,1) > max_date, :) = [];

        for asset_ndx = 2:size(data.assets,2)
            data.assets(:,asset_ndx) = data.assets(:,asset_ndx) - data.risk_free_rate(:,2);
        end
        
        save(data_file_name, 'data');
    end
    
    clear data_file_name load_mat_file;
    
end
