namespace :reservation do
  desc "Cancel too much reservation"
  task cancel_overreserved: :environment do
    users = User.joins(:reservations).group('users.id').having('count(user_id) > 20')
    users.each do |user|
      user.reservations.each { |reservation| reservation.update_attributes(status: 'CANCELED') }
    end
  end
end