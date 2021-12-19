//
//  GameOfLife.swift
//  GameOfLife
//
//  Created by Julien Mulot on 19/12/2021.
//

import Foundation

func randomizeGrid(_ grid: [[Int]]) -> [[Int]] {
    var newGrid = grid
    let sizeY = grid.count
    let sizeX = grid[0].count
    
    for y in (0...sizeY-1) {
        for x in (0...sizeX-1) {
            newGrid[y][x] = Int.random(in: 0...1)
        }
    }
    return newGrid
}

func evolve(_ grid: [[Int]]) -> [[Int]] {
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
                if ((neighbors < 2) || (neighbors > 3)) {
                    newGrid[y][x] = 0
                }
            }
            else if (grid[y][x] == 0) {
                if (neighbors == 3) {
                    newGrid[y][x] = 1
                }
            }
            //print("X: \(x+1) Y: \(y+1) has value: \(grid[y][x]) and has \(neighbors) neighbors > new value \(newGrid[y][x])")
        }
    }
    return newGrid
}
