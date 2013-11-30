/* global $, remark, MsgPanel  */

$(function () {
  'use strict';
  var slideshow = remark.create({
    ratio: '4:3'
  });
  var msgPanel = new MsgPanel($('#panel'));

  $(window).on('resize', function () {
    msgPanel.resize();
  });
  var ws = new WebSocket('ws://localhost:3000/tw_search');
  ws.onmessage = function (e) {
    var msg = JSON.parse(e.data);
    console.log(msg);
    msgPanel.add(msg);
  };
  $(window).unload(function () {
    ws.close();
    ws = null;
  });
});

// vi:set sts=2 sw=2 et:
