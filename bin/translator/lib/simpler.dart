// import 'dart:io';
// import 'dart:convert';
// //import 'package:openai_dart/openai_dart.dart';
// //import 'package:args/args.dart';

// const OAI_BASE_URL = "http://localhost:9099/v1";
// const API_KEY  = "***";
// const COMPLETION_MODEL = "llamaindex_pipeline";

// // final openAIClient = OpenAIClient(
// //   baseUrl: OAI_BASE_URL,
// //   apiKey: API_KEY,
// // );

// void main (List<String> arguments) async {
//   // final parser = ArgParser()
//   //   ..addOption('prompt', abbr: 'p', defaultsTo: 'Endlagen');

//   //final argResults = parser.parse(arguments);
//   //final prompt = argResults['prompt'];

//   // final res = await openAIClient.createChatCompletionStream(
//   //   request: CreateChatCompletionRequest(
//   //     model: ChatCompletionModel.modelId(COMPLETION_MODEL),
//   //     messages: [
//   //       ChatCompletionMessage.user(
//   //         content: ChatCompletionUserMessageContent.string(prompt),
//   //       ),
//   //     ],
//   //   ),
//   // );

//   // final buffer = StringBuffer();
//   // await stdout.addStream(res.map((choice) {
//   //   final content = choice.choices.first.delta.content;
//   //   if (content != null) {
//   //     buffer.write(content);
//   //     return utf8.encode(content);
//   //   }
//   //   return [];
//   // }));
// }