(function() {
  var __hasProp = Object.prototype.hasOwnProperty, __extends = function(child, parent) {
    for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; }
    function ctor() { this.constructor = child; }
    ctor.prototype = parent.prototype;
    child.prototype = new ctor;
    child.__super__ = parent.prototype;
    return child;
  }, __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };
  jQuery(function() {
    var API_URL, Question, QuestionView, Questions, QuestionsRouter, questionsRouter;
    API_URL = '/api';
    Question = (function() {
      __extends(Question, Backbone.Model);
      function Question() {
        Question.__super__.constructor.apply(this, arguments);
      }
      Question.prototype.defaults = {
        id: 0,
        text: 'Question',
        answered: false,
        answers: [
          {
            text: 'Answer',
            explanations: ['Explanation', 'Explanation']
          }, {
            text: 'Answer',
            explanations: ['Explanation', 'Explanation']
          }
        ]
      };
      return Question;
    })();
    QuestionView = (function() {
      __extends(QuestionView, Backbone.View);
      function QuestionView() {
        this.render = __bind(this.render, this);
        QuestionView.__super__.constructor.apply(this, arguments);
      }
      QuestionView.prototype.className = 'question';
      QuestionView.prototype.template = _.template($('#question-template').html());
      QuestionView.prototype.events = {
        'click .skip': 'skip',
        'click .answers a': 'showExplanations',
        'click .explanations a': 'answerQuestion',
        'blur .explanations input': 'answerQuestionWithCustomExplanation',
        'keyup .explanations input': 'answerQuestionWithCustomExplanation'
      };
      QuestionView.prototype.render = function() {
        $(this.el).attr('id', "question_" + (this.model.get('id')));
        $(this.el).append(this.template(this.model.toJSON()));
        return this;
      };
      QuestionView.prototype.skip = function(e) {
        console.log("skip: " + (this.model.toJSON()));
        return e.preventDefault();
      };
      QuestionView.prototype.showExplanations = function(e) {
        console.log("showExplanations: " + (this.model.toJSON()));
        console.log($(this));
        return e.preventDefault();
      };
      QuestionView.prototype.answerQuestion = function(e) {
        console.log("answerQuestion: " + (this.model.toJSON()));
        return e.preventDefault();
      };
      QuestionView.prototype.answerQuestionWithCustomExplanation = function(e) {
        console.log("answerQuestionWithCustomExplanation: " + (this.model.toJSON()));
        e.preventDefault();
        if (e.keyCode === 13) {
          return console.log('pressed return');
        }
      };
      return QuestionView;
    })();
    Questions = (function() {
      __extends(Questions, Backbone.Collection);
      function Questions() {
        Questions.__super__.constructor.apply(this, arguments);
      }
      Questions.prototype.model = Question;
      Questions.prototype.url = "" + API_URL + "/questions.json";
      return Questions;
    })();
    QuestionsRouter = (function() {
      __extends(QuestionsRouter, Backbone.Router);
      function QuestionsRouter() {
        QuestionsRouter.__super__.constructor.apply(this, arguments);
      }
      QuestionsRouter.prototype.routes = {
        '': 'index'
      };
      QuestionsRouter.prototype.initialize = function() {
        return this.question = new Question;
      };
      QuestionsRouter.prototype.index = function() {
        var questionView, questions;
        questions = $('#questions');
        questionView = new QuestionView({
          model: this.question
        });
        return questions.append(questionView.render().el);
      };
      return QuestionsRouter;
    })();
    questionsRouter = new QuestionsRouter;
    return Backbone.history.start({
      pushState: true
    });
  });
}).call(this);
