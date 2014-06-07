% Bertrand liechtenstein & Iliar Mangutov & Shanshan Ni & Sean Filipov
% Topics in economics, Final Project
function data = load_data()
    data.factordata = xlsread('finm350_2013_hw2_factordata.xls');
    data.year_index = 1;
    data.excess_mkt_index = 2;
    data.recession_index = 3;
    data.gdp_growth_index = 4;
    data.corporate_profit_growth_index = 5;

    data.testassets = xlsread('finm350_2013_hw2_testassets.xls');

    download_spx = false;
    if (download_spx)
        [spx_table, spx_div] = get_google_daily_data({'INDEXSP:.INX'}, ...
           '01/01/2003', '06/05/2014', 'mm/dd/yyyy');
        data.spx = double([spx_table.INDEXSP0x3A0x2EINX.Date, spx_table.INDEXSP0x3A0x2EINX.Close]);
        save('spx_daily_2003_2014.mat',spx);
    else
        data.spx = load('spx_daily_2003_2014.mat');
    end
end
