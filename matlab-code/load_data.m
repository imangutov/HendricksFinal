% Bertrand liechtenstein & Iliar Mangutov & Shanshan Ni & Sean Filipov
% Topics in economics, Final Project
function data = load_data(from_mat_file)
    data_file_name = '../data/data.mat'; 
    if (from_mat_file)
        data = load(data_file_name);
        data = data.data;
    else
        [data.factors data.factors_ndx data.factor_data_set] = load_factors();
        [data.asset_classes data.asset_classes_ndx data.asset_data_set] = load_asset_classes();
        data.risk_free_rate = load_risk_free_rate();

        for asset_class_ndx = 1:size(data.asset_data_set,2)
            common_timestamps = intersect(data.asset_data_set{asset_class_ndx}(:,1),...
                                          data.risk_free_rate(:,1));
            risk_free_rate = get_intersect_array(common_timestamps, data.risk_free_rate);
            asset_return   = get_intersect_array(common_timestamps, data.asset_data_set{asset_class_ndx});
            asset_excess_return = asset_return - risk_free_rate;
            data.asset_data_set{asset_class_ndx}(:,2) = asset_excess_return;
        end
        
        min_date = max([min(data.factors(:,1)), ...
                        min(data.asset_classes(:,1)) ...
                        min(data.risk_free_rate(:,1)) ]);
        max_date = min([max(data.factors(:,1)), ...
                        max(data.asset_classes(:,1)), ...
                        max(data.risk_free_rate(:,1))]);
        data.factors(data.factors(:,1) < min_date, :) = [];
        data.factors(data.factors(:,1) > max_date, :) = [];
        data.asset_classes(data.asset_classes(:,1) < min_date, :) = [];
        data.asset_classes(data.asset_classes(:,1) > max_date, :) = [];
        data.risk_free_rate(data.risk_free_rate(:,1) < min_date, :) = [];
        data.risk_free_rate(data.risk_free_rate(:,1) > max_date, :) = [];
        
        save(data_file_name, 'data');
    end
    
    clear data_file_name load_mat_file;
    
end
