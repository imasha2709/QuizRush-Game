import SwiftUI

struct QuizRushView: View {

    @StateObject private var vm = QuizViewModel()

    var body: some View {

        NavigationStack {

            VStack {

                if vm.isLoading {

                    Spacer()

                    ProgressView("Loading Questions...")

                    Spacer()

                }

                else if vm.hasError {

                    Spacer()

                    Image(systemName: "wifi.slash")
                        .font(.system(size: 60))
                        .foregroundColor(.red)

                    Text("Something went wrong")

                    Button("Try Again") {

                        vm.loadQuestions()

                    }
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)

                    Spacer()

                }

                else if vm.finished {

                    Spacer()

                    Image(systemName: "star.fill")
                        .font(.system(size: 70))
                        .foregroundColor(.yellow)

                    Text("Game Finished")
                        .font(.largeTitle)

                    Text("Score: \(vm.score)/10")
                        .font(.title2)

                    Button("Play Again") {

                        vm.restart()

                    }
                    .padding()
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(12)

                    Spacer()

                }

                else {

                    VStack(spacing: 20) {

                        Text("Question \(vm.currentQuestion + 1) / 10")
                            .font(.headline)

                        Text(vm.questions[vm.currentQuestion].question)
                            .font(.title3)
                            .multilineTextAlignment(.center)
                            .padding()

                        ForEach(vm.questions[vm.currentQuestion].answers, id: \.self) { answer in

                            Button {

                                withAnimation(.spring()) {

                                    vm.checkAnswer(answer)

                                }

                            } label: {

                                Text(answer)

                                    .frame(maxWidth: .infinity)

                                    .padding()

                                    .background(Color.blue)

                                    .foregroundColor(.white)

                                    .cornerRadius(12)

                                    .shadow(radius: 4)

                            }

                        }

                        Spacer()

                        Text("Score : \(vm.score)")
                            .font(.title2)

                    }
                    .padding()

                }

            }
            .navigationTitle("Quiz Rush")
            .task {

                vm.loadQuestions()

            }

        }

    }

}