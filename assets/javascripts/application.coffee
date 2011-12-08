jQuery ->
  API_URL = '/api'
  
  class Question extends Backbone.Model
    defaults:
      id: 0
      text: 'Question'
      answered: false
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
      console.log "skip: #{@model.toJSON()}"
      
      e.preventDefault()
      
      # get a new question from the server
      # render the new question
      # append it to the questions container
    
    showExplanations: (e) ->
      console.log "showExplanations: #{@model.toJSON()}"
      console.log $(@)
      
      e.preventDefault()
      
      # add selected class to clicked anchor
      # slideUp explanations not related to this answer
      # slideDown associated explanations
    
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
