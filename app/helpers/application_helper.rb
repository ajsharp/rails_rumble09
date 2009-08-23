module ApplicationHelper
  
  # Sets the page title and outputs title if container is passed in.
  # eg. <%= title('Hello World', :h2) %> will return the following:
  # <h2>Hello World</h2> as well as setting the page title.
  def title(str, container = nil)
    @page_title = str
    content_tag(container, str) if container
  end
  
  # Outputs the corresponding flash message if any are set
  def flash_messages
    messages = []
    %w(notice success error).each do |msg|
      messages << content_tag(:div, html_escape(flash[msg.to_sym]), :id => "#{msg}") unless flash[msg.to_sym].blank?
    end
    messages
  end
  
  def link_or_active(link_title, link_path={}, alternatives={})
    link_to_unless_current(link_title, link_path, alternatives) {
      # checking to see if "active" is already one of the classes assigned, and if NOT, append it to the classes string
      unless alternatives[:class] =~ /^(\w*\s+)*active/
        if alternatives[:class]
          alternatives[:class].rstrip!
          alternatives[:class] << ' active'
        else
          alternatives[:class] = 'active'
        end
      end
      link_to(link_title, link_path, alternatives)
    }
	end
  
end
