"""Writes game/data/levels.tres (the levels of the level mode, G17) from the table below.

Each level: goal (SCORE, TRIOS or GOLD), goal count, goal symbol, pieces, seed, and the
starting grid, one string per row (legend in game/data/level_definition.gd). After a change,
run `make test`: test/unit/level_game_test.gd checks that a simple robot wins every level, and
prints the pieces it had left (aim for 3 or 4: the level is tight but fair).

Usage: python3 -I tools/generate_levels.py
"""

from pathlib import Path

OUTPUT = Path(__file__).resolve().parent.parent / "game" / "data" / "levels.tres"

levels = [
 ("SCORE", 300, 0, 10, 11, ["........","........","........","........","........","........","........","........"]),
 ("TRIOS", 3, 4, 14, 12, ["........","........","........","..4..4..","........","........","4......4","........"]),
 ("GOLD", 0, 0, 9, 13, [".......b","........","........","...a....","........","d.......","......c.","1.0.2.3."]),
 ("SCORE", 600, 0, 10, 14, ["........","........","........","........","........","0101.0..","1010.101","0101.010"]),
 ("TRIOS", 4, 0, 16, 15, ["........","........","0......0","........","........","...00...","........","2.3.1.3."]),
 ("GOLD", 0, 0, 10, 16, ["........","b.....d.","........","........","....e...","..c.....","........",".1.2.a.3"]),
 ("SCORE", 600, 0, 12, 17, ["........","........","........","........","...##...","........","........","#......#"]),
 ("GOLD", 0, 0, 11, 18, ["a......e","........","..#.....","........",".....d..","........","#.......","..b...#."]),
 ("TRIOS", 5, 1, 16, 19, ["........","........","........","..AB....","........","....CA..","........","1......1"]),
 ("GOLD", 0, 0, 11, 21, ["e......d","........","...#....","..a.....","........","....c...","..AB....","#...D..b"]),
]
out = ['[gd_resource type="Resource" script_class="LevelSet" format=3]','',
 '[ext_resource type="Script" path="res://game/data/level_set.gd" id="1_set"]',
 '[ext_resource type="Script" path="res://game/data/level_definition.gd" id="2_level"]','']
goals = {"SCORE":0,"TRIOS":1,"GOLD":2}
for i,(g,c,sym,p,seed,rows) in enumerate(levels):
    for r in rows: assert len(r)==8,(i,r)
    out += [f'[sub_resource type="Resource" id="level_{i+1}"]','script = ExtResource("2_level")',
      'rows = Array[String](['+', '.join('"'+r+'"' for r in rows)+'])',
      f'goal = {goals[g]}', f'goal_count = {c}', f'goal_symbol = {sym}', f'pieces = {p}', f'random_seed = {seed}','']
out += ['[resource]','script = ExtResource("1_set")',
 'levels = Array[ExtResource("2_level")](['+', '.join(f'SubResource("level_{i+1}")' for i in range(len(levels)))+'])',
 'extra_pieces = 5','extra_pieces_ads = 2','']
OUTPUT.write_text('\n'.join(out))
