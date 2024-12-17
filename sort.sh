#!/bin/bash

## Исключим мультфильмы
join -1 1 -2 1 -t $'\t' title.basics.tsv title.ratings.tsv | awk -v OFS='\t' -F '\t' '$9 !~ /Animation/' | awk -F '\t' 'BEGIN{OFS="\t"} {print $1, $10, $11}' > title.ratings_parsed.tsv

## Выбрать всех актёров и актрис, которые снимались в фильмах, у которых больше 100 оценок
join -1 1 -2 1 title.ratings_parsed.tsv title.principals.tsv | awk '$6 == "actor" || $6 == "actress"' | awk '$3 >= 100' | awk 'BEGIN{OFS="\t"} {print $5, $2, $1}' | sort -u -k1 > sorted.tsv

## Посчитать количество фильмов у каждого актёра
awk -F '\t' 'BEGIN{OFS="\t"} {counts[$1]++} END { for (id in counts) print id, counts[id], sqrt(counts[id]) }' sorted.tsv | sort -k1 > count.tsv

## Средний рейтинг
awk -F '\t' 'BEGIN{OFS="\t"} { ratings[$1] += $2; counts[$1]++ } END { for (id in ratings) print id, ratings[id] / counts[id] }' sorted.tsv | sort -k1 > rating.tsv

## 
join -1 1 -2 1 -t $'\t' count.tsv rating.tsv | awk -F '\t' 'BEGIN{OFS="\t"} {print $1, $3*$4}' > prefinal.tsv

## Получить по коду актёра имя и отсортировать по рейтингу
join -1 1 -2 1 -t $'\t' name.basics.tsv prefinal.tsv | awk -F '\t' 'BEGIN{OFS="\t"} {print $2, $7}' | sort -t $'\t' -k2nr > final.tsv
