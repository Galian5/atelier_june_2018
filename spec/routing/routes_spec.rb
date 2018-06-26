require 'rails_helper'

describe 'AppRouting' do
  it {
    expect(root: 'books', action: 'index')
  }

  it {
    expect(get: 'books/12/reserve').to route_to(controller: 'reservations', action: 'reserve', book_id: '12')
  }

  it {
    expect(get: 'books/12/take').to route_to(controller: 'reservations', action: 'take', book_id: '12')
  }

  it {
    expect(get: 'books/12/give_back').to route_to(controller: 'reservations', action: 'give_back', book_id: '12')
  }

  it {
    expect(get: 'books/12/cancel_reservation').to route_to(controller: 'reservations', action: 'cancel', book_id: '12')
  }

  get 'users/:user_id/reservations', to: 'reservations#users_reservations', as: 'users_reservations'
  it {
    expect(get: 'users/12/').to route_to(controller: 'reservations', action: 'users_reservations', book_id: '12')
  }

  get 'google-isbn', to: 'google_books#show'
  resources :books


end
