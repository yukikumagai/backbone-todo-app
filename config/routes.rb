Todos::Application.routes.draw do
  root to: 'lists#index'

  get ':token', to: 'lists#show', as: :show_list

  scope ':token', as: 'list' do
    resources :items, only: %i[index show create update destroy]
  end
end
