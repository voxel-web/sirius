require 'api_spec_helper'
require 'icalendar'

RSpec.shared_examples 'events endpoint' do
  include_context 'API response'

  let(:events_cnt) { 3 }
  let(:events_params) { Hash.new }

  # Events from 2014-04-01 to 2014-04-03
  let!(:events) do
    i = 0
    Fabricate.times(events_cnt, :event, events_params) do
      starts_at { "2014-04-0#{i+=1} 14:30" } # XXX sequencer in times doesn't work
      ends_at { "2014-04-0#{i} 16:00" }
    end
  end
  let(:event) { events.first }

  let(:event_json) do
    {
      id: event.id,
      name: event.name,
      starts_at: event.starts_at,
      ends_at: event.ends_at
    }.to_json
  end

  subject { body }

  it 'is sane' do
    expect(Event.where(events_params).count).to eql events_cnt
  end

  context 'with default parameters' do
    before { get path }

    it 'returns OK' do
      expect(status).to eql(200)
    end

    it 'returns a JSON-API format' do
      expect(body).to have_json_size(events_cnt).at_path('events')
    end
  end

  context 'with pagination' do
    before { get "#{path}?limit=1&offset=1" }
    it { should have_json_size(1).at_path('events') }
  end

  context 'with date filtering' do
    before { get "#{path}?from=2014-04-02T13:50&to=2014-04-03T00:00" }
    it { should have_json_size(1).at_path('events') }
  end

  context 'as an icalendar' do
    before { get '/events.ical' }

    it 'returns a valid content-type' do
      expect(headers['Content-Type']).to eql('text/calendar')
    end

    it 'returns a valid iCalendar' do
      calendar = Icalendar.parse(body).first
      expect(calendar.events.size).to eq(events_cnt)
    end
  end
end

RSpec.shared_examples 'invalid endpoint' do
  it 'returns a Not Found error' do
    get path
    expect(response.status).to eql 404
  end
end


describe API::EventsEndpoints do
  include_context 'API response'

  describe 'GET /events' do
    let(:path) { '/events' }
    it_behaves_like 'events endpoint'
  end

  describe 'GET /events/:id' do
    let(:event) { Fabricate(:event) }
    let(:event_json) do
      {
        id: event.id,
        name: event.name,
        starts_at: event.starts_at,
        ends_at: event.ends_at
      }.to_json
    end
    context 'JSON-API format' do
      before { get "/events/#{event.id}" }
      subject { body }

      it 'returns OK' do
        expect(status).to eql(200)
      end

      it { should have_json_size(1).at_path('events') }

      it { should be_json_eql(event_json).at_path('events/0') }

    end

    context 'with non-existent resource' do
      before { get "/events/9001" }
      it 'returns a Not Found error' do
        expect(status).to eql(404)
      end
    end
  end

  let(:room) { Fabricate(:room, kos_code: 'T9:350') }

  describe 'GET /rooms' do
    it_behaves_like 'invalid endpoint' do
      let(:path) { '/rooms' }
    end
  end

  describe 'GET /rooms/:kos_id' do
    it_behaves_like 'invalid endpoint' do
      let(:path) { "/rooms/#{room.kos_code}" }
    end
  end

  describe 'GET /rooms/:kos_code/events' do
    let(:path) { "/rooms/#{room.kos_code}/events" }

    context 'with non-existent room' do
      before { get path }
      let(:path) { "/rooms/YOLO/events" }
      it 'returns a Not Found error' do
        expect(status).to eql 404
      end
    end

    context 'with existing room' do
      it_behaves_like 'events endpoint' do
        let(:events_params) { { room: room } }
      end
    end
  end
end
