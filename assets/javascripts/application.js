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
        skipped: false,
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
        var currQuestionID, doIt, nextQuestionID, pause, previous, question;
        e.preventDefault();
        pause = 250;
        previous = this;
        question = $(this.el);
        currQuestionID = this.model.get('id');
        nextQuestionID = currQuestionID === 4 ? 1 : currQuestionID + 1;
        this.model.set({
          skipped: true
        });
        doIt = function() {
          question.addClass('skipped');
          return previous.appendNewQuestion(nextQuestionID);
        };
        return doIt();
      };
      QuestionView.prototype.newQuestion = function(questionID, callback) {
        return $.getJSON("" + API_URL + "/question/" + questionID + ".json", function(data) {
          var question;
          question = new Question(data[0]);
          return callback(question);
        });
      };
      QuestionView.prototype.appendNewQuestion = function(questionID) {
        var parent;
        parent = $(this.el).parent();
        return this.newQuestion(questionID, function(question) {
          var questionView;
          questionView = new QuestionView({
            model: question
          });
          return parent.append(questionView.render().el);
        });
      };
      QuestionView.prototype.showExplanations = function(e) {
        var $link, doIt, link, pause, previous;
        e.preventDefault();
        pause = 250;
        previous = this;
        link = e.srcElement;
        $link = $(link);
        doIt = function() {
          $link.addClass('selected');
          return $(link.hash).slideDown();
        };
        if ($link.hasClass('selected')) {
          return $(link.hash).slideUp(pause, function() {
            return $link.removeClass('selected');
          });
        } else if (previous.$('.selected').length === 0) {
          return doIt();
        } else if (!$link.hasClass('selected')) {
          return previous.$('.explanations').slideUp(pause, function() {
            return setTimeout(function() {
              previous.$('.selected').removeClass('selected');
              return doIt();
            }, pause);
          });
        }
      };
      QuestionView.prototype.reAnswerQuestion = function(question) {
        question.addClass('reanswering');
        question.find('.answer').hide();
        return question.find('.answers').show();
      };
      QuestionView.prototype.updateQuestionWithAnswerAndExplanation = function(question, answer, explanation) {
        var answerLink, answerWrapper, currQuestionID, nextQuestionID, questionID;
        answerWrapper = question.find('.answer');
        questionID = question.attr('id');
        currQuestionID = this.model.get('id');
        nextQuestionID = currQuestionID === 4 ? 1 : currQuestionID + 1;
        question.removeClass('skipped');
        answerWrapper.hide();
        answerWrapper.empty();
        answerLink = $("<a href='#" + questionID + "'>" + answer + "</a>").click(__bind(function(e) {
          e.preventDefault();
          return this.reAnswerQuestion(question);
        }, this));
        answerWrapper.append(answerLink).append("" + explanation);
        return question.find('.explanations:visible').slideUp(__bind(function() {
          question.find('.answers').hide();
          question.find('.selected').removeClass('selected');
          answerWrapper.show();
          if (!question.hasClass('reanswering')) {
            return this.appendNewQuestion(nextQuestionID);
          } else {
            return question.removeClass('reanswering');
          }
        }, this));
      };
      QuestionView.prototype.answerQuestion = function(e) {
        var answer, explanation, question;
        e.preventDefault();
        question = $(e.srcElement).parents('.question');
        answer = question.find('.selected').html();
        explanation = e.srcElement.innerHTML;
        return this.updateQuestionWithAnswerAndExplanation(question, answer, explanation);
      };
      QuestionView.prototype.answerQuestionWithCustomExplanation = function(e) {
        var answer, explanation, question;
        e.preventDefault();
        if (e.keyCode === 13) {
          question = $(e.srcElement).parents('.question');
          answer = question.find('.selected').html();
          explanation = e.srcElement.value;
          return this.updateQuestionWithAnswerAndExplanation(question, answer, explanation);
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
      QuestionsRouter.prototype.initialize = function() {};
      QuestionsRouter.prototype.index = function() {
        return $.getJSON("" + API_URL + "/question/1.json", function(data) {
          var questionView, questions;
          this.question = new Question(data[0]);
          questionView = new QuestionView({
            model: this.question
          });
          questions = $('#questions');
          questions.empty();
          return questions.append(questionView.render().el);
        });
      };
      return QuestionsRouter;
    })();
    questionsRouter = new QuestionsRouter;
    return Backbone.history.start({
      pushState: true
    });
  });
}).call(this);
