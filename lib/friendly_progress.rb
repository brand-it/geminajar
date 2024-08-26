# frozen_string_literal: true

# Format string for the progress bar, displaying title, activity, bar,
# current/total progress, percentage, and estimated time remaining.
#
# FriendlyProgress.create(total: 100, title: 'Loading Data') do |progress|
#   100.times do
#     sleep(0.1)   # Simulate work being done
#     progress.increment(1)
#   end
# end
class FriendlyProgress
  FORMAT = '%t %a %B %c/%C %p%% %E'

  # Creates a new FriendlyProgress instance and initializes the progress bar.
  # If a block is given, the progress bar is yielded to the block, which is executed,
  # and the progress bar is automatically finished when the block ends.
  #
  # @param total [Integer] The total amount of work to be completed.
  # @param title [String] The title displayed on the progress bar.
  # @return [FriendlyProgress, Object] The FriendlyProgress instance if no block is given,
  #                                    otherwise the result of the block.
  def self.create(total:, title: 'Progress')
    progress_bar = new(ProgressBar.create(title:, total:, format: FORMAT))

    if block_given?
      result = yield(progress_bar)
      progress_bar.finish
      result
    else
      progress_bar
    end
  end

  # Initializes a new instance of FriendlyProgress.
  # @param progress_bar [ProgressBar] The progress bar instance to manage.
  def initialize(progress_bar)
    @progress_bar = progress_bar
    @progress = 0
  end

  # Increments the progress bar by the specified amount.
  # If the increment results in invalid progress, the progress bar is automatically finished.
  #
  # @param amount [Integer] The amount by which to increment the progress bar.
  def increment(amount)
    @progress += amount
    @progress_bar.progress = @progress
  rescue ProgressBar::InvalidProgressError
    finish
  end

  def finish
    @progress_bar&.finish
  end
end
