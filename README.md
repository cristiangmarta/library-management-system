# README

Rails API application backend for our Library Management System

- I Used Devise + JWT for authentication. JTI was chosen as the revocation strategy and I set the token lifespan to 1 day to make development easier.
- Used Pundit to cover authorization and scoped resources. I bundled part of a solution I already had for managing user roles. For this particular use case it may be an overkill, but it'd scale better if more roles were needed in the future
- Used a PG docker container for convenience
- Keeping in mind concurrency, I tried to cover every possible edge case regarding book availability.
- Used a state machine to manage the state of borrowed books. This is just personal preference, it may be an overkill, but it'd scale better if more transitions/callbacks were needed in the future
- Used a few of my go-to support gems for the specs
- Used Postman for integration testing (I included the collection in the codebase)

- "Author" and "Genre" from books could be extracted to their own table to avoid duplicated data in the DB
- Some improvements need to be made to the way json responses are seriliazed
- Pagination on #index endpoints is needed
- The usage of Book#available? may generate N+1 if not handled properly.
- Controller specs could more DRY


Setup
- docker-compose up db
- bundle install
- bundle exec rake db:drop db:create db:migrate db:seed
- bundle exec rails s


The password for each user is "1234Face"
- Users from "admin-test-1@example.com" to "admin-test-10@example.com" are "Members"
- Users from "admin-test-11@example.com" to "admin-test-20@example.com" are "Librarians"
