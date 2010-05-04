 #ActionMailer::Base.delivery_method = :smtp
 ActionMailer::Base.smtp_settings = {
      :address => "smtp.gmail.com",
      :port => 587,
      :domain => "gmail.com",
      :authentication => :plain,
      :user_name => "rubyslippery@gmail.com",
      :password => "slippery"
  }

