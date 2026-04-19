#pragma once
#include "Piece.h"
#include <string>

class Board;

class Horse : public Piece
{
public:
    Horse(int x, int y, int color);
    bool canMove(int toX, int toY, const Board &board) const override;
    std::string getTypeName() const override;
};
