class CraqValidator
  attr_reader :errors

  def initialize(questions, answers)
    @questions = questions
    @answers = answers
    @errors = nil
  end

  def valid?
    # does not validate again if it already
    return errors.empty? unless errors.nil?

    validate

    errors.empty?
  end

  private

  attr_reader :questions, :answers

  def validate
    @errors = {}

    return not_answered_for_all if answers.nil?

    questions.each_with_index do |question, i|
      next unless valid_question?(question, i)

      answer = answers[:"q#{i}"]

      @completed = answer && question[:options][answer][:complete_if_selected]
    end
  end

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

  def valid_question_after_completed?(question_index, answer)
    return true if answer.nil?

    add_error(:"q#{question_index}", :already_finished)

    false
  end

  def valid_question?(question, question_index)
    answer = answers[:"q#{question_index}"]

    return valid_question_after_completed?(question_index, answer) if @completed

    return true if answer && question[:options][answer]

    error = answer.nil? ? :empty : :wrong

    add_error(:"q#{question_index}", error)

    false
  end
end
