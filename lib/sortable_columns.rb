module SortableColumns
  
  class ParameterError < StandardError; end
  
  def sortable_order(sortable, options = {})
    add_custom_sort_keys( sortable, options[:custom_keys] )
    if params[:sort_by] && params[:order]
      validate_params(sortable)
      store_sort(sortable)
      if session[:sortable_columns][:custom_sort][sortable.to_s.downcase.to_sym][params[:sort_by]]
        return "#{session[:sortable_columns][:custom_sort][sortable.to_s.downcase.to_sym][params.delete(:sort_by)]} #{params.delete(:order)}"
      else
        return "#{params.delete(:sort_by)} #{params.delete(:order)}"
      end
    else
      if session[:sortable_columns] && session[:sortable_columns][sortable.to_s.downcase.to_sym]
        col_name = session[:sortable_columns][sortable.to_s.downcase.to_sym].keys.first.to_s
        if session[:sortable_columns][:custom_sort] and session[:sortable_columns][:custom_sort][sortable.to_s.downcase.to_sym] and
              session[:sortable_columns][:custom_sort][sortable.to_s.downcase.to_sym][col_name] 
          column = session[:sortable_columns][:custom_sort][sortable.to_s.downcase.to_sym][col_name]
        else
          column = col_name 
        end
        return "#{column.to_s} #{session[:sortable_columns][sortable.to_s.downcase.to_sym][column.to_sym]}"
      end
    end
  end
  
private

  def validate_params(sortable)
#    raise ParameterError.new("#{sortable} has no column \"#{params[:sort_by]}\".") unless sortable.column_names.include?(params[:sort_by])
    raise ParameterError.new("Order must be \"asc\" or \"desc\"") unless params[:order] == "asc" || params[:order] == "desc"
  end

  def store_sort(sortable )
    session[:sortable_columns] ||= Hash.new
    session[:sortable_columns][sortable.to_s.downcase.to_sym] = {params[:sort_by].to_sym => params[:order]}
  end

  def add_custom_sort_keys( sortable, custom_keys = {} )
    session[:sortable_columns] ||= Hash.new
    session[:sortable_columns][:custom_sort] ||= {}
    session[:sortable_columns][:custom_sort][sortable.to_s.downcase.to_sym] ||= {}
    custom_keys.each do |key,value|
      session[:sortable_columns][:custom_sort][sortable.to_s.downcase.to_sym][key] = value
    end
  end
end
