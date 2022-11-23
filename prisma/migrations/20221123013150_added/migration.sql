/*
  Warnings:

  - Added the required column `ageRating` to the `Anime` table without a default value. This is not possible if the table is not empty.

*/
-- RedefineTables
PRAGMA foreign_keys=OFF;
CREATE TABLE "new_Anime" (
    "kitsuId" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
    "malId" INTEGER,
    "synopsis" TEXT NOT NULL,
    "ageRating" TEXT NOT NULL,
    "title_en" TEXT,
    "title_jp" TEXT,
    "title" TEXT NOT NULL,
    "posterImg" TEXT NOT NULL,
    "coverImg" TEXT,
    "genres" TEXT NOT NULL,
    "score" REAL NOT NULL,
    "episodes" INTEGER,
    "slug" TEXT,
    "dubSlug" TEXT,
    "poster" INTEGER,
    "lastUpdated" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
);
INSERT INTO "new_Anime" ("coverImg", "dubSlug", "episodes", "genres", "kitsuId", "lastUpdated", "malId", "poster", "posterImg", "score", "slug", "synopsis", "title", "title_en", "title_jp") SELECT "coverImg", "dubSlug", "episodes", "genres", "kitsuId", "lastUpdated", "malId", "poster", "posterImg", "score", "slug", "synopsis", "title", "title_en", "title_jp" FROM "Anime";
DROP TABLE "Anime";
ALTER TABLE "new_Anime" RENAME TO "Anime";
CREATE UNIQUE INDEX "Anime_malId_key" ON "Anime"("malId");
PRAGMA foreign_key_check;
PRAGMA foreign_keys=ON;
