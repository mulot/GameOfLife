//
//  GameOfLife.swift
//  GameOfLife
//
//  Created by Julien Mulot on 19/12/2021.
//

import Foundation

var defaultBirthRule = [3]
var defaultSurvivalRule = [2,3]

func blankGrid(sizeX: Int, sizeY: Int) -> [[Int]] {
    return [[Int]].init(repeating: [Int].init(repeating: 0, count: sizeX), count: sizeY)
}

func randomGrid(sizeX: Int, sizeY: Int) -> [[Int]] {
    var grid = blankGrid(sizeX: sizeX, sizeY: sizeY)
    
    for y in (0...sizeY-1) {
        for x in (0...sizeX-1) {
            grid[y][x] = Int.random(in: 0...1)
        }
    }
    return grid
}

func evolve(_ grid: [[Int]], birth: [Int] = defaultBirthRule, survival: [Int] = defaultSurvivalRule) -> [[Int]] {
    let sizeY = grid.count
    let sizeX = grid[0].count
    var newGrid = grid
    
    for y in (0...sizeY-1) {
        for x in (0...sizeX-1) {
            var neighbors = 0
            if (x > 0) {
                if (grid[y][x-1] == 1) {
                    neighbors += 1
                }
                if (y > 0) {
                    if (grid[y-1][x-1] == 1) {
                        neighbors += 1
                    }
                }
                if (y < sizeY-1) {
                    if (grid[y+1][x-1] == 1) {
                        neighbors += 1
                    }
                }
            }
            if (x < sizeX-1) {
                if (grid[y][x+1] == 1) {
                    neighbors += 1
                }
                if (y > 0) {
                    if (grid[y-1][x+1] == 1) {
                        neighbors += 1
                    }
                }
                if (y < sizeY-1) {
                    if (grid[y+1][x+1] == 1) {
                        neighbors += 1
                    }
                }
            }
            if (y > 0) {
                if (grid[y-1][x] == 1) {
                    neighbors += 1
                }
            }
            if (y < sizeY-1) {
                if (grid[y+1][x] == 1) {
                    neighbors += 1
                }
            }
            if (grid[y][x] == 1) {
                var result = 0
                for s in survival {
                    if (neighbors == s) {
                        result = 1
                    }
                }
                newGrid[y][x] = result
            }
            else if (grid[y][x] == 0) {
                for b in birth {
                if (neighbors == b) {
                    newGrid[y][x] = 1
                }
                }
            }
            //print("X: \(x+1) Y: \(y+1) has value: \(grid[y][x]) and has \(neighbors) neighbors > new value \(newGrid[y][x])")
        }
    }
    return newGrid
}
