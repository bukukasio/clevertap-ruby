require 'spec_helper'

describe CleverTap::Response do
  let(:success) do
    { 'status' => 'success', 'processed' => 1, 'unprocessed' => [] }
  end

  let(:partial) do
    {
      'status' => 'success',
      'processed' => 1,
      'unprocessed' => [{ '{ "ID" => "5", "Name": "John"}' => 'Some error' }]
    }
  end

  let(:failure) do
    {
      'status' => 'fail',
      'error' => 'Account Id not valid',
      'code' => 401
    }
  end

  let(:non_json) do
    '<head><title>502 Bad Gateway</title></head>'\
    '<body>' \
    '<center><h1>502 Bad Gateway</h1></center>'\
    '</body>'\
    '</html>'
  end

  describe '#new' do
    subject { described_class.new(response) }

    context 'when successful request' do
      let(:response) { OpenStruct.new(body: success.to_json, success?: true) }

      it { expect(subject.success).to be true }
      it { expect(subject.failures).to eq [] }
    end

    context 'when partially successful request' do
      let(:response) { OpenStruct.new(body: partial.to_json, success?: true) }

      it { expect(subject.success).to be false }
      it { expect(subject.failures).to eq partial['unprocessed'] }
    end

    context 'when failed request' do
      let(:response) { OpenStruct.new(body: failure.to_json, success?: false) }

      it { expect(subject.success).to be false }
      it { expect(subject.failures).to eq [failure] }
    end

    context 'when non json response' do
      let(:response) { OpenStruct.new(body: non_json, success?: false) }

      it { expect(subject.success).to be false }
      it { expect(subject.failures).to eq [{ resp_string: non_json.to_s }.to_json] }
    end
  end
end
