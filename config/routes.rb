Rails.application.routes.draw do
  post 'file', controller: 'stored_files'
  get 'files/:tag_query_search/:page', controller: 'stored_files', action: 'files'
end
