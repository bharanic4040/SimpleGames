//
//  ContentView.swift
//  SimpleGames
//
//  Created by lavanya chennu on 24/06/26.
//

import SwiftUI

struct ContentView: View {

   
    @State private var board: [[Int]] = Array(
        repeating: Array(repeating: -1, count: 8),
        count: 8
    )
    // 0 = Blue, 1 = Purple, nil = ongoing
    @State private var winner: Int? = nil
    @State private var flipStateForAnimation: [[Bool]] = Array(
        repeating: Array(repeating: false, count: FLIP_CAPTURE_GAME_BOARD_SIZE),
        count: FLIP_CAPTURE_GAME_BOARD_SIZE
    )
    @State private var gameTurns: Int = 0
    @State private var whoseTurn: Int = 0
    @State private var bluePlayerScore = 0 // player 1
    @State private var purplePlayerScore = 0 // player 2
    
    
    var body: some View {
        GeometryReader { geometry in

            let spacing: CGFloat = 4
        
            let boardWidth = geometry.size.width - 20
            let tileSize = max(25, (boardWidth - spacing * 7) / 8)
        
               VStack {
                HStack{
                    Text("Capture Tiles")
                           .font(.system(size: 30, weight: .heavy, design: .rounded))
                           .foregroundStyle(
                               LinearGradient(
                                   colors: [.blue, .purple],startPoint: .leading, endPoint: .trailing
                               )
                           )
                           .shadow(color: .black.opacity(0.2), radius: 3, x: 0, y: 2)
                       
                    Button {
                        restartGame()
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "arrow.clockwise.circle.fill")
                            Text("Restart")
                        }
                        .font(.system(size: 15, weight: .bold, design: .rounded))
                        .padding(.horizontal, 22)
                        .padding(.vertical, 12)
                        .background(
                            LinearGradient(
                                colors: [.orange, .red],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .foregroundColor(.white)
                        .clipShape(Capsule())
                        .shadow(radius: 4)
                    }.padding(.horizontal, 10)
                }.padding(.top, 5).padding(.bottom, 10)
                  

                LazyVGrid(
                    columns: Array(
                        repeating: GridItem(.fixed(tileSize), spacing: spacing),
                        count: FLIP_CAPTURE_GAME_BOARD_SIZE
                    ),
                    spacing: spacing
                ) {
                    ForEach(0..<8, id: \.self) { row in
                        ForEach(0..<8, id: \.self) { col in
                            FlippableTile(
                                value: board[row][col],
                                shouldFlip: flipStateForAnimation[row][col]
                            ) {
                                flipTile(row: row, col: col)
                            }.id("\(row)-\(col)")
                            .frame(width: tileSize, height: tileSize)
                        }
                    }
                }//.padding(.top, 7)
                   // Spacer()

                    HStack(spacing: 24) {
                        Text("🔵 Blue: \(bluePlayerScore)")
                            .font(.headline)
                            .foregroundColor(.blue)

                        Text("🟣 Purple: \(purplePlayerScore)")
                            .font(.headline)
                            .foregroundColor(.purple)
                    }
                    .padding(.bottom, 17).padding(.top, 5)
                VStack(spacing: 12) {

                    Text("Rules")
                        .font(.headline)
                        .fontWeight(.bold)

                    Text("""
                    Each tile is 1 point. The rule is, if you surround enemy tiles with your tiles in any direction, you conquer all enemy tiles in between.
                    """)
                    .font(.footnote)
                    .multilineTextAlignment(.leading)
                    .foregroundStyle(.secondary)
                }
                .padding()
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .padding(.horizontal)
                .padding(.bottom, 40)
                //winner banner
                if let winner {
                    Text(
                        winner == 0
                        ? "🎉 Blue Player Won!"
                        : winner == 1
                            ? "🎉 Purple Player Won!"
                            : "🤝 Buddy, It's a Draw!"
                    )
                    .font(.system(size: 22, weight: .heavy, design: .rounded))
                    .foregroundStyle(winner == 0 ? .blue : .purple)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(
                                (winner == 0 ? Color.blue : Color.purple)
                                    .opacity(0.15)
                            )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(
                                winner == 0 ? .blue : .purple,
                                lineWidth: 2
                            )
                    )
                    .transition(.scale.combined(with: .opacity))
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .padding()
        .padding(.top, 10)
    }

    private func flipTile(row: Int, col: Int) {
        
        if (board[row][col] != -1) {
            return
        }
        if ( whoseTurn == 0 ) {
            changeBluePlayerScore(row: row, col: col)
        } else {
            changePurplePlayerScore(row: row, col: col)
        }
        SoundManager.shared.playFlip()
               
        flipStateForAnimation[row][col] = true
    
        // Trigger animation only if allowed
        if flipStateForAnimation[row][col] {
            withAnimation(.easeInOut(duration: 0.4)) {
                flipStateForAnimation[row][col].toggle()
            }
        }
    }
    
    private func changeBluePlayerScore(row: Int, col: Int) {
        if (board[row][col] != -1 || whoseTurn != 0) {
            return
        }
        board[row][col] = whoseTurn
        gameTurns += 1
        var change = 0
        flipStateForAnimation = Array(
            repeating: Array(repeating: false, count: FLIP_CAPTURE_GAME_BOARD_SIZE),
            count: FLIP_CAPTURE_GAME_BOARD_SIZE
        )
        let flips = getFlippedCellsOfEnemies(row: row, col: col, player: whoseTurn)
        for flip in flips {
            let x = flip[0]
            let y = flip[1]
            board[x][y] = whoseTurn
            flipStateForAnimation[x][y] = true
            change += 1
        }
        bluePlayerScore += 1 + change
        purplePlayerScore -= change
        whoseTurn = 1 - whoseTurn
        checkForGameOver()
    }
    
    private func changePurplePlayerScore(row: Int, col: Int) {
        if (board[row][col] != -1 || whoseTurn != 1) {
            return
        }
        board[row][col] = whoseTurn
        gameTurns += 1
        var change = 0
        flipStateForAnimation = Array(
            repeating: Array(repeating: false, count: FLIP_CAPTURE_GAME_BOARD_SIZE),
            count: FLIP_CAPTURE_GAME_BOARD_SIZE
        )
        let flips = getFlippedCellsOfEnemies(row: row, col: col, player: whoseTurn)
        for flip in flips {
            let x = flip[0]
            let y = flip[1]
            board[x][y] = whoseTurn
            flipStateForAnimation[x][y] = true
            change += 1
        }
        purplePlayerScore += change + 1
        bluePlayerScore -= change
        whoseTurn = 1 - whoseTurn
        checkForGameOver()
    }
    func getFlippedCellsOfEnemies(
        row: Int,
        col: Int,
        player: Int
    ) -> [[Int]] {
        
        let opponent = (player == 0) ? 1 : 0
        var flips: [[Int]] = []

        for (dx, dy) in ALL_MATRIX_DIRECTIONS {
            var x = row + dx
            var y = col + dy
            var tempFlips: [[Int]] = []

            // must first hit opponent pieces
            while x >= 0 && y >= 0 && x < FLIP_CAPTURE_GAME_BOARD_SIZE &&
                    y < FLIP_CAPTURE_GAME_BOARD_SIZE && board[x][y] == opponent {
                tempFlips.append([x, y])
                x += dx
                y += dy
            }
            // valid only if last piece is your piece
            if x >= 0 && y >= 0 && x < FLIP_CAPTURE_GAME_BOARD_SIZE &&
                y < FLIP_CAPTURE_GAME_BOARD_SIZE &&
                board[x][y] == player {
                flips.append(contentsOf: tempFlips)
            }
        }

        return flips
    }
    
    private func checkForGameOver() {
        if gameTurns == FLIP_CAPTURE_GAME_BOARD_SIZE * FLIP_CAPTURE_GAME_BOARD_SIZE {
            if bluePlayerScore > purplePlayerScore {
                winner = 0
            } else if purplePlayerScore > bluePlayerScore {
                winner = 1
            } else {
                winner = 2
            }
        }
    }
    
    private func restartGame() {
        gameTurns = 0
        bluePlayerScore = 0
        purplePlayerScore = 0
        whoseTurn = 0
        winner = nil
        board = Array(
            repeating: Array(repeating: -1, count: 8),
            count: 8
        )
        flipStateForAnimation = Array(
            repeating: Array(repeating: false, count: FLIP_CAPTURE_GAME_BOARD_SIZE),
            count: FLIP_CAPTURE_GAME_BOARD_SIZE
        )
    }
  }

struct FlippableTile: View {

    let value: Int

    let shouldFlip: Bool
    let action: () -> Void

    @State private var rotation: Double = 0

    private var tileColor: Color {
        value == 0 ? .blue : value == 1 ? .purple : .gray
    }

    var body: some View {
        RoundedRectangle(cornerRadius: 8)
            .fill(tileColor)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(.white.opacity(0.3), lineWidth: 1)
            )
            .rotation3DEffect(
                .degrees(rotation),
                axis: (x: 0, y: 1, z: 0)
            )
            .onChange(of: shouldFlip) { _, newValue in
                           if newValue {
                               withAnimation(.easeInOut(duration: 0.4)) {
                                   rotation += 180
                               }
                           }
            }
            .onTapGesture {
                  //had to remove the animation here or else it will animate the flip action twice, we already added animation in the onChange method above, so, only action method is enough here
                    action()
            }
    }
}

#Preview {
    ContentView()
}
