
FactoryGirl.define do

  factory :photo do
    user
    image {  Rack::Test::UploadedFile.new(Rails.root.join('spec/requests/medium_missing.png'), 'image/png')}
  end

  factory :user, aliases: [:friender, :friendee, :friend] do
    sequence(:first_name){ |n| "Foo#{n}"}
    sequence(:last_name){ |n| "Bar#{n}"}
    email { "#{first_name}@#{last_name}.com"}
    password 'foobarfoobar'
    password_confirmation 'foobarfoobar'
    friendships_count 0

    after(:build) do |user|
      class << user
        def send_welcome_email; true; end
      end
    end

    trait :with_welcome_email do
      after(:build) do |user|
        class << user
          def send_welcome_email; super; end
        end
      end
    end

    trait :with_profile do
      association :profile
    end
    trait :with_pending_friend_request do
      after(:create) do |user|
        friend = create(:friendee, :with_profile)
        user.initiated_friendships.create(friendee_id: friend.id)
      end
    end
    trait :with_rejected_friend_request do
      after(:create) do |user|
        friend = create(:user, :with_profile)
        create(:friendship, rejected: true, friendee_id: friend.id, friender_id: user.id)
      end
    end
    trait :with_accepted_friend_request do
      after(:create) do |user|
        friend = create(:friend, :with_profile)
        create(:friendship, rejected: false, friendee_id: friend.id, friender_id: user.id)
      end
    end
    trait :with_friends do
      transient do
        friend_count 3
      end
      after(:create) do |u, evaluator|
        friends = create_list(:friend, evaluator.friend_count, :with_profile)
        u.friendees << friends
      end
    end

  end

  factory :profile do
    sex 'female'
    birthdate { Faker::Date.birthday(13,99)}
    college { Faker::University.name }
    hometown { Faker::Address.city }
    current_city { Faker::Address.city }
    telephone { Faker::PhoneNumber.phone_number }
    quote { Faker::Hacker.say_something_smart }
    about { Faker::Hipster.sentence(3) }
    trait :with_user do
      user
    end
    trait :with_images do
      association :avatar, factory: :photo
      association :cover, factory: :photo
    end

    trait :male do
      sex 'male'
    end
    trait :without_images do
      avatar_id nil
      cover_id nil
    end
  end

  factory :friendship do
    association :friend_initiator, factory: [:friender, :with_profile]
    association :friend_recipient, factory: [:friendee, :with_profile]
    rejected nil
    trait :accepted do
      rejected false
    end
    trait :pending do
      rejected nil
    end

  end

  factory :post do
    body  { Faker::Hacker.say_something_smart }
    user

    after(:create) do |post|
      create(:profile, user: post.user)
    end

    trait :with_likes do
      transient do
        likes_count 3
      end
      after(:create) do |post, evaluator|
        create_list(:like, evaluator.likes_count, :for_post, likeable: post)
      end

    end

  end
  factory :like do
    user
    trait :for_post do
      association :likeable, factory: :post
    end
    trait :for_comment do
      association :likeable, factory: :comment
    end
  end

  factory :comment do
    body Faker::Hacker.say_something_smart
    user
    trait :for_post do
      # commentable_type 'Post'
      association :commentable, factory: :post
    end
    trait :for_photo do
      # commentable_type 'Photo'
      association :commentable, factory: :photo
    end

    # this is so we don't send notification emails automatically when testing
    after(:build) do |comment|
      class << comment
        def send_notification_email; true; end
      end
    end

    trait :with_notification_email do
      after(:build) do |comment|
        class << comment
          def send_notification_email; super; end
        end
      end
    end

  end

  factory :activity do
    user
    trait :for_photo do
      association :activable, factory: :photo
    end
    trait :for_post do
      association :activable, factory: :post
    end
  end



end
