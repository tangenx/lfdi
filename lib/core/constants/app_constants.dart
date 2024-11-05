import 'dart:ui';

RegExp winRegExp = RegExp(
  r'^\"(?<winstr>.*)\"\s(?<wincore>[\d]+.[\d])\s\(Build\s(?<winbuild>.*)\)$',
  caseSensitive: true,
);

const appTitle = 'lfi';
const windowSize = Size(755, 545);
