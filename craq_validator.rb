class CraqValidator
  attr_reader :errors

  def initialize(questions, answers)
    @questions = questions
    @answers = answers
    @errors = {}
  end

  def valid?
    return not_answered_for_all if answers.nil?

    questions.each_with_index do |question, i|
      answer = answers[:"q#{i}"]

      add_error(:"q#{i}", :already_finished) && next if answer && @finished

      next if @finished

      add_error(:"q#{i}", :empty) && next if answer.nil?

      add_error(:"q#{i}", :wrong) && next if question[:options][answer].nil?

      @finished = question[:options][answer][:complete_if_selected]
    end

    return true if errors.empty?

    false
  end

  private

  attr_reader :questions, :answers

  def add_error(question_number, error)
    case error
    when :empty
      errors[question_number] = "was not answered"
    when :wrong
      errors[question_number] = "has an answer that is not on the list of valid answers"
    when :already_finished
      errors[question_number] = "was answered even though a previous response indicated "\
                                "that the questions were complete"
    end
  end

  def not_answered_for_all
    questions.size.times do |i|
      add_error(:"q#{i}", :empty)
    end

    false
  end
end
