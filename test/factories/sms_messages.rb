# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :sms_message, :class => 'Sms::Message' do
    direction "MyString"
    to "MyText"
    from "MyString"
    body "MyText"
    sent_at "2013-04-30 08:52:03"
  end
end
