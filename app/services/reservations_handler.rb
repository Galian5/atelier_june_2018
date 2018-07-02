class ReservationsHandler
  def initialize(user, book)
    @user = user
    @book = book
  end

  def reserve
    return unless can_reserve?(user)

    book.reservations.create(user: user, status: 'RESERVED')
  end


  def cancel_reservation(user)
    book.reservations.where(user: user, status: 'RESERVED').order(created_at: :asc).first.update_attributes(status: 'CANCELED')
  end

  private
  attr_reader :user, :book

  def not_taken?
    book.reservations.find_by(status: 'TAKEN').nil?
  end

  def can_take?(user)
    not_taken? && ( available_for_user?(user) || book.reservations.empty? )
  end


  def next_in_queue
    book.reservations.where(status: 'RESERVED').order(created_at: :asc).first
  end

  def pending_reservations
    book.reservations.find_by(status: 'PENDING')
  end

  def available_reservation
    book.reservations.find_by(status: 'AVAILABLE')
  end

  def available_for_user?(user)
    if available_reservation.present?
      available_reservation.user == user
    else
      pending_reservations.nil?
    end
  end


  def can_reserve?(user)
    book.reservations.find_by(user: user, status: 'RESERVED').nil?
  end


end

