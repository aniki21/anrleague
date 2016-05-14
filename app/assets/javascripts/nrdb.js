var ev = null;
var nrdbPopover = function(){
  $('a[href*="netrunnerdb.com"]').on('click',function(e){
    ev = e;
    var that = $(this);
    var href = that.attr('href');
    var card_id = /card\/[0-9]{5}/.exec(href);
    var target = ev.target;

    if(card_id != undefined){
      // This is a card link (not a deck)
      ev.preventDefault();
      if(that.attr('data-toggle') != 'popover'){
        $.ajax({
          url: 'https://netrunnerdb.com/api/'+card_id,
          dataType:'json',
          success: function(d,s,x){
            var card = d[0];
            var card_body = formatCardBody(card);

            // Set the attributes on the link
            that.attr('title', '<span class="'+card.faction_code+'"><i class="icon icon-'+card.faction_code+'"></i> '+card.title+'<span>');
            that.attr('data-content', card_body);
            that.attr('data-toggle', 'popover');
            that.attr('data-trigger','focus');
            that.attr('data-placement','auto');
            that.attr('data-html',true);

            // Show the popover, at long last
            that.popover('show');
          },
          error: function(){
            // Shows popup error, but it'll have to do
            window.open(href,"_blank");
          }
        });
      }
      else{
        // We've already done the hard lifting, just show the popup
        that.popover('show');
      }
    }
  });
};

function formatCardBody(card){

  // Metadata
  var card_meta = '<strong>'+card.type+'</strong>';
  if(card.subtype != undefined && card.subtype != ""){
    card_meta += ': '+card.subtype;
  }

  switch(card.type_code){
    case 'identity':
      if(card.side_code == "runner"){
        card_meta += ' &middot; <i class="icon icon-link"></i> '+card.baselink;
      }
      card_meta += ' &middot; '+card.minimumdecksize+'/'+card.influencelimit;
      break;
      // Corp cards
    case 'agenda':
      card_meta += ' &middot; '+card.advancementcost+'/'+card.agendapoints;
      break;
    case 'asset':
      // rez, trash
      card_meta += ' &middot; '+card.cost+'<i class="icon icon-credit"></i> &middot; <i class="nr nr-trash"></i>'+card.trash;
      break;
    case 'operation':
      card_meta += ' &middot; '+card.cost+'<i class="icon icon-credit"></i>';
      break;
    case 'ice':
      card_meta += ' &middot; '+card.cost+'<i class="icon icon-credit"></i> &middot; Str: '+card.strength;
      break;
      // Runner cards
    case 'event':
      card_meta += ' &middot; '+card.cost+'<i class="icon icon-credit"></i>';
      break;
    case 'hardware':
      card_meta += ' &middot; '+card.cost+'<i class="icon icon-credit"></i>';
      break;
    case 'resource':
      card_meta += ' &middot; '+card.cost+'<i class="icon icon-credit"></i>';
      break;
    case 'program':
      card_meta += ' &middot; '+card.cost+'<i class="icon icon-credit"></i> &middot; '+card.memoryunits+'<i class="icon icon-mu"></i>';
      if(card.strength != undefined && card.strength != ""){
        card_meta += ' &middot; Str: '+card.strength;
      }
      break;
  }

  // Replace icons
  var card_text =  "";
  if(card.text != undefined && card.text != ""){
    card_text = card.text.replace(/\n/g,"</p><p>");
    card_text = card_text.replace(/\[Recurring Credits\]/g,'<i class="icon icon-recurring-credit"></i>');
    card_text = card_text.replace(/\[Subroutine\]/g,'<i class="icon icon-subroutine"></i>');
    card_text = card_text.replace(/\[Credits\]/g,'<i class="icon icon-credit"></i>');
    card_text = card_text.replace(/\[Click\]/g,'<i class="icon icon-click"></i>');
    card_text = card_text.replace(/\[Memory Unit\]/g,'<i class="icon icon-mu"></i>');
  }

  // Set the actual content of the card popover
  var card_body = '';
  card_body += '<p><small>'+card_meta+'</small></p>';
  card_body += '<p>'+card_text+'</p>';

  if(card.flavor != undefined){
    card_body += '<p><small><em>'+card.flavor+'</em></small></p>';
  }

  // Influence
  card_body += '<p class="text-right '+card.faction_code+'"><small>';
  for(i = 0; i<card.factioncost; i++){
    card_body += '<i class="fa fa-circle"></i>'
  }
  card_body += '</small></p>';

  return card_body;
}
