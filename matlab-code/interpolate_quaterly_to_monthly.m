% This function does spline interpolation of quaterly data to monthly
function monthly = interpolate_quaterly_to_monthly(quaterly)
  quaterly = sortrows(quaterly,1);
  xx = (1:size(quaterly,1)*3)';
  x = (1:3:size(quaterly,1)*3)';
  y = quaterly(:,2);
  yy = spline(x,y,xx);
  data_start_date = datenum(fix(quaterly(1,1)/100),rem(quaterly(1,1),100),1);
  for data_ndx = 1:size(xx,1)
    date = addtodate(data_start_date, xx(data_ndx,1)-1, 'month');
    dates(data_ndx) = year(date)*100+month(date);
  end
  dates = dates';
  monthly = [dates yy];
end
