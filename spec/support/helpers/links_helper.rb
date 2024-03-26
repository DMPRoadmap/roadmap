# frozen_string_literal: true

module LinksHelper
  def add_link
    click_link '+ Add an additional URL'
  end

  def remove_link
    # # Scroll the element into view
    last_link = all('a.delete > .fas.fa-circle-xmark.fa-reverse', visible: false).last
    scroll_to_element(last_link)
    # Use Javascript to click link element, as it appears to be size 0
    execute_script('arguments[0].click();', last_link)
  end

  def scroll_to_element(element)
    script = 'arguments[0].scrollIntoView(true)'
    execute_script(script, element.native)
  end
end
