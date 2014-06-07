% This function returns intersection based on first column
function result_array = get_intersect_array(timestamp_array,value_array)
  [arr,index_1,index_2] = intersect(timestamp_array,value_array(:,1));
  result_array = value_array(index_2,:);
  result_array = result_array(:,2);
end
