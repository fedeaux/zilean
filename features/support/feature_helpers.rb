module FeatureHelpers
  def normalize(name)
    name.split(' ').map(&:strip).map(&:downcase).join('-')
  end

  def dom_element_selector(name, type: 'the')
    prefix = type == 'the' ? '#' : '.'

    if name.include? 'for the'
      parts = name.split('for the').map(&:strip)
      "#{prefix}#{normalize(parts.second)} .#{normalize(parts.first)}"
    else
      prefix + normalize(name)
    end
  end

  def dom_element(name, type: 'the')
    find(dom_element_selector(name, type: type))
  end

  def parse_parameter_list(parameter_list)
    parameter_list.split(',').map { |part|
      parts = part.split.map(&:strip)
      [parts.first.chomp(':'), parts.second]
    }.to_h
  end

  def fill_form_with(form, form_object_name, values)
    within form do
      values.each do |name, value|
        fill_field_with find_field("#{form_object_name}[#{name}]"), value
      end
    end
  end

  def fill_field_with(field, value)
    if field.tag_name == 'input'
      field.set value
    end
  end
end

World(FeatureHelpers)
