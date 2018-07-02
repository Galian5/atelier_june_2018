class Book < ApplicationRecord
  has_many :reservations
  has_many :borrowers, through: :reservations, source: :user
  belongs_to :category

  # statuses: AVAILABLE, TAKEN, RESERVED, EXPIRED, CANCELED, RETURNED

  def category_name
    category.try(:name)
  end

  def category_name=(name)
    self.category = Category.where(name: name).first_or_initialize
  end

  def can_take?(user)
    not_taken? && ( available_for_user?(user) || reservations.empty? )
  end


  def can_give_back?(user)
    reservations.find_by(user: user, status: 'TAKEN').present?
  end

  def take(user)
    return unless can_take?(user)

    if available_reservation.present?
      available_reservation.update_attributes(status: 'TAKEN')
    else
      reservations.create(user: user, status: 'TAKEN')
    end.tap {|reservation|
      notify_user_calendar(reservation)
    }
  end

  def give_back
    ActiveRecord::Base.transaction do
      reservations.find_by(status: 'TAKEN').tap { |reservation|
        reservation.update_attributes(status: 'RETURNED')
        notify_user_calendar(reservation)
      }
      next_in_queue.update_attributes(status: 'AVAILABLE') if next_in_queue.present?
    end
  end


  def can_reserve?(user)
    reservations.find_by(user: user, status: 'RESERVED').nil?
  end


  private

  def notify_user_calendar(reservation)
    UserCalendarNotifier.new(reservation.user).perform(reservation)
  end

  def not_taken?
    reservations.find_by(status: 'TAKEN').nil?
  end

  def available_for_user?(user)
    if available_reservation.present?
      available_reservation.user == user
    else
      pending_reservations.nil?
    end
  end

  def pending_reservations
    reservations.find_by(status: 'PENDING')
  end

  def available_reservation
    reservations.find_by(status: 'AVAILABLE')
  end


end
