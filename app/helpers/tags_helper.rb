module TagsHelper
  def do_tag_menu(tag)
    tag.children.each do |child|
      render _child_form 
      do_something(child)
    end
  end
end
