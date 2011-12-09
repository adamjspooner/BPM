jQuery ->
  API_URL = '/api'
  
  class Question extends Backbone.Model
    defaults:
      id: 0
      text: 'Question'
      answered: false
      skipped: false
      answers: [{
        text: 'Answer'
        explanations: [
          'Explanation',
          'Explanation'
        ]
      }, {
        text: 'Answer'
        explanations: [
          'Explanation',
          'Explanation'
        ]
      }]
  
  class QuestionView extends Backbone.View
    className: 'question'
    template: _.template($('#question-template').html())
    events:
      'click .skip': 'skip'
      'click .answers a': 'showExplanations'
      'click .explanations a': 'answerQuestion'
      'blur .explanations input': 'answerQuestionWithCustomExplanation'
      'keyup .explanations input': 'answerQuestionWithCustomExplanation'
    
    render: =>
      $(@el).attr('id', "question_#{@model.get('id')}")
      $(@el).append(@template(@model.toJSON()))
      @
    
    skip: (e) ->
      e.preventDefault()
      pause = 250
      previous = @
      question = $(@el)
      currQuestionID = @model.get('id')
      nextQuestionID = if currQuestionID is 4 then 1 else currQuestionID + 1
      
      # Damn handy
      # [classes...] = e.srcElement.className.split(' ')
      
      @model.set
        skipped: true
      
      doIt = ->
        question.addClass('skipped')
        previous.appendNewQuestion nextQuestionID
      
      doIt()
      
      # TODO: find double-posting bug in the following
      
      # hide explanations if they're shown
      # if previous.$('.explanations:visible').length isnt 0
      #   previous.$('.explanations').slideUp ->
      #     # and remove the selected class from the button
      #     previous.$('.selected').removeClass('selected')
      #     
      #     # skip and show new question
      #     doIt()
      # 
      # # otherwise, show the new question
      # else
      #   doIt()
    
    newQuestion: (questionID, callback) ->
      $.getJSON "#{API_URL}/question/#{questionID}.json", (data) ->
          question = new Question data[0]
          callback question
    
    appendNewQuestion: (questionID) ->
      parent = $(@el).parent()
      
      # get a new question from the server
      @newQuestion questionID, (question) ->
        questionView = new QuestionView
          model: question
        
        # append it to the parent container
        parent.append questionView.render().el
    
    showExplanations: (e) ->
      e.preventDefault()
      pause = 250
      previous = @
      link = e.srcElement
      $link = $(link)
      
      doIt = ->
        $link.addClass('selected')
        $(link.hash).slideDown()
      
      # slideUp when the explanations are shown
      if $link.hasClass('selected')
        $(link.hash).slideUp pause, ->
          $link.removeClass('selected')
      
      # don't pause when an answer hasn't been selected
      else if previous.$('.selected').length is 0
        doIt()
      
      # othwerise, unless selecting the selected
      else if ! $link.hasClass('selected')
        # hide explanations, show appropriate afterwards
        previous.$('.explanations').slideUp pause, ->
          # make it feel fluid
          setTimeout ->
            # remove selected class from link
            previous.$('.selected').removeClass('selected')
            
            doIt()
            
          , pause
    
    reAnswerQuestion: (question) ->
      question.addClass('reanswering')
      question.find('.answer').hide()
      question.find('.answers').show()
    
    updateQuestionWithAnswerAndExplanation: (question, answer, explanation) ->
      answerWrapper = question.find('.answer')
      questionID = question.attr('id')
      currQuestionID = @model.get('id')
      nextQuestionID = if currQuestionID is 4 then 1 else currQuestionID + 1
      
      question.removeClass('skipped')
      answerWrapper.hide()
      answerWrapper.empty()
      
      answerLink = $("<a href='##{questionID}'>#{answer}</a>").click (e) =>
        e.preventDefault()
        @reAnswerQuestion(question)
      
      answerWrapper.append(answerLink).append("#{explanation}")
      
      question.find('.explanations:visible').slideUp =>
        question.find('.answers').hide()
        question.find('.selected').removeClass('selected')
        answerWrapper.show()
        
        if not question.hasClass('reanswering')
          @appendNewQuestion(nextQuestionID)
        else
          question.removeClass('reanswering')
    
    answerQuestion: (e) ->
      e.preventDefault()
      question = $(e.srcElement).parents('.question')
      answer = question.find('.selected').html()
      explanation = e.srcElement.innerHTML
      
      # send answer and explanation to the server
      # update the interface after a successful post
      @updateQuestionWithAnswerAndExplanation question, answer, explanation
    
    answerQuestionWithCustomExplanation: (e) ->
      e.preventDefault()
      
      if e.keyCode is 13
        question = $(e.srcElement).parents('.question')
        answer = question.find('.selected').html()
        explanation = e.srcElement.value
        
        # send answer and explanation to the server
        # update the interface after a successful post
        @updateQuestionWithAnswerAndExplanation question, answer, explanation
  
  class Questions extends Backbone.Collection
    model: Question
    url: "#{API_URL}/questions.json"
  
  # class QuestionsView extends QuestionView
  #   template: _.template($('#questions-template').html())
  #   
  #   initialize: ->
  #     @collection.bind('reset', @render)
  #   
  #   render: =>
  #     $(@el).html(@template({}))
  #     questions = @.$('#questions')
  #     
  #     @collection.each (question) ->
  #       questionsView = new QuestionsView
  #         model: question
  #         collection: question.collection
  #       
  #       questions.append(questionsView.render().el)
  #     
  #     @
  # 
  # class QuestionsRouter extends Backbone.Router
  #   routes:
  #     '': 'index'
  #   
  #   initialize: ->
  #     questions = new Questions
  #     questions.fetch()
  #     
  #     @allQuestionsView = new AllQuestionsView
  #       collection: questions
  #   
  #   index: =>
  #     container = $('#container')
  #     container.empty()
  #     container.append(@allQuestionsView.render().el)
  
  class QuestionsRouter extends Backbone.Router
    routes:
      '': 'index'
    
    initialize: ->
      # questions = new Questions
      # questions.fetch()
    
    index: ->
      # start with the first question
      $.getJSON "#{API_URL}/question/1.json", (data) ->
        @question = new Question data[0]
        questionView = new QuestionView
          model: @question
        
        questions = $('#questions')
        
        questions.empty()
        questions.append(questionView.render().el)
  
  # start the application
  questionsRouter = new QuestionsRouter
  Backbone.history.start
    pushState: true