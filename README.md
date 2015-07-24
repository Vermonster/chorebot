# Chorebot

Remind people to do things at certain times

## Setup

Chorebot requires two ENV variables: `SLACK_MEMBERS_URL` and `SLACK_WEBHOOK_URL`.

`SLACK_MEMBERS_URL` is a URL that includes an API access token and it lets Chorebot get a list of the current members of the organization so it can figure out possible assignees.

`SLACK_WEBHOOK_URL` is a URL that gives Chorebot access to post to a particular channel. Any HTTP `POST`s that Chorebot makes to this URL show up as Slack posts in that channel. For development, you should generate your own incoming webhook URL that points to a random channel only you are in, so you don't clutter up the main channel with test posts. See https://api.slack.com/incoming-webhooks.

In the future:
- Instead of `SLACK_MEMBERS_URL` we might just pass in the API token as an ENV variable, if we end up needing other API endpoints.
- We might rename `SLACK_WEBHOOK_URL` if we have both incoming and outgoing webhook URLs.

## Development

Most of Chorebot's business logic exists in `chorebot.rb`. I've been iterating by just doing:

```
$ bundle exec foreman run irb -I . -r chorebot
```

And seeing the results of running the methods in my console or as posted to Slack.

## Testing

```
$ rspec spec
```

We don't have any real API mocks set up, but you can just override the methods that talk to the API if you want to add basic test coverage:

```ruby
# require the file with business logic
require 'chorebot'

# override the methods which talk to the api
def post_message(message)
  $last_chorebot_message = message
end

def member_names
  ['some', 'constants']
end

# add your tests
describe 'chorebot' do
  # tests
end
```
