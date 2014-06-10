% This function returns intersection based on first column
function result_array = get_intersect_array(timestamp_array,value_matrix)
  [arr,index_1,index_2] = intersect(timestamp_array,value_matrix(:,1));
  result_array = value_matrix(index_2,:);
%  result_array = result_array(:,2);
  result_array(:,1) = [];
end
