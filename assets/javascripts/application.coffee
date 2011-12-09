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
      $(@el).attr('id', "question_#{@model.get('id') + 1}")
      $(@el).append(@template(@model.toJSON()))
      @
    
    skip: (e) ->
      console.log "skip: #{@model.toJSON()}"
      
      e.preventDefault()
      pause = 250
      previous = @
      
      # Damn handy
      # [classes...] = e.srcElement.className.split(' ')
      
      @model.set
        skipped: true
      
      doIt = ->
        $(@model).addClass('skipped')
        previous.appendNewQuestion(previous.model.get('id') + 1)
      
      # hide explanations if they're shown
      if previous.$('.explanations').length is 0
        previous.$('.explanations').slideUp ->
          # and remove the selected class from the button
          previous.$('.selected').removeClass('selected')
          
          # skip and show new question
          doIt()
      
      # otherwise, show the new question
      else
        doIt()
    
    appendNewQuestion: (question_id) ->
      console.log 'appendNewQuestion'
      
      question = new Question
        id: question_id
      
      questionView = new QuestionView
        model: question
      
      $(@el).parent().append(questionView.render().el)
    
    showExplanations: (e) ->
      e.preventDefault()
      pause = 250
      previous = @
      link = e.srcElement
      $link = $(link)
      
      doIt = ->
        $link.addClass('selected')
        $(link.hash).slideDown()
      
      # don't pause when an answer hasn't been selected
      if previous.$('.selected').length is 0
        doIt()
      
      # othwerise, unless selecting the selected
      else if ! $link.hasClass('.selected')
        # hide explanations, show appropriate afterwards
        previous.$('.explanations').slideUp pause, ->
          # make it feel fluid
          setTimeout ->
            # remove selected class from link
            previous.$('.selected').removeClass('selected')
            
            doIt()
            
          , pause
    
    answerQuestion: (e) ->
      console.log "answerQuestion: #{@model.toJSON()}"
      
      e.preventDefault()
      
      # post answer to server with explanation
      # set question to answered?
      # get a new question from the server
      # render the new question
      # append it to the questions container
    
    answerQuestionWithCustomExplanation: (e) ->
      console.log "answerQuestionWithCustomExplanation: #{@model.toJSON()}"
      
      e.preventDefault()
      
      if e.keyCode is 13
        console.log 'pressed return'
      
      # post answer to server with custom explanation
      # set question to answered?
      # get a new question from the server
      # render the new question
      # append it to the questions container
  
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
      # 
      # @firstQuestion = questions.at(0)
      
      @question = new Question
    
    index: ->
      questions = $('#questions')
      
      questionView = new QuestionView
        model: @question
      
      questions.append(questionView.render().el)
  
  questionsRouter = new QuestionsRouter
  Backbone.history.start
    pushState: true
  
  # question1 = new Question
  #   id: 123
  #   text: 'Where are you, career-wise?'
  #   answers: [{
  #     text: 'Working'
  #     explanations: [
  #       "I'm working for The Man.",
  #       "I'm starting my own company.",
  #       "I'm freelancing."
  #     ]
  #   }, {
  #     text: 'Studying'
  #     explanations: [
  #       "I'm getting my bachelor's.",
  #       "I'm working on my master's.",
  #       "I'm in high school."
  #     ]
  #   }, {
  #     text: 'Not working'
  #     explanations: [
  #       "I'm between jobs.",
  #       "I'm living in my parent's basement playing WoW.",
  #       "I'm a bum."
  #     ]
  #   }]
  # 
  # question2 = new Question
  #   id: 124
  #   text: 'Are some human lives worth more?'
  #   answers: [{
  #     text: 'Yes'
  #     explanations: [
  #       'I think certain people are just more important to society than others.',
  #       'When it comes down to it, I would choose my family and loved ones over others.',
  #       'This is selfish of me, but my own life is worth more to me than others.'
  #     ]
  #   }, {
  #     text: 'No'
  #     explanations: [
  #       'Some explanation.',
  #       'Another explanation.'
  #     ]
  #   }]
  # 
  # questionView = new QuestionView
  #   model: question1
  #   
  # $('#questions').append(questionView.render().el)
