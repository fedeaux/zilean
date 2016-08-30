module FeatureHelpers
  def normalize(name)
    name.split(' ').map(&:strip).map(&:downcase).join('-')
  end

  def dom_element_selector(name)
    if name.include? 'for the'
      parts = name.split('for the').map(&:strip)
      "##{normalize(parts.second)} .#{normalize(parts.first)}"
    else
      '#' + normalize(name)
    end
  end

  def dom_element(name)
    find(dom_element_selector(name))
  end
end

World(FeatureHelpers)
