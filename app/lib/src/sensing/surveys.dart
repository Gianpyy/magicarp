import 'package:research_package/research_package.dart';

// The [_Surveys] class is instantiated and made accessible
final surveys = _Surveys();

/// Class that manages access to different types of surveys
class _Surveys {
  // Demographic survey
  final Survey _demographics = _DemographicSurvey();
  Survey get demographics => _demographics;

  //Daily recap survey
  final Survey _dailyRecap = _DayRecapSurvey();
  Survey get dailyRecap => _dailyRecap;
}

/// An interface for an survey from the RP package.
abstract class Survey {
  /// The title of this survey.
  String get title;

  /// A short description (one line) of this survey
  String get description;

  /// How many minutes will it take to do this survey?
  int get minutesToComplete;

  /// The survey to fill out.
  RPTask get survey;
}

/// Implementation of the demographic survey
class _DemographicSurvey implements Survey {
  @override
  String get title => "Demographics";

  @override
  String get description => "A short 4-item survey on your background";

  @override
  int get minutesToComplete => 2;

  // Responses formats for demographic survey questions
  final RPChoiceAnswerFormat _sexChoices = RPChoiceAnswerFormat(
      answerStyle: RPChoiceAnswerStyle.SingleChoice,
      choices: [
        RPChoice(text: "Female", value: 1),
        RPChoice(text: "Male", value: 2),
        RPChoice(text: "Other", value: 3),
        RPChoice(text: "Prefer not to say", value: 4),
      ]
  );

  final RPChoiceAnswerFormat _ageChoices = RPChoiceAnswerFormat(
      answerStyle: RPChoiceAnswerStyle.SingleChoice,
      choices: [
        RPChoice(text: "Under 20", value: 1),
        RPChoice(text: "20-29", value: 2),
        RPChoice(text: "30-39", value: 3),
        RPChoice(text: "40-49", value: 4),
        RPChoice(text: "50-59", value: 5),
        RPChoice(text: "60-69", value: 6),
        RPChoice(text: "70-79", value: 7),
        RPChoice(text: "80-89", value: 8),
        RPChoice(text: "90 and above", value: 9),
        RPChoice(text: "Prefer not to say", value: 10),
      ]
  );

  final RPChoiceAnswerFormat _medicalChoices = RPChoiceAnswerFormat(
      answerStyle: RPChoiceAnswerStyle.MultipleChoice,
      choices: [
        RPChoice(text: "None", value: 1),
        RPChoice(text: "Asthma", value: 2),
        RPChoice(text: "Cystic fibrosis", value: 3),
        RPChoice(text: "COPD/Emphysema", value: 4),
        RPChoice(text: "Pulmonary fibrosis", value: 5),
        RPChoice(text: "Other lung disease  ", value: 6),
        RPChoice(text: "High Blood Pressure", value: 7),
        RPChoice(text: "Angina", value: 8),
        RPChoice(
            text: "Previous stroke or Transient ischaemic attack  ", value: 9),
        RPChoice(text: "Valvular heart disease", value: 10),
        RPChoice(text: "Previous heart attack", value: 11),
        RPChoice(text: "Other heart disease", value: 12),
        RPChoice(text: "Diabetes", value: 13),
        RPChoice(text: "Cancer", value: 14),
        RPChoice(text: "Previous organ transplant", value: 15),
        RPChoice(text: "HIV or impaired immune system", value: 16),
        RPChoice(text: "Other long-term condition", value: 17),
        RPChoice(text: "Prefer not to say", value: 18),
      ]
  );

  final RPChoiceAnswerFormat _smokeChoices = RPChoiceAnswerFormat(
      answerStyle: RPChoiceAnswerStyle.SingleChoice,
      choices: [
        RPChoice(text: "Never smoked", value: 1),
        RPChoice(text: "Ex-smoker", value: 2),
        RPChoice(text: "Current smoker (less than once a day", value: 3),
        RPChoice(text: "Current smoker (1-10 cigarettes pr day", value: 4),
        RPChoice(text: "Current smoker (11-20 cigarettes pr day", value: 5),
        RPChoice(text: "Current smoker (21+ cigarettes pr day", value: 6),
        RPChoice(text: "Prefer not to say", value: 7),
      ])
  ;

  @override
  RPTask get survey => RPOrderedTask(
      identifier: "demo_survey",
      steps: [
        RPQuestionStep(
            identifier: "demo_1",
            title: "Which is your biological sex?",
            answerFormat: _sexChoices,
        ),
        RPQuestionStep(
            identifier: "demo_2",
            title: "How old are you?",
            answerFormat: _ageChoices,
        ),
        RPQuestionStep(
            identifier: "demo_3",
            title: "Do you have any medical conditions?",
            answerFormat: _medicalChoices,
        ),
        RPQuestionStep(
            identifier: "demo_4",
            title: "Do you, or have you, ever smoked (including e-cigarettes)?",
            answerFormat: _smokeChoices,
        ),
      ]
  );
}

/// Implementation of a survey about a daily recap
class _DayRecapSurvey extends Survey {

  @override
  String get title => "How did your day go?";

  @override
  String get description => "Take a minute to fill out this survey about your day";

  @override
  int get minutesToComplete => 1;

  // Responses format for this survey
  final RPImageChoiceAnswerFormat _satisfaction = RPImageChoiceAnswerFormat(
      choices: [
        RPImageChoice(
          imageUrl: 'assets/img/very-sad.png',
          value: -2,
          description: 'Feeling very sad',
        ),
        RPImageChoice(
          imageUrl: 'assets/img/sad.png',
          value: -1,
          description: 'Feeling sad',
        ),
        RPImageChoice(
          imageUrl: 'assets/img/ok.png',
          value: 0,
          description: 'Feeling ok',
        ),
        RPImageChoice(
          imageUrl: 'assets/img/happy.png',
          value: 1,
          description: 'Feeling happy',
        ),
        RPImageChoice(
          imageUrl: 'assets/img/very-happy.png',
          value: 2,
          description: 'Feeling very happy',
        ),
      ]
  );

  @override
  RPTask get survey => RPOrderedTask(
      identifier: "daily_recap_survey",
      steps: [
        RPQuestionStep(
            identifier: "daily_1",
            title: "How do you feel about today's day?",
            answerFormat: _satisfaction
        ),
      ],
  );
}