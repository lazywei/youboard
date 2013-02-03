# -*- encoding : utf-8 -*-
module BootstrapHelper
  def notice_message
    flash_messages = []
    flash.each do |type, message|
      type = case type
             when :notice then :success
             when :alert then :error
             end
      content = content_tag :div, :class => "alert fade in alert-#{type}" do
        button_tag("x", :class => "close", "data-dismiss" => "alert") + message
      end
      flash_messages << content if message.present?
    end
    flash_messages.join("\n").html_safe
  end
end
