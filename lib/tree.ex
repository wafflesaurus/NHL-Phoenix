defmodule Tree do

	use Application

	def start(_type, _args) do
		# pool_config = [mfa: {SampleWorker, :start_link, []}, size: 5]
		IO.inspect "Start"
		IO.inspect self
		start_pool
	end

	def start_pool do
		Tree.Super.start_link
	end

end
