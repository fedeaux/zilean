require 'rails_helper'

RSpec.describe 'Activity Requests', type: :request do
  describe 'GET api/activities' do
    it 'is unauthorized if no user is logged in' do
      get '/api/activities'
      expect(response).to be_unauthorized
    end

    context 'Authorized' do
      before :each do
        login_as create :user_ray
        create :activity_work_project_x
        create :activity_work_project_dharma
      end

      it 'returns a hierarchy tree of activities for the current user' do
        get '/api/activities'
        json_response = JSON.parse response.body

        expect(json_response.length).to eq 1
        expect(json_response[0]['name']).to eq 'Work'

        expect(json_response[0]['children'].length).to eq 2
        expect(json_response[0]['children'][0]['name']).not_to eq nil
      end
    end
  end

  describe 'POST api/activities' do
    it 'is unauthorized if no user is logged in' do
      post '/api/activities'
      expect(response).to be_unauthorized
    end

    context 'Authorized' do
      before :each do
        login_as create :user_ray
        create :activity_work_project_x
        create :activity_work_project_dharma
      end

      it 'creates an activity' do
        attributes = attributes_for(:activity_sleep)
        post '/api/activities', params: { activity: attributes }
        json_response = JSON.parse response.body

        expect(json_response['id']).not_to be nil
        expect(json_response['name']).to eq attributes[:name]
      end

      it 'creates an activity with parent' do
        parent = create :activity_sleep
        attributes = { name: 'Nap', parent_id: parent.id }
        post '/api/activities', params: { activity: attributes }
        json_response = JSON.parse response.body

        expect(json_response['id']).not_to be nil
        expect(json_response['name']).to eq attributes[:name]

        expect(json_response['color']).to eq parent.color
        expect(json_response['parent_id']).to eq parent.id
      end
    end
  end
end
