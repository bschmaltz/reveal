module ApplicationHelper
	# Returns the full title on a per-page basis.
  def full_title(page_title)
    base_title = "Reveal"
    if page_title.empty?
      base_title
    else
      "#{base_title} | #{page_title}"
    end
  end

  def api_url
    "http://reveal-api.herokuapp.com"
    #{}"http://localhost:3001"
  end

  def authenticated?
    !session[:user].nil?
  end

  def current_user
    session[:user]
  end
end