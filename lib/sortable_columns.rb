module SortableColumns
  
  class ParameterError < StandardError; end
  
  def sortable_order(sortable, options = {})
    add_custom_sort_keys( sortable, options[:custom_keys] )
    if params[:sort_by] && params[:sort_by][sortable.to_s.downcase.to_sym] && params[:order] && params[:order][sortable.to_s.downcase.to_sym]
      validate_params(sortable)
      store_sort(sortable)
      if session[:sortable_columns][:custom_sort][sortable.to_s.downcase.to_sym][params[:sort_by][sortable.to_s.downcase.to_sym]]
        result = "#{session[:sortable_columns][:custom_sort][sortable.to_s.downcase.to_sym][params[:sort_by].delete(sortable.to_s.downcase.to_sym)]} #{params[:order].delete(sortable.to_s.downcase.to_sym)}"
        params.delete(:sort_by)
        params.delete(:order)
        return result
      else
        result = "#{params[:sort_by].delete(sortable.to_s.downcase.to_sym)} #{params[:order].delete(sortable.to_s.downcase.to_sym)}"
        params.delete(:sort_by)
        params.delete(:order)
        return result
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
        result = "#{column.to_s} #{session[:sortable_columns][sortable.to_s.downcase.to_sym][col_name.to_sym]}"
        return result
      end
    end
  end
  
private

  def validate_params(sortable)
#    raise ParameterError.new("#{sortable} has no column \"#{params[:sort_by]}\".") unless sortable.column_names.include?(params[:sort_by])
    raise ParameterError.new("Order must be \"asc\" or \"desc\"") unless params[:order][sortable.to_s.downcase.to_sym] == "asc" || params[:order][sortable.to_s.downcase.to_sym] == "desc"
  end

  def store_sort(sortable )
    session[:sortable_columns] ||= Hash.new
    session[:sortable_columns][sortable.to_s.downcase.to_sym] = {params[:sort_by][sortable.to_s.downcase.to_sym].to_sym => params[:order][sortable.to_s.downcase.to_sym]}
  end

  def add_custom_sort_keys( sortable, custom_keys = {} )
    session[:sortable_columns] ||= Hash.new
    session[:sortable_columns][:custom_sort] ||= Hash.new
    session[:sortable_columns][:custom_sort][sortable.to_s.downcase.to_sym] ||= Hash.new
    custom_keys.each do |key,value|
      session[:sortable_columns][:custom_sort][sortable.to_s.downcase.to_sym][key] = value
    end
  end
end
