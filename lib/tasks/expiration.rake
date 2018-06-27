namespace :expiration do
  desc "Inform about upcomming reservation expiration"
  task send_expiration_information: :environment do
    reservations = Reservation.where(status: 'TAKEN').where(expires_at: Date.tomorrow.all_day)
    reservations.each do |reserv|
      book = Book.find_by(id: reserv.book_id)
      ReservationsMailer.book_return_remind(book).deliver
      ReservationsMailer.book_reserved_return(book).deliver
    end

  end
end